//
//  VendorPurchase.swift
//  ManagementApp
//
//  Created by Goldmedal on 25/01/20.
//  Copyright © 2020 Goldmedal. All rights reserved.
//

import Foundation
import Crashlytics
import AMPopTip
struct highestdays: Codable {
    let result: Bool?
    let message, servertime: String?
    let data: [highestdaysObj]
}

// MARK: - Datum
struct highestdaysObj: Codable {
    let highdays: String?
    let ledgerdownload, agingdownload, purchaseLedgerAmt, saleLedgerAmt, diffrence: String?
}
@IBDesignable class VendorPurchase: BaseCustomView {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var lblSales: UILabel!
    @IBOutlet var lblOverallGrowth: UILabel!
    @IBOutlet var lblLYS: UILabel!
    @IBOutlet weak var imvInfo: UIImageView!
    @IBOutlet var lblHeader: UILabel!
    @IBOutlet weak var imvLedger: UIImageView!
    @IBOutlet weak var imvHighDays: UIImageView!
    @IBOutlet weak var stackView: UIView!
    
    var vendorPurchase = [VendorPurchaseObject]()
    var vendorPurchaseObject = [VendorPurchaseObj]()
    var highestDays = [highestdays]()
    var highestDaysObj = [highestdaysObj]()
    var dueSequence = Bool()
    
    var currYearSales: Double = 0
    var lastYearSales: Double = 0
    var overallGrowth: Double = 0
    
    var strCin = String()
    var txtToolTip = "Vendor Purchase Amnt of the current financial year"
    var apiVendor = ""
    let popTip = PopTip()
    var lastYearSalesApi = ""
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let (fromdate, todate) = Utility.yearDate()
    //print("AppDel \(appDelegate.newCin)")
    
