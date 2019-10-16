//
//  OutstandingSummaryViewController.swift
//  DealorsApp
//
//  Created by Goldmedal on 2/20/19.
//  Copyright © 2019 Goldmedal. All rights reserved.
//

import UIKit
import FirebaseAnalytics


// - - - - - - For retry payment api - - - -  - - - - - - -
struct OutsPaymentRetryElement: Codable {
    let result: Bool?
    let message, servertime: String?
    let data: [OutsPaymentRetryObj]?
}

struct OutsPaymentRetryObj: Codable {
     let newtransactionid: String?
}


// - - - - - - For freepay payment api - - - -  - - - - - - -
struct FreePayPaymentElement: Codable {
    let result: Bool?
    let message, servertime: String?
    let data: [FreePayPaymentObj]
}

struct FreePayPaymentObj: Codable {
    let mobile, email: String?
}




class OutstandingSummaryViewController: UIViewController,PopupDateDelegate,UITableViewDelegate,UITableViewDataSource {
    
    var strApiUnblockOuts = ""
    var strApiFreepayPayment = ""
    var strApiRetryPayment = ""
    var apiHitCount = 0
    
    var outsPaymentObject = [OutsInvoiceObj]()
    var strCin = ""
    var reasonOfFailed = "none"
    var itemArr = [[String: Any]]()
    var strCurrDate = ""

    var intVerifyPayableAmount = Int()
    var intVerifyTotalAmount = Int()
    var intVerifySavedAmount = Int()
    
    var arrVerifySavedAmount = [Int]()
 
    var OutsPaymentRetryElementMain = [OutsPaymentRetryElement]()
    var OutsPaymentRetryObjMain = [OutsPaymentRetryObj]()
    
    var FreePayPaymentElementMain = [FreePayPaymentElement]()
    var FreePayPaymentObjMain = [FreePayPaymentObj]()
    
    @IBOutlet weak var tblOutstandingSummary: UITableView!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var lblTimer: UILabel!
    @IBOutlet weak var lblGrandTotal: UILabel!
    @IBOutlet weak var lblSavedAmountTotal: UILabel!
    @IBOutlet weak var lblDiscountAmountTotal: UILabel!
    @IBOutlet weak var lblMaxLimit: UILabel!
    
    @IBOutlet weak var btnPay: RoundButton!
    @IBOutlet weak var btnCancel: RoundButton!
    @IBOutlet weak var btnBankName: RoundButton!
    @IBOutlet weak var noDataView: NoDataView!
    
    var strBankUtrn = ""
    var strBankMaxAmount = ""
    var statusCode = 0
    var strDeviceId = ""
    
    var countdownTimer: Timer!
    var totalTime = 900
    var countDownStopped = false
    var retryOption = false
    
    var strlocalTransactionId = String()
    var strFreepayTransactionId = ""
    
    var strGrandTotal = String()
    var strSavedAmountTotal = String()
    var strDiscountAmountTotal = String()
    
    var UnblockOutstandingElementMain = [UnblockOutstandingElement]()
    
    var delegateDismiss: PopupDateDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        startTimer()
        
        self.noDataView.hideView(view: self.noDataView)
        
        let loginData =  UserDefaults.standard.value(forKey: "loginData") as? Dictionary ?? [:]
        strCin = loginData["userlogid"] as? String ?? ""
        
        let initialData =  UserDefaults.standard.value(forKey: "initialData") as? Dictionary ?? [:]
        
        // Do any additional setup after loading the view.
//        strApiUnblockOuts = "https://api.goldmedalindia.in/api/CancelFreePayTranstions"
//        strApiFreepayPayment = "https://api.goldmedalindia.in/api/PaymentFreepayRequest"
//        strApiRetryPayment = "https://api.goldmedalindia.in/api/RetryFreepayTransaction"
        
         strApiUnblockOuts = (initialData["baseApi"] as? String ?? "")+""+(initialData["cancelFreePayTranstions"] as? String ?? "")
         strApiFreepayPayment = (initialData["baseApi"] as? String ?? "")+""+(initialData["paymentFreepayRequest"] as? String ?? "")
         strApiRetryPayment = (initialData["baseApi"] as? String ?? "")+""+(initialData["retryFreepayTransaction"] as? String ?? "")
    
        
        lblGrandTotal.text = Utility.formatRupee(amount: Double(strGrandTotal)!)
        lblSavedAmountTotal.text =  Utility.formatRupee(amount: Double(strSavedAmountTotal)!)
        lblDiscountAmountTotal.text =  Utility.formatRupee(amount: Double(strDiscountAmountTotal)!)
        lblMaxLimit.text = Utility.formatRupee(amount: Double(0))
        
