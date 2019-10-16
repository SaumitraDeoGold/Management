//
//  CatalogueListController.swift
//  DealorsApp
//
//  Created by Goldmedal on 8/1/18.
//  Copyright © 2018 Goldmedal. All rights reserved.
//

import UIKit
import FirebaseAnalytics

class CatalogueListController: BaseViewController , UITableViewDelegate , UITableViewDataSource{
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var menu: UIBarButtonItem!
     @IBOutlet weak var noDataView: NoDataView!
    
    var CatalogueElementMain = [CatalogueElement]()
    var CatalogueDataMain = [CatalogueData]()
    var CatalogueArray = [CatalogueObject]()
    
    var fromIndex = 0
    let batchSize = 10
    var ismore = true
    var strCin = ""
    var catalogueApi=""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addSlideMenuButton()
        
        self.noDataView.hideView(view: self.noDataView)
        
        Analytics.setScreenName("CATALOGUE SCREEN", screenClass: "CatalogueListController")
        
        let loginData =  UserDefaults.standard.value(forKey: "loginData") as? Dictionary ?? [:]
        strCin = loginData["userlogid"] as? String ?? ""
        
        let initialData =  UserDefaults.standard.value(forKey: "initialData") as? Dictionary ?? [:]
        catalogueApi = (initialData["baseApi"] as? String ?? "")+""+(initialData["catalogue"] as? String ?? "")
        
        // Do any additional setup after loading the view.
        if (Utility.isConnectedToNetwork()) {
            print("Internet connection available")
            self.apiCatalogueList()
            self.noDataView.hideView(view: self.noDataView)
        }
        else{
            print("No internet connection available")
            
            var alert = UIAlertView(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
            self.noDataView.showView(view: self.noDataView, from: "NET")
        }
        
        
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
    }
    
    
    func apiCatalogueList(){
        
        let json: [String: Any] = ["CIN":strCin,"ClientSecret":"201020","Index":fromIndex,"Count":batchSize]
        
        DataManager.shared.makeAPICall(url: catalogueApi, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            
            DispatchQueue.main.async {
            do {
                self.CatalogueElementMain = try JSONDecoder().decode([CatalogueElement].self, from: data!)
                
                self.CatalogueDataMain = self.CatalogueElementMain[0].data ?? []
                
                self.CatalogueArray.append(contentsOf:self.CatalogueDataMain[0].pricelistdata ?? [])
                
                self.ismore = self.CatalogueDataMain[0].ismore ?? false
            } catch let errorData {
                print(errorData.localizedDescription)
            }
               
                    if(self.tableView != nil)
                    {
                        self.tableView.reloadData()
                    }
                
                 if(self.CatalogueArray.count>0){
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
        
        guard let url = URL(string: CatalogueArray[sender.view!.tag].fileURL ?? "") else {
            var alert = UIAlertView(title: "Error", message: "Invalid Pdf", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
            
            return
        }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CatalogueArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        let cell = tableView.dequeueReusableCell(withIdentifier: "CatalogueListCell", for: indexPath) as! CatalogueListCell
        
        cell.lblRangeName.text = CatalogueArray[indexPath.row].rangeName?.capitalized ?? "-"
        cell.lblFromDate.text = CatalogueArray[indexPath.row].fromDate
        cell.lblBrandName.text = CatalogueArray[indexPath.row].brandName?.capitalized ?? "-"
        
        if CatalogueArray[indexPath.row].imgurl != ""
        {
            cell.imvCatalogue.sd_setImage(with: URL(string: CatalogueArray[indexPath.row].imgurl ?? ""), placeholderImage: UIImage(named: "no_image_icon.png"))
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.clickPdf))
        cell.imvCatalogue.addGestureRecognizer(tap)
        cell.imvCatalogue.tag = indexPath.row
        cell.imvCatalogue.isUserInteractionEnabled = true
        
        print(indexPath.row," --------------------------------------",CatalogueArray.count)
        
        if indexPath.row == CatalogueArray.count - 1 {
            
            if self.ismore {
                fromIndex = fromIndex + 10// last cell
                apiCatalogueList()
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
