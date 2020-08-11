//
//  AmountDifference.swift
//  ManagementApp
//
//  Created by Goldmedal on 18/07/20.
//  Copyright © 2020 Goldmedal. All rights reserved.
//

import Foundation
@IBDesignable class AmountDifference: BaseCustomView {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var lblSales: UILabel!
    @IBOutlet var lblPurchase: UILabel!
    @IBOutlet var lblDifference: UILabel!
    
    var vendorPurchase = [VendorPurchaseObject]()
    var vendorPurchaseObject = [VendorPurchaseObj]()
    var highestDays = [highestdays]()
    var highestDaysObj = [highestdaysObj]()
    var dueSequence = Bool()
    
    var currYearSales: Double = 0
    var lastYearSales: Double = 0
    var overallGrowth: Double = 0
    
    var strCin = String()
    var apiVendor = ""
    var lastYearSalesApi = ""
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let (fromdate, todate) = Utility.yearDate()
    //print("AppDel \(appDelegate.newCin)")
    
    override func xibSetup() {
        super.xibSetup()
        //lblHeader.text = appDelegate.partyName
        apiVendor = "https://api.goldmedalindia.in/api/getVendorPurchaseAndLedger"
        ViewControllerUtils.sharedInstance.showLoader() 
        apiHighestDays()
        
        
        let initialData =  UserDefaults.standard.value(forKey: "initialData") as? Dictionary ?? [:]
        lastYearSalesApi = (initialData["baseApi"] as? String ?? "")+""+(initialData["lastYearSales"] as? String ?? "")
        
         
    }
    
     
    
    func apiHighestDays(){
        let json: [String: Any] = ["ClientSecret":"ClientSecret","CIN":UserDefaults.standard.value(forKey: "userCIN") as! String,"Category":UserDefaults.standard.value(forKey: "userCategory") as! String, "Id":appDelegate.sendCin,"fromdate":"04/01/2019","todate":"03/31/2020"]
        let manager =  DataManager.shared
        print("Params Sent ------------------>>> : \(json)")
        manager.makeAPICall(url: "https://test2.goldmedalindia.in/api/getvendorhighestdaysandledgeragingdownload", params: json, method: .POST, success: { (response) in
            let data = response as? Data
            
            do {
                self.highestDays = try JSONDecoder().decode([highestdays].self, from: data!)
                self.highestDaysObj  = self.highestDays[0].data
                self.lblSales.text = Utility.formatRupee(amount: Double(self.highestDaysObj[0].saleLedgerAmt!)!)
                self.lblPurchase.text = Utility.formatRupee(amount: Double(self.highestDaysObj[0].purchaseLedgerAmt!)!)
                self.lblDifference.text = Utility.formatRupee(amount: Double(self.highestDaysObj[0].diffrence!)!)
                ViewControllerUtils.sharedInstance.removeLoader()
            } catch let errorData {
                print(errorData.localizedDescription)
                ViewControllerUtils.sharedInstance.removeLoader()
            }
        }) { (Error) in
            print(Error?.localizedDescription as Any)
            ViewControllerUtils.sharedInstance.removeLoader()
        }
    }
 
    
}
