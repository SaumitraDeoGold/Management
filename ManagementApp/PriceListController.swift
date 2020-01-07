//
//  PriceListController.swift
//  DealorsApp
//
//  Created by Goldmedal on 3/29/18.
//  Copyright © 2018 Goldmedal. All rights reserved.
//

import UIKit
import FirebaseAnalytics

class PriceListController: BaseViewController , UITableViewDelegate , UITableViewDataSource{

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var menuPriceList: UIBarButtonItem!
    @IBOutlet weak var noDataView: NoDataView!
    
    var PriceListElementMain = [PriceListElement]()
    var PriceListDataMain = [PriceListData]()
    var PriceListArray = [PricelistObject]()
    
    var fromIndex = 0
    let batchSize = 10
    var ismore = true
    var strCin = ""
    var priceListApi=""
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        addSlideMenuButton()
        
        Analytics.setScreenName("PRICE LIST SCREEN", screenClass: "PriceListController")
        
        let loginData =  UserDefaults.standard.value(forKey: "loginData") as? Dictionary ?? [:]
        strCin = loginData["userlogid"] as? String ?? ""
        
        let initialData =  UserDefaults.standard.value(forKey: "initialData") as? Dictionary ?? [:]
        priceListApi = (initialData["baseApi"] as? String ?? "")+""+(initialData["priceList"] as? String ?? "")
        
        // Do any additional setup after loading the view.
        if (Utility.isConnectedToNetwork()) {
            print("Internet connection available")
            self.apiPriceList()
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
    
  
    
    func apiPriceList(){
        
        let json: [String: Any] = ["CIN":strCin,"ClientSecret":"201020","Index":fromIndex,"Count":batchSize]
        
        DataManager.shared.makeAPICall(url: priceListApi, params: json, method: .POST, success: { (response) in
            let data = response as? Data
             DispatchQueue.main.async {
                    do {
                     self.PriceListElementMain = try JSONDecoder().decode([PriceListElement].self, from: data!)
            
                     self.PriceListDataMain = self.PriceListElementMain[0].data
            
                      self.PriceListArray.append(contentsOf:self.PriceListDataMain[0].pricelistdata)
            
                       self.ismore = (self.PriceListDataMain[0].ismore ?? false)!
                
            } catch let errorData {
                print(errorData.localizedDescription)
            }
              
               
                    if(self.tableView != nil)
                    {
                        self.tableView.reloadData()
                    }
                
                if(self.PriceListArray.count>0){
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
        
        guard let url = URL(string: PriceListArray[sender.view!.tag].fileURL ?? "") else {
            var alert = UIAlertView(title: "Error", message: "Invalid Pdf", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
            
            return
        }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return PriceListArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
       // let cell = Bundle.main.loadNibNamed("PriceListCell", owner: self, options: nil)?.first as! PriceListCell
        let cell = tableView.dequeueReusableCell(withIdentifier: "PriceListCell", for: indexPath) as! PriceListCell
        
        cell.lblRangeName.text = PriceListArray[indexPath.row].rangeName?.capitalized ?? "-"
         cell.lblDate.text = PriceListArray[indexPath.row].fromDate ?? "-"
         cell.lblBrandName.text = PriceListArray[indexPath.row].brandName?.capitalized ?? "-"
        
        if PriceListArray[indexPath.row].imgurl != ""
        {
            cell.imvPriceList.sd_setImage(with: URL(string: PriceListArray[indexPath.row].imgurl ?? ""), placeholderImage: UIImage(named: "no_image_icon.png"))
        }else{
            cell.imvPriceList.image = UIImage(named: "no_image_icon.png")
        }
        
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.clickPdf))
        cell.imvPriceList.addGestureRecognizer(tap)
        cell.imvPriceList.tag = indexPath.row
        cell.imvPriceList.isUserInteractionEnabled = true
       
        print(indexPath.row," --------------------------------------",PriceListArray.count)
        
        if indexPath.row == PriceListArray.count - 1 {
            
            if self.ismore {
                fromIndex = fromIndex + 10// last cell
                apiPriceList()
            }else{
                print("No More data")
            }
        }
        
        return cell
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   
}