        self.tblOutstandingSummary.delegate = self;
        self.tblOutstandingSummary.dataSource = self;
        
       strDeviceId = UIDevice.current.identifierForVendor!.uuidString
        if(strDeviceId.isEqual("")){
            strDeviceId = "-"
        }
        
        let currDate = Date()
        var dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "dd-MM-yyyy"
        strCurrDate = dateFormatter.string(from: currDate)
        
        for i in 0...(outsPaymentObject.count-1) {
            arrVerifySavedAmount.append(Int(self.outsPaymentObject[i].savedAmount ?? "0")!)
        }


        intVerifySavedAmount = arrVerifySavedAmount.reduce(0,+)
        
        print("VERIFY AMOUNT  - - - - ",Int(strDiscountAmountTotal) ,"- - - - -", intVerifyPayableAmount,"::::::::",Int(strSavedAmountTotal) ,"- - - - -", intVerifySavedAmount)
        
        Analytics.setScreenName("OUTSTANDING SUMMARY SCREEN", screenClass: "OutstandingSummaryViewController")
//        SQLiteDB.instance.addAnalyticsData(ScreenName: "OUTSTANDING SUMMARY SCREEN", ScreenId: Int64(GlobalConstants.init().OUTSTANDING_PAYMENT_SUMMARY))

//        if((Int(strDiscountAmountTotal)! != intVerifyPayableAmount) || (Int(strSavedAmountTotal)! != intVerifySavedAmount)){
//            reasonOfFailed = "RatesDontMatch"
//            apiUnblockOutstanding()
//        }
     
    }
    
    
    @IBAction func clicked_bankName(_ sender: UIButton) {
        let sb = UIStoryboard(name: "BankDetailPicker", bundle: nil)
        let popup = sb.instantiateInitialViewController() as? BankDetailPickerController
        popup?.delegate = self
        self.present(popup!, animated: true)
    }
    
    func updateBankList(value: String, utrn: String, amount: String) {
        strBankUtrn = utrn
        btnBankName.setTitle(value, for: .normal)
        strBankMaxAmount = amount
        
        lblMaxLimit.text = Utility.formatRupee(amount: Double(strBankMaxAmount ?? "0")!)
    }
    
    
    func startTimer() {
        lblTimer.textColor = UIColor.black
        countdownTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
        countDownStopped = false
    }
    
    @objc func updateTime() {
        
        lblTimer.text = "\(timeFormatted(totalTime))"
        
        if totalTime != 0 {
            totalTime -= 1
        } else {
           
            if (Utility.isConnectedToNetwork()) {
                 reasonOfFailed = "CountdownTimerLimitExceeded"
                apiUnblockOutstanding()
            }
            else{
                var alert = UIAlertView(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", delegate: nil, cancelButtonTitle: "OK")
                alert.show()
            }
            
            
            endTimer()
        }
    }
    
    func endTimer() {
        
        countdownTimer.invalidate()
        countDownStopped = true
        
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    func timeFormatted(_ totalSeconds: Int) -> String {
        let seconds: Int = totalSeconds % 60
        let minutes: Int = (totalSeconds / 60) % 60
        //     let hours: Int = totalSeconds / 3600
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    
    // - -  - - verify freepay otp on click of pay  - - - - - - - -
    @IBAction func clicked_summaryPay(_ sender: UIButton) {
        
        if(!strBankUtrn.elementsEqual("")){
            if (Utility.isConnectedToNetwork()) {
                print("AMOUNT - - - - ",strBankMaxAmount," - - - ",strDiscountAmountTotal)
                if(Double(strBankMaxAmount ?? "0")! >= Double(strDiscountAmountTotal ?? "0")!)
                {
                    if(retryOption){
                        apiRetryOutsPayment()
                    }else{
                         apiFreepayPayment()
                    }
                   
                }else{
                    var alert = UIAlertView(title: "Invalid", message: "Your balance is \(strBankMaxAmount).", delegate: nil, cancelButtonTitle: "OK")
                    alert.show()
                }
            }
            else{
                var alert = UIAlertView(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", delegate: nil, cancelButtonTitle: "OK")
                alert.show()
            }
        }else{
            var alert = UIAlertView(title: "SELECT BANK", message: "Make sure you select a bank", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
        }
    }
    
    // - - - - - hit local unblock api - - - - - - - -
    @IBAction func clicked_summaryCancel(_ sender: UIButton) {
        
        let alertCancel = UIAlertController(title: "CANCEL TRANSACTION", message: "Are you sure you want to cancel transaction??", preferredStyle: .alert)
        
        alertCancel.addAction(UIAlertAction(title: "OK", style: .default, handler: { (alertAction) -> Void in
            if (Utility.isConnectedToNetwork()) {
                self.reasonOfFailed = "userClickedCancel"
                self.apiUnblockOutstanding()
            }
            else{
                var alert = UIAlertView(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", delegate: nil, cancelButtonTitle: "OK")
                alert.show()
            }
        }))
        
        
        alertCancel.addAction(UIAlertAction(title: "CANCEL", style: .default, handler: { (alertAction) -> Void in
            
        }))
        
        
        
        self.present(alertCancel, animated: true, completion: nil)
      
    }
    
    
    // - - -  - - - - - - API to unblock outstanding details - - - -  - - - - - - -- - -
    func apiUnblockOutstanding() {
         self.noDataView.showTransparentView(view: self.noDataView, from: "LOADER")
        
         apiHitCount += 1
        
        let json: [String: Any] = ["CIN":strCin,"ClientSecret":"ClientSecret","transactionid":strlocalTransactionId,"reasonoffailed":reasonOfFailed]
        
        print("apiUnblockOutstanding local----",json)
        
        DataManager.shared.makeAPICall(url: strApiUnblockOuts, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            DispatchQueue.main.async {
                do {
                    self.UnblockOutstandingElementMain = try JSONDecoder().decode([UnblockOutstandingElement].self, from: data!)
                    
                    let result = self.UnblockOutstandingElementMain[0].result
                    
                    if(result ?? false){
                        var alert = UIAlertView(title: "Success", message: "Outstanding payment is successfully cancelled", delegate: nil, cancelButtonTitle: "OK")
                        alert.show()
                        
                        self.endTimer()
                     
                    }else{
                        var alert = UIAlertView(title: "Error", message: "Something went wrong", delegate: nil, cancelButtonTitle: "OK")
                        alert.show()
                        
                        if(self.apiHitCount > 1){
                           self.endTimer()
                        }
                      
                    }
                    self.noDataView.hideView(view: self.noDataView)
                } catch let errorData {
                    self.noDataView.hideView(view: self.noDataView)
                    
                    print(errorData.localizedDescription)
                    
                    var alert = UIAlertView(title: "Error", message: "Something went wrong", delegate: nil, cancelButtonTitle: "OK")
                    alert.show()
                    
                    if(self.apiHitCount > 1){
                        self.endTimer()
                    }
                    
                }
                
            }
            
        }) { (Error) in
            print(Error?.localizedDescription)
           self.noDataView.hideView(view: self.noDataView)
            if(self.apiHitCount > 1){
                 self.endTimer()
            }
        }
        
    }
    
    
    // - - -  - - - - - - API to confirm payment to freepay   - - - -  - - - - - - -- - -
    func apiFreepayPayment() {
        retryOption = true
        
       self.noDataView.showTransparentView(view: self.noDataView, from: "LOADER")
        
        let json: [String: Any] =  ["CIN":strCin,"transactionid":strlocalTransactionId,"payBankCode":strBankUtrn,"ClientSecret":"clientsecret"]
        
        print("API FREEPAY PAYMENT - - - - -",json)
        
        let manager =  DataManager.shared
        
        manager.makeAPICall(url: strApiFreepayPayment, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            
            do {
                 UIApplication.shared.endIgnoringInteractionEvents()
                
                self.FreePayPaymentElementMain = try JSONDecoder().decode([FreePayPaymentElement].self, from: data!)
                self.FreePayPaymentObjMain = self.FreePayPaymentElementMain[0].data
                
                let result = self.FreePayPaymentElementMain[0].result
                
                let mobileNo = self.FreePayPaymentObjMain[0].mobile ?? ""
                let emailId = self.FreePayPaymentObjMain[0].email ?? ""
                
                if(result ?? false){
                    self.countdownTimer.invalidate()
                    self.countDownStopped = true
                    
                    weak var pvc = self.presentingViewController
                    self.dismiss(animated: false, completion: {
                        let vcOutstandingPaymentRegistration  = self.storyboard?.instantiateViewController(withIdentifier: "OutstandingPaymentRegistration") as! OutstandingPaymentOtpController
                        vcOutstandingPaymentRegistration.callFrom = "FreepayPayment"
                        vcOutstandingPaymentRegistration.strMobileNumber = mobileNo
                        vcOutstandingPaymentRegistration.strEmailid = emailId
                        vcOutstandingPaymentRegistration.localTrxId = (self.strlocalTransactionId ?? "-")!
                        pvc?.present(vcOutstandingPaymentRegistration, animated: false, completion: nil)
                        
                    })
                }else{
                    var alert = UIAlertView(title: "Try again!!", message: "Something went wrong", delegate: nil, cancelButtonTitle: "OK")
                    alert.show()
                 
                }
                self.noDataView.hideView(view: self.noDataView)
                
            } catch let errorData {
                print(errorData.localizedDescription)
                
                var alert = UIAlertView(title: "Error", message: "Something went wrong", delegate: nil, cancelButtonTitle: "OK")
                alert.show()
                
                self.endTimer()
               self.noDataView.hideView(view: self.noDataView)
                
            }
        }) { (Error) in
            print(Error?.localizedDescription)
            
            var alert = UIAlertView(title: "Error", message: "Something went wrong", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
            
            self.endTimer()
          self.noDataView.hideView(view: self.noDataView)
            
        }
        
    }
  
    
    
    // - - - - - - - - retry for outstanding payment - - - -  - - - - -
    func apiRetryOutsPayment(){
        
       self.noDataView.showTransparentView(view: self.noDataView, from: "LOADER")
        
        let json: [String: Any] =  ["CIN":strCin,"ClientSecret":"ClientSecret","transactionid":strlocalTransactionId]
        
        print("RETRY OUTS PAYMENT - - - - -",json)
        
        let manager =  DataManager.shared
        
        manager.makeAPICall(url: strApiRetryPayment, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            
            do {
                self.OutsPaymentRetryElementMain = try JSONDecoder().decode([OutsPaymentRetryElement].self, from: data!)
                
                let result = self.OutsPaymentRetryElementMain[0].result
                
                if(result ?? false){
                    self.OutsPaymentRetryObjMain = self.OutsPaymentRetryElementMain[0].data!
                    
                    let newTransactionId = self.OutsPaymentRetryObjMain[0].newtransactionid
                    
                    self.strlocalTransactionId = (newTransactionId ?? "-")!
                    
                    self.apiFreepayPayment()
                }else{
                   self.endTimer()
                }
                
                self.noDataView.hideView(view: self.noDataView)
                
            } catch let errorData {
                print(errorData.localizedDescription)
                
                self.endTimer()
                
              self.noDataView.hideView(view: self.noDataView)
                
            }
        }) { (Error) in
            print(Error?.localizedDescription)
            
            self.endTimer()
            
          self.noDataView.hideView(view: self.noDataView)
            
        }
        
    }
    
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.outsPaymentObject.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SummaryPaymentCell", for: indexPath) as! SummaryOutsPaymentCell
        
        cell.lblSlno.text = String(indexPath.row + 1)
        cell.lblInvoiceId.text = self.outsPaymentObject[indexPath.row].invoiceId ?? "-"
        cell.lblSavedAmount.text = Utility.formatRupee(amount: Double(self.outsPaymentObject[indexPath.row].savedAmount ?? "0")!)
        cell.lblTotalAmount.text = Utility.formatRupee(amount: Double(self.outsPaymentObject[indexPath.row].enteredAmount ?? "0")!)
        cell.lblPayableAmount.text = Utility.formatRupee(amount: Double(self.outsPaymentObject[indexPath.row].discountedAmount ?? "0")!)
        cell.lblSavedPercent.text = (self.outsPaymentObject[indexPath.row].per ?? "0")! + "%"
        
        return cell
    }
    
}
