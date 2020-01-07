//
//  ActiveSchemeController.swift
//  DealorsApp
//
//  Created by Goldmedal on 4/3/18.
//  Copyright © 2018 Goldmedal. All rights reserved.
//

import UIKit
import FirebaseAnalytics

class ActiveSchemeController: BaseViewController , UITableViewDelegate , UITableViewDataSource {
    
    var ActiveSchemeElementMain = [ActiveSchemeElement]()
    var ActiveSchemeDataMain = [ActiveSchemeData]()
    var ActiveSchemeArray = [ActiveSchemeObject]()
    @IBOutlet weak var noDataView: NoDataView!
   
    @IBOutlet weak var menuActiveScheme: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    
    var fromIndex = 0
    let batchSize = 10
    var ismore = true
    var strCin = ""
    var activeSchemeApi=""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
         self.noDataView.hideView(view: self.noDataView)

        // Do any additional setup after loading the view.
        addSlideMenuButton()
        
        Analytics.setScreenName("ACTIVE SCHEME SCREEN", screenClass: "ActiveSchemeController")
        
        let loginData =  UserDefaults.standard.value(forKey: "loginData") as? Dictionary ?? [:]
        strCin = loginData["userlogid"] as? String ?? ""
        
        let initialData =  UserDefaults.standard.value(forKey: "initialData") as? Dictionary ?? [:]
        activeSchemeApi = (initialData["baseApi"] as? String ?? "")+""+(initialData["activeScheme"] as? String ?? "")
        
        if (Utility.isConnectedToNetwork()) {
            print("Internet connection available")
            OperationQueue.main.addOperation {
            self.ActiveSchemeArray.removeAll()
            self.apiActiveScheme();
            }
             self.noDataView.hideView(view: self.noDataView)
        }
        else {
            print("No internet connection available")
            
            var alert = UIAlertView(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
            self.noDataView.showView(view: self.noDataView, from: "NET")
        }
        
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
 
    }
    
    
    
    func apiActiveScheme(){
       
         let json: [String: Any] = ["CIN":strCin,"ClientSecret":"ClientSecret","Index":fromIndex,"Count":batchSize]
        
        DataManager.shared.makeAPICall(url: activeSchemeApi, params: json, method: .POST, success: { (response) in
            let data = response as? Data
          
             DispatchQueue.main.async {
            do {
               self.ActiveSchemeElementMain = try JSONDecoder().decode([ActiveSchemeElement].self, from: data!)
                
                self.ActiveSchemeDataMain = self.ActiveSchemeElementMain[0].data
                self.ActiveSchemeArray.append(contentsOf:self.ActiveSchemeDataMain[0].activeschemedata)
                self.ismore = (self.ActiveSchemeDataMain[0].ismore ?? false)!
                
                }
            catch let errorData {
                print(errorData.localizedDescription)
            }
                
                
                    if(self.tableView != nil)
                    {
                        self.tableView.reloadData()
                    }
                
                if(self.ActiveSchemeArray.count>0){
                    self.noDataView.hideView(view: self.noDataView)
                }else{
                    self.noDataView.showView(view: self.noDataView, from: "NDA")
                }
           
        }
            
        }) { (Error) in
            ViewControllerUtils.sharedInstance.removeLoader()
            print(Error?.localizedDescription)
            self.noDataView.showView(view: self.noDataView, from: "ERR")
        }
       
    }
    
    
    func clickPdf(sender: UITapGestureRecognizer)
    {
        print("pdf name : \(sender.view!.tag)")
        
        guard let url = URL(string: ActiveSchemeArray[sender.view!.tag].link ?? "") else {
            var alert = UIAlertView(title: "Error", message: "Invalid Pdf", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
            
            return
        }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ActiveSchemeArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
         let cell = tableView.dequeueReusableCell(withIdentifier: "ActiveSchemeCell", for: indexPath) as! ActiveSchemeCell
     
        cell.lblFromDate.text = ActiveSchemeArray[indexPath.row].fromDate ?? "-"
        cell.lblSchemeName.text = ActiveSchemeArray[indexPath.row].schemeName?.capitalized ?? "-"
        cell.lblSchemeType.text = ActiveSchemeArray[indexPath.row].schemeType?.capitalized ?? "-"
        
        if ActiveSchemeArray[indexPath.row].imgurl != ""
        {
            cell.imvActiveScheme.sd_setImage(with: URL(string: ActiveSchemeArray[indexPath.row].imgurl ?? ""), placeholderImage: UIImage(named: "no_image_icon.png"))
        }else{
            cell.imvActiveScheme.image = UIImage(named: "no_image_icon.png")
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.clickPdf))
        cell.imvActiveScheme.addGestureRecognizer(tap)
        cell.imvActiveScheme.tag = indexPath.row
        cell.imvActiveScheme.isUserInteractionEnabled = true
        
        
        print(indexPath.row," --------------------------------------",ActiveSchemeArray.count)
        
        if indexPath.row == ActiveSchemeArray.count - 1 {
            
            if self.ismore {
                fromIndex = fromIndex + 10// last cell
                apiActiveScheme()
            }else{
                print("No more data")
            }
        }
        
        return cell
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}
