//
//  TechSpecificationController.swift
//  DealorsApp
//
//  Created by Goldmedal on 5/5/18.
//  Copyright © 2018 Goldmedal. All rights reserved.
//

import UIKit
import SDWebImage
import FirebaseAnalytics

class TechSpecificationController: BaseViewController, UITableViewDelegate , UITableViewDataSource {

    @IBOutlet weak var menuSpecification: UIBarButtonItem!
    @IBOutlet weak var tableViewSpecification: UITableView!
    @IBOutlet weak var noDataView: NoDataView!
    
    var TechSpecsElementMain = [TechSpecsElement]()
    var TechSpecsArray = [TechSpecsData]()
    var strCin = ""
    var techSpecsApi=""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        noDataView.hideView(view: noDataView)
        
        addSlideMenuButton()
        
        Analytics.setScreenName("TECH SPECIFICATION SCREEN", screenClass: "TechSpecificationController")
        
        let loginData =  UserDefaults.standard.value(forKey: "loginData") as? Dictionary ?? [:]
        strCin = loginData["userlogid"] as? String ?? ""
        
        let initialData =  UserDefaults.standard.value(forKey: "initialData") as? Dictionary ?? [:]
        techSpecsApi = (initialData["baseApi"] as? String ?? "")+""+(initialData["technicalSpecification"] as? String ?? "")
        
        // Do any additional setup after loading the view.
        if (Utility.isConnectedToNetwork()) {
            print("Internet connection available")
            self.apiTechSpecsList()
            self.noDataView.hideView(view: self.noDataView)
        }
        else{
            print("No internet connection available")
            
            var alert = UIAlertView(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
             self.noDataView.showView(view: self.noDataView, from: "NET")
        }
        
        self.tableViewSpecification.delegate = self;
        self.tableViewSpecification.dataSource = self;
    }
    
    
    func apiTechSpecsList(){
        
         let json: [String: Any] = ["CIN":strCin,"ClientSecret":"ClientSecret"]
        
        DataManager.shared.makeAPICall(url: techSpecsApi, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            
            DispatchQueue.main.async {
            do {
                self.TechSpecsElementMain = try JSONDecoder().decode([TechSpecsElement].self, from: data!)
                self.TechSpecsArray = self.TechSpecsElementMain[0].data
         
            } catch let errorData {
                print(errorData.localizedDescription)
            }
                
               
                    if(self.tableViewSpecification != nil)
                    {
                        self.tableViewSpecification.reloadData()
                    }
                
                 if(self.TechSpecsArray.count>0){
                    self.noDataView.hideView(view: self.noDataView)
                }else{
                    self.noDataView.showView(view: self.noDataView, from: "NDA")
                }
            }
        }) { (Error) in
            self.noDataView.showView(view: self.noDataView, from: "ERR")
            ViewControllerUtils.sharedInstance.removeLoader()
            print(Error?.localizedDescription)
        }
        
    }
    
    
    func clickPdf(sender: UITapGestureRecognizer)
    {
        print("pdf name : \(sender.view!.tag)")
        
        guard let url = URL(string: TechSpecsArray[sender.view!.tag].url ?? "") else {
            
            var alert = UIAlertView(title: "Error", message: "Invalid Pdf", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
            
            return
        }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return TechSpecsArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TechSpecsListCell", for: indexPath) as! TechSpecsRowCell
        if(TechSpecsArray.count > 0){
      cell.lblCode.text = TechSpecsArray[indexPath.row].code?.capitalized ?? "-"
      cell.lblName.text = TechSpecsArray[indexPath.row].name?.capitalized ?? "-"
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.clickPdf))
            cell.imvTechSpecs.addGestureRecognizer(tap)
            cell.imvTechSpecs.tag = indexPath.row
            cell.imvTechSpecs.isUserInteractionEnabled = true
        
        if TechSpecsArray[indexPath.row].imgurl != ""
        {
            cell.imvTechSpecs.sd_setImage(with: URL(string: TechSpecsArray[indexPath.row].imgurl ?? ""), placeholderImage: UIImage(named: "no_image_icon.png"))
        }
       
    }
 
        return cell
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
 
}