    override func xibSetup() {
        super.xibSetup()
        lblHeader.text = appDelegate.partyName
        apiVendor = "https://api.goldmedalindia.in/api/getVendorPurchaseAndLedger"
        ViewControllerUtils.sharedInstance.showLoader()
        apiVendorTotal()
        apiHighestDays()
        
        
        let initialData =  UserDefaults.standard.value(forKey: "initialData") as? Dictionary ?? [:]
        lastYearSalesApi = (initialData["baseApi"] as? String ?? "")+""+(initialData["lastYearSales"] as? String ?? "")
        
        let tapInfo = UITapGestureRecognizer(target: self, action: #selector(SalesView.tapFunction))
        imvInfo.addGestureRecognizer(tapInfo)
         
        let tapLedger = UITapGestureRecognizer(target: self, action: #selector(self.clickedLedger))
        imvLedger.addGestureRecognizer(tapLedger)
        let tapHD = UITapGestureRecognizer(target: self, action: #selector(self.clickedHD))
        imvHighDays.addGestureRecognizer(tapHD)
    }
    
    @objc func clickedHD(sender:UITapGestureRecognizer) {
               let storyboard = UIStoryboard(name: "Main", bundle: nil)
               let destViewController = storyboard.instantiateViewController(withIdentifier: "Webview") as! viewPDFController
                destViewController.webvwUrl = highestDaysObj[0].agingdownload!
               parentViewController?.navigationController!.pushViewController(destViewController, animated: true)
           }
    
    @objc func clickedLedger(sender:UITapGestureRecognizer) {
           let storyboard = UIStoryboard(name: "Main", bundle: nil)
           let destViewController = storyboard.instantiateViewController(withIdentifier: "Webview") as! viewPDFController
           destViewController.webvwUrl = highestDaysObj[0].ledgerdownload!
           parentViewController?.navigationController!.pushViewController(destViewController, animated: true)
           //self.navigationController!.pushViewController(destViewController, animated: true)
//           let topViewController : UIViewController = parent?.navigationController!.topViewController!
//           parent?.navigationController!.pushViewController(destViewController, animated: true)
       }
    
    @objc func tapFunction(sender:UITapGestureRecognizer) {
        popTip.bubbleColor = UIColor.black
        popTip.show(text: txtToolTip, direction: .none, maxWidth: 300, in: view, from: view.frame)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.popTip.hide()
        }
    }
    
//    @IBAction func btnCreditNote(_ sender: Any) {
//        let cdNote = parentViewController?.storyboard?.instantiateViewController(withIdentifier: "CreditDebitNote") as! CreditDebitViewController
//        parentViewController?.navigationController?.pushViewController(cdNote, animated: true)
//
//    }
    
//    @IBAction func btnTOD(_ sender: Any) {
//        let tod = parentViewController?.storyboard?.instantiateViewController(withIdentifier: "TOD") as! TODViewController
//        parentViewController?.navigationController?.pushViewController(tod, animated: true)
//
//    }
//
//    @IBAction func btnQwikPay(_ sender: Any) {
//        let vcOutstandingCalculationReport  = parentViewController?.storyboard?.instantiateViewController(withIdentifier: "OutstandingPaymentCalculation") as! OutstandingPaymentCalculationController
//        vcOutstandingCalculationReport.maintainDueSequence = dueSequence
//        parentViewController?.present(vcOutstandingCalculationReport, animated: false, completion: nil)
//    }
    
    //API CALL...
    func apiVendorTotal(){
        let json: [String: Any] = ["ClientSecret":"ClientSecret","CIN":UserDefaults.standard.value(forKey: "userCIN") as! String,"Category":UserDefaults.standard.value(forKey: "userCategory") as! String, "Vendorid":appDelegate.sendCin,"fromdate":fromdate,"todate":todate]
        let manager =  DataManager.shared
        //print("Params Sent : \(json)")
        manager.makeAPICall(url: apiVendor, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            
            do {
                self.vendorPurchase = try JSONDecoder().decode([VendorPurchaseObject].self, from: data!)
                self.vendorPurchaseObject  = self.vendorPurchase[0].data
                self.lblLYS.text = Utility.formatRupee(amount: Double(self.vendorPurchaseObject[0].ledgerbalanceamt!)!)
                self.lblSales.text = Utility.formatRupee(amount: Double(self.vendorPurchaseObject[0].purchaseamt!)!)
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
    
    func apiHighestDays(){
        let json: [String: Any] = ["ClientSecret":"ClientSecret","CIN":UserDefaults.standard.value(forKey: "userCIN") as! String,"Category":UserDefaults.standard.value(forKey: "userCategory") as! String, "Id":appDelegate.sendCin,"fromdate":"04/01/2019","todate":"03/31/2020"]
        let manager =  DataManager.shared
        print("Params Sent ------------------>>> : \(json)")
        manager.makeAPICall(url: "https://test2.goldmedalindia.in/api/getvendorhighestdaysandledgeragingdownload", params: json, method: .POST, success: { (response) in
            let data = response as? Data
            
            do {
                self.highestDays = try JSONDecoder().decode([highestdays].self, from: data!)
                self.highestDaysObj  = self.highestDays[0].data
                self.lblOverallGrowth.text = (self.highestDaysObj[0].highdays!)
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

    
//    func apiSales(){
//        ViewControllerUtils.sharedInstance.showViewLoader(view: view)
//
//        let json: [String: Any] = ["CIN":appDelegate.sendCin,"ClientSecret":"201020"]
//
//        DataManager.shared.makeAPICall(url: lastYearSalesApi, params: json, method: .POST, success: { (response) in
//            let data = response as? Data
//
//            do {
//
//                self.salesMain = try JSONDecoder().decode([SaleElement].self, from: data!)
//                self.salesData = self.salesMain[0].data ?? []
//                print("CIN RECIEVED \(self.appDelegate.sendCin)")
//                let result = self.salesMain[0].result ?? false
//
//                if result
//                {
//                    OperationQueue.main.addOperation {
//
//                        print(self.salesData[0].curyearsale,"-- ---",self.salesData[0].lstyearsale)
//
//                        self.currYearSales = Double(self.salesData[0].curyearsale ?? "0.0")!
//                        self.lastYearSales = Double(self.salesData[0].lstyearsale ?? "0.0")!
//
//                        if (self.lastYearSales != 0 && self.currYearSales != 0)
//                        {
//                            self.overallGrowth = ((self.currYearSales - self.lastYearSales)/self.lastYearSales)*100
//                            self.lblOverallGrowth.text = String(format: "%.2f", self.overallGrowth) + "%"
//                        }
//
//
//                        self.lblLYS.text = Utility.formatRupee(amount: self.lastYearSales)
//                        self.lblSales.text = Utility.formatRupee(amount: self.currYearSales)
//
//                        if self.overallGrowth > 0
//                        {
//                            if #available(iOS 11.0, *) {
//                                self.lblOverallGrowth.backgroundColor = UIColor(named: "ColorGreen")
//                            } else {
//                                self.lblOverallGrowth.backgroundColor = UIColor.green
//                            }
//                        }else{
//                            if #available(iOS 11.0, *) {
//                                self.lblOverallGrowth.backgroundColor = UIColor(named: "ColorRed")
//                            } else {
//                                self.lblOverallGrowth.backgroundColor = UIColor.red
//                            }
//                        }
//
//                    }
//                }
//                ViewControllerUtils.sharedInstance.removeLoader()
//            } catch let errorData {
//                print(errorData.localizedDescription)
//                ViewControllerUtils.sharedInstance.removeLoader()
//            }
//        }) { (Error) in
//            ViewControllerUtils.sharedInstance.removeLoader()
//            print(Error?.localizedDescription ?? "ERROR")
//        }
//
//    }
    
    
}
