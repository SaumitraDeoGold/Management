//
//  TodDetailPopupController.swift
//  DealorsApp
//
//  Created by Goldmedal on 7/11/19.
//  Copyright © 2019 Goldmedal. All rights reserved.
//

import UIKit

struct TODDetailElement: Codable {
    let result: Bool?
    let message, servertime: String?
    let data: [TODDetailObj]
}

// MARK: - Datum
struct TODDetailObj: Codable {
    let todgroupnm, yearlyTargetAmt, yearlySalesAmt, yearlytradeSale: String?
    let yearlyprojectSale, yearlyEarnedAmt: String?
}

class TodDetailPopupController: UIViewController , UITableViewDelegate , UITableViewDataSource {
    
    @IBOutlet weak var viewHeight: NSLayoutConstraint!
   
    var TODDetailElementMain = [TODDetailElement]()
    var TODDetailObjMain = [TODDetailObj]()
  
    @IBOutlet weak var imvClose: UIImageView!
    @IBOutlet weak var vwClose: UIView!
    @IBOutlet weak var tableView: UITableView!

    var strCin = ""
    var TODInfoApi = ""
    var cinRecieved = ""
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cinRecieved = appDelegate.sendCin
        let loginData =  UserDefaults.standard.value(forKey: "loginData") as? Dictionary ?? [:]
        strCin = loginData["userlogid"] as? String ?? ""
        
        let initialData =  UserDefaults.standard.value(forKey: "initialData") as? Dictionary ?? [:]
      //  TODInfoApi = "https://test2.goldmedalindia.in/api/getTODSalesInfo"
        TODInfoApi = (initialData["baseApi"] as? String ?? "")+""+(initialData["todSalesInfo"] as? String ?? "")
        
        // Do any additional setup after loading the view.
        if (Utility.isConnectedToNetwork()) {
            print("Internet connection available")
            OperationQueue.main.addOperation {
                self.apiTODInfoDetail()
            }
        }
        else{
            print("No internet connection available")
            
            var alert = UIAlertView(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
        }
      
        let tabClose = UITapGestureRecognizer(target: self, action: #selector(self.tapFunction))
        vwClose.addGestureRecognizer(tabClose)
        
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
    }
    
    @objc func tapFunction(sender:UITapGestureRecognizer) {
        print("tap working")
        dismiss(animated: true)
    }
    
    
    func apiTODInfoDetail(){
        ViewControllerUtils.sharedInstance.showLoader()
        
        let json: [String: Any] = ["CIN":cinRecieved,"ClientSecret":"201020"]
        
        DataManager.shared.makeAPICall(url: TODInfoApi, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            DispatchQueue.main.async {
                do {
                    self.TODDetailElementMain = try JSONDecoder().decode([TODDetailElement].self, from: data!)
                    self.TODDetailObjMain = self.TODDetailElementMain[0].data
                    
                    if(self.TODDetailObjMain.count == 0){
                        var alert = UIAlertView(title: "No Data available", message: "No Data available", delegate: nil, cancelButtonTitle: "OK")
                        alert.show()
                        
                        self.dismiss(animated: true)
                    }else{
                        if(self.tableView != nil)
                        {
                            self.tableView.reloadData()
                            self.viewHeight.constant = CGFloat((self.TODDetailObjMain.count*40)+80)
                        }
                    }
                    
                } catch let errorData {
                    print(errorData.localizedDescription)
                    self.dismiss(animated: true, completion: nil)
                }
              
            }
            ViewControllerUtils.sharedInstance.removeLoader()
        }) { (Error) in
            ViewControllerUtils.sharedInstance.removeLoader()
            print(Error?.localizedDescription)
            self.dismiss(animated: true, completion: nil)
        }
        
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodDetailCell", for: indexPath) as! TodDetailCell
      
            cell.lblGroupName.text = TODDetailObjMain[indexPath.row].todgroupnm ?? "-"
            cell.lblYearlyTarget.text = Utility.formatRupee(amount:Double(self.TODDetailObjMain[indexPath.row].yearlyTargetAmt ?? "0.0")!)
            cell.lblYearlySales.text = Utility.formatRupee(amount:Double(self.TODDetailObjMain[indexPath.row].yearlySalesAmt ?? "0.0")!)
            
            return cell
       
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return TODDetailObjMain.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    
}

