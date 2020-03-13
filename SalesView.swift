//
//  DATAView.swift
//  DealorsApp
//
//  Created by Goldmedal on 8/4/18.
//  Copyright © 2018 Goldmedal. All rights reserved.
//


import UIKit
import Crashlytics
import AMPopTip

@IBDesignable class SalesView: BaseCustomView {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var lblSales: UILabel!
    @IBOutlet var lblOverallGrowth: UILabel!
    @IBOutlet var lblLYS: UILabel!
    @IBOutlet weak var imvInfo: UIImageView!
    @IBOutlet weak var creditDebitNote: UIButton!
    
    var salesMain = [SaleElement]()
    var salesData = [sales]()
    var dueSequence = Bool()
    
    var currYearSales: Double = 0
    var lastYearSales: Double = 0
    var overallGrowth: Double = 0
    
    var strCin = String()
    var txtToolTip = "Net Amnt is the total sales achieved before tax in current financial year"
    let popTip = PopTip()
    var lastYearSalesApi = ""
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    //print("AppDel \(appDelegate.newCin)")
  
    override func xibSetup() {
        super.xibSetup()
        //let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        // Drawing code
        //let loginData =  UserDefaults.standard.value(forKey: "loginData") as? Dictionary ?? [:]
        //strCin = loginData["userlogid"] as? String ?? ""
        
        let initialData =  UserDefaults.standard.value(forKey: "initialData") as? Dictionary ?? [:]
         lastYearSalesApi = (initialData["baseApi"] as? String ?? "")+""+(initialData["lastYearSales"] as? String ?? "")
        
        let tapInfo = UITapGestureRecognizer(target: self, action: #selector(SalesView.tapFunction))
        imvInfo.addGestureRecognizer(tapInfo)
        //print("CIN : \(strCin)")
        apiSales()
    }
    
    
    @objc func tapFunction(sender:UITapGestureRecognizer) {
        popTip.bubbleColor = UIColor.black
        popTip.show(text: txtToolTip, direction: .none, maxWidth: 300, in: view, from: view.frame)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.popTip.hide()
        }
    }

    @IBAction func btnCreditNote(_ sender: Any) {
        let cdNote = parentViewController?.storyboard?.instantiateViewController(withIdentifier: "CreditDebitNote") as! CreditDebitViewController
        parentViewController?.navigationController?.pushViewController(cdNote, animated: true)
        
//        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
//        let vc = storyboard.instantiateViewController(withIdentifier: "CreditDebitNote") as! CreditDebitViewController
//        if vc != nil {
//            vc.view.frame = (self.window!.frame)
//            self.window!.addSubview(vc.view)
//            self.window!.bringSubview(toFront: vc.view)
//        }
        //self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func btnProfile(_ sender: Any) {
        let tod = parentViewController?.storyboard?.instantiateViewController(withIdentifier: "MyProfile") as! MyProfileController
        tod.fromDealer = true
        parentViewController?.navigationController?.pushViewController(tod, animated: true)
        
    }
    
//    let vc = self.storyboard?.instantiateViewController(withIdentifier: "DivNBranch") as! DivNBranchwiseController
//    vc.fromdate = fromdate//"01/01/\(currYear)"
//    vc.todate = todate//"03/31/\(currYear)"
//    vc.format = "quarterly"
//    parent?.navigationController!.pushViewController(vc, animated: true)
    
    @IBAction func btnTOD(_ sender: Any) {
        let tod = parentViewController?.storyboard?.instantiateViewController(withIdentifier: "TOD") as! TODViewController
        parentViewController?.navigationController?.pushViewController(tod, animated: true)
        
    }
    
    @IBAction func btnQwikPay(_ sender: Any) {
        let vcOutstandingCalculationReport  = parentViewController?.storyboard?.instantiateViewController(withIdentifier: "OutstandingPaymentCalculation") as! OutstandingPaymentCalculationController
        vcOutstandingCalculationReport.maintainDueSequence = dueSequence
        parentViewController?.present(vcOutstandingCalculationReport, animated: false, completion: nil)
    }
    
    func apiSales(){
        ViewControllerUtils.sharedInstance.showViewLoader(view: view)
        
        let json: [String: Any] = ["CIN":appDelegate.sendCin,"ClientSecret":"201020"]
        
        DataManager.shared.makeAPICall(url: lastYearSalesApi, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            
            do {
                
                self.salesMain = try JSONDecoder().decode([SaleElement].self, from: data!)
                self.salesData = self.salesMain[0].data ?? []
                print("CIN RECIEVED \(self.appDelegate.sendCin)")
                let result = self.salesMain[0].result ?? false
                
                if result
                {
                    OperationQueue.main.addOperation {
                        
                        print(self.salesData[0].curyearsale,"-- ---",self.salesData[0].lstyearsale)
                        
                        self.currYearSales = Double(self.salesData[0].curyearsale ?? "0.0")!
                        self.lastYearSales = Double(self.salesData[0].lstyearsale ?? "0.0")!
                        
                        if (self.lastYearSales != 0 && self.currYearSales != 0)
                        {
                        self.overallGrowth = ((self.currYearSales - self.lastYearSales)/self.lastYearSales)*100
                        self.lblOverallGrowth.text = String(format: "%.2f", self.overallGrowth) + "%"
                        }
                       
                        
                        self.lblLYS.text = Utility.formatRupee(amount: self.lastYearSales)
                        self.lblSales.text = Utility.formatRupee(amount: self.currYearSales)
                        
                        if self.overallGrowth > 0
                        {
                            if #available(iOS 11.0, *) {
                                self.lblOverallGrowth.backgroundColor = UIColor(named: "ColorGreen")
                            } else {
                                self.lblOverallGrowth.backgroundColor = UIColor.green
                            }
                        }else{
                            if #available(iOS 11.0, *) {
                                self.lblOverallGrowth.backgroundColor = UIColor(named: "ColorRed")
                            } else {
                                 self.lblOverallGrowth.backgroundColor = UIColor.red
                            }
                        }
                        
                    }
                }
                 ViewControllerUtils.sharedInstance.removeLoader()
            } catch let errorData {
                print(errorData.localizedDescription)
                ViewControllerUtils.sharedInstance.removeLoader()
            }
        }) { (Error) in
            ViewControllerUtils.sharedInstance.removeLoader()
            print(Error?.localizedDescription ?? "ERROR")
        }
        
    }


}
