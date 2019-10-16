//
//  OutstandingPaymentOtpController.swift
//  DealorsApp
//
//  Created by Goldmedal on 2/9/19.
//  Copyright © 2019 Goldmedal. All rights reserved.
//

import UIKit
import FirebaseAnalytics
import SVPinView

class OutstandingPaymentOtpController: UIViewController {
    
    @IBOutlet weak var lblEmailId: UILabel!
    @IBOutlet weak var lblContactNo: UILabel!
    @IBOutlet weak var btnVerify: UIButton!
    @IBOutlet weak var btnResendOtp: UIButton!
    @IBOutlet weak var lblTimer: UILabel!
    @IBOutlet weak var vwOtpMain: SVPinView!
    @IBOutlet weak var lblOtpHeader: UILabel!
    @IBOutlet weak var noDataView: NoDataView!
    
    var dueSequence = Bool()
    
    var outsPaymentRegVerifyApi = ""
    var outsPaymentOtpVerifyApi = ""
    var outsPaymentOtpRecheckApi = ""
    
    var outsPaymentRegRetryApi = ""
    var outsPaymentOtpRetryApi = ""
    
    var strApiUnblockOuts = ""
    
    var callFrom = String()
    
    var reasonOfFailed = "none"
    var strStatusCode = ""
    
    var apiHitCount = 0
    
    var VerifyRegistrationOtpMain = [VerifyRegistrationOtpLocal]()
    var VerifyRegistrationOtpObjMain = [VerifyRegistrationOtpLocalObj]()
    
    var RegistrationElementMain = [GetOtpFreePayElement]()
    var RegistrationObjMain = [GetOtpFreePayObj]()
    
    var UnblockOutstandingElementMain = [UnblockOutstandingElement]()
    
    var countdownTimer: Timer!
    var totalTime = 360
    var countDownStopped = false
    var strCin = ""
    
    var freepayTrxId = String()
    var localTrxId = String()
    
    var strEmailid = String()
    var strMobileNumber = String()
    
    var countdownTimerForResend: Timer!
    var totalTimeForResend = 120
    var countDownStoppedForResend = false
    
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let initialData =  UserDefaults.standard.value(forKey: "initialData") as? Dictionary ?? [:]
        
        let loginData =  UserDefaults.standard.value(forKey: "loginData") as? Dictionary ?? [:]
        strCin = loginData["userlogid"] as? String ?? ""
        
        //        outsPaymentRegVerifyApi = "https://api.goldmedalindia.in/api/VerifyFreePayOTP"
        //        outsPaymentOtpVerifyApi = "https://api.goldmedalindia.in/api/ConfirmPaymentRequest"
        //
        //        outsPaymentOtpRetryApi = //"https://api.goldmedalindia.in/api/GetResendPaymentRequestOTP"
        //        outsPaymentRegRetryApi = "https://api.goldmedalindia.in/api/GetResendFreePayOTP"
        
        outsPaymentRegVerifyApi = (initialData["baseApi"] as? String ?? "")+""+(initialData["verifyFreePayOTP"] as? String ?? "")
        outsPaymentOtpVerifyApi = (initialData["baseApi"] as? String ?? "")+""+(initialData["confirmPaymentRequest"] as? String ?? "")
        outsPaymentOtpRetryApi = (initialData["baseApi"] as? String ?? "")+""+(initialData["resendPaymentRequestOTP"] as? String ?? "")
        outsPaymentRegRetryApi = (initialData["baseApi"] as? String ?? "")+""+(initialData["resendFreePayOTP"] as? String ?? "")
        strApiUnblockOuts = (initialData["baseApi"] as? String ?? "")+""+(initialData["cancelFreePayTranstions"] as? String ?? "")
         outsPaymentOtpRecheckApi = (initialData["baseApi"] as? String ?? "")+""+(initialData["freePayFailedTranstions"] as? String ?? "")
     //   outsPaymentOtpRecheckApi = "https://test2.goldmedalindia.in/api/CheckFreePayFailedTranstions"
        
        var strEmail = ""
        var strMobile = ""
        
        var chars : Array<Character> = Array()
        var arr : [Substring] = []
        
        if (strEmailid.count > 0 && strEmailid.range(of:"@") != nil) {
            arr =  strEmailid.split(separator: "@")
            chars = Array(arr[0])
        }
        
        if(chars.count>4){
            
            for i in 2..<chars.count-2 {
                
                chars[i] = "*"
            }
            
            var Text:String = String (chars)
            Text.append("@")
            Text.append(String (arr[1]))
            
            lblEmailId.text = Text
            
        }else{
            lblEmailId.text = strEmailid
        }
        
        if(strMobileNumber.count > 5){
            let startMobile = strMobileNumber.startIndex;
            let endMobile = strMobileNumber.index(strMobileNumber.startIndex, offsetBy: 6);
            strMobile = strMobileNumber.replacingCharacters(in: startMobile..<endMobile, with: "******")
        }else{
            strMobile = strMobileNumber
        }
        lblContactNo.text = strMobile
        
        
        
        self.noDataView.hideView(view: self.noDataView)
        
        if(callFrom.elementsEqual("FreepayPayment")){
            lblOtpHeader.text = "OTP PAYMENT VERIFICATION"
            
//            SQLiteDB.instance.addAnalyticsData(ScreenName: "OTP OUTSTANDING PAYMENT SCREEN", ScreenId: Int64(GlobalConstants.init().OUTSTANDING_OTP_PAYMENT))
            
            Analytics.setScreenName("OTP OUTSTANDING PAYMENT SCREEN", screenClass: "OutstandingPaymentOtpController")
        }else{
            lblOtpHeader.text = "ONE TIME PAYMENT REGISTRATION"
            
//            SQLiteDB.instance.addAnalyticsData(ScreenName: "OTP OUTSTANDING REGISTRATION SCREEN", ScreenId: Int64(GlobalConstants.init().OUTSTANDING_OTP_REGISTRATION))
            
            Analytics.setScreenName("OTP OUTSTANDING REGISTRATION SCREEN", screenClass: "OutstandingPaymentOtpController")
        }
        
        startTimer()
        
        startTimerForResend()
        
        configurePinView()
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: .UIApplicationDidEnterBackground, object: nil)
         notificationCenter.addObserver(self, selector: #selector(appMovedToForeground), name: .UIApplicationWillEnterForeground, object: nil)
        
    }

    @objc func appMovedToBackground() {
        print("App moved to background!")
       
    }
    
    @objc func appMovedToForeground() {
        print("App moved to foreground!")
        
    }
    
    func configurePinView() {
        
        vwOtpMain.pinLength = 4
        vwOtpMain.interSpace = 10
        vwOtpMain.textColor = UIColor.black
        vwOtpMain.borderLineColor = UIColor.white
        vwOtpMain.activeBorderLineColor = UIColor.white
        vwOtpMain.borderLineThickness = 4
        vwOtpMain.shouldSecureText = false
        vwOtpMain.allowsWhitespaces = false
        vwOtpMain.style = .box
        vwOtpMain.fieldBackgroundColor = UIColor.gray.withAlphaComponent(0.3)
        vwOtpMain.activeFieldBackgroundColor = UIColor.gray.withAlphaComponent(0.5)
        vwOtpMain.fieldCornerRadius = 10
        vwOtpMain.activeFieldCornerRadius = 10
        vwOtpMain.placeholder = ""
        vwOtpMain.becomeFirstResponderAtIndex = 0
        
        vwOtpMain.font = UIFont.systemFont(ofSize: 20)
        vwOtpMain.keyboardType = .numberPad
        vwOtpMain.pinInputAccessoryView = { () -> UIView in
            let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
            doneToolbar.barStyle = UIBarStyle.default
            let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
            let done: UIBarButtonItem  = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.done, target: self, action: #selector(dismissKeyboard))
            
            var items = [UIBarButtonItem]()
            items.append(flexSpace)
            items.append(done)
            
            doneToolbar.items = items
            doneToolbar.sizeToFit()
            return doneToolbar
        }()
        
        vwOtpMain.didFinishCallback = didFinishEnteringPin(pin:)
        vwOtpMain.didChangeCallback = { pin in
            print("The entered pin is \(pin)")
        }
    }
    
    @objc func dismissKeyboard() {
        self.view.endEditing(false)
    }
    
    
    @IBAction func clearPin() {
        vwOtpMain.clearPin()
    }
    
    @IBAction func pastePin() {
        guard let pin = UIPasteboard.general.string else {
            showAlert(title: "Error", message: "Clipboard is empty")
            return
        }
        vwOtpMain.pastePin(pin: pin)
    }
    
    @IBAction func toggleStyle() {
        var nextStyle = vwOtpMain.style.rawValue + 1
        if nextStyle == 3 {nextStyle = 0}
        let style = SVPinViewStyle(rawValue: nextStyle)!
        switch style {
        case .none:
            vwOtpMain.fieldBackgroundColor = UIColor.white.withAlphaComponent(0.3)
            vwOtpMain.activeFieldBackgroundColor = UIColor.white.withAlphaComponent(0.5)
            vwOtpMain.fieldCornerRadius = 15
            vwOtpMain.activeFieldCornerRadius = 15
            vwOtpMain.style = style
        case .box:
            vwOtpMain.activeBorderLineThickness = 4
            vwOtpMain.fieldBackgroundColor = UIColor.clear
            vwOtpMain.activeFieldBackgroundColor = UIColor.clear
            vwOtpMain.fieldCornerRadius = 0
            vwOtpMain.activeFieldCornerRadius = 0
            vwOtpMain.style = style
        case .underline:
            vwOtpMain.activeBorderLineThickness = 4
            vwOtpMain.fieldBackgroundColor = UIColor.clear
            vwOtpMain.activeFieldBackgroundColor = UIColor.clear
            vwOtpMain.fieldCornerRadius = 0
            vwOtpMain.activeFieldCornerRadius = 0
            vwOtpMain.style = style
        }
        clearPin()
    }
    
    func didFinishEnteringPin(pin:String) {
        //  showAlert(title: "Success", message: "The Pin entered is \(pin)")
    }
    
    // MARK: Helper Functions
    func showAlert(title:String, message:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func setGradientBackground(view:UIView, colorTop:UIColor, colorBottom:UIColor) {
        for layer in view.layer.sublayers! {
            if layer.name == "gradientLayer" {
                layer.removeFromSuperlayer()
            }
        }
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [colorTop.cgColor, colorBottom.cgColor]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.frame = view.bounds
        gradientLayer.name = "gradientLayer"
        view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    
    // - - - - - Timer for 6 minutes main - - - -  - - -
    func startTimer() {
        lblTimer.textColor = UIColor.black
        countdownTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
        countDownStopped = false
    }
    
    @objc func updateTime() {
        
        lblTimer.text = "\(timeFormatted(totalTime))"
        
        if totalTime != 0 {
            totalTime -= 1
            
            if(callFrom.elementsEqual("FreepayPayment") && totalTime <= 120){
                self.btnVerify.isUserInteractionEnabled = false
                self.btnVerify.backgroundColor = UIColor.lightGray
                self.btnResendOtp.isHidden = true
            }
            
        } else {
            
            // - - - - - count down exceeded for registration - - - - -  - - - -
            //            if(callFrom.elementsEqual("FreepayPayment")){
            //                if (Utility.isConnectedToNetwork()) {
            //                    reasonOfFailed = "CountdownTimerLimitExceeded"
            //                   // self.apiUnblockOutstanding()
            //                }
            //                else{
            //                    var alert = UIAlertView(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", delegate: nil, cancelButtonTitle: "OK")
            //                    alert.show()
            //                }
            //            }
            
            var alert = UIAlertView(title: "OTP Time Out", message: "Please check your status after 30 minutes", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
            
            endTimer()
        }
    }
    
    func endTimer() {
        //        countdownTimer.invalidate()
        //        countDownStopped = true
        //        self.dismiss(animated: true, completion: nil)
        
        self.countdownTimer.invalidate()
        self.countDownStopped = true
        
        if(callFrom.elementsEqual("FreepayPayment")){
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                weak var pvc = self.presentingViewController
                self.dismiss(animated: false, completion: {
                    let vcOutsPaymentSummaryListController =  self.storyboard?.instantiateViewController(withIdentifier: "OutsPaymentSummaryListController") as! OutsPaymentSummaryListController
                    vcOutsPaymentSummaryListController.callFrom = "otp"
                    
                    let navVc = UINavigationController(rootViewController: vcOutsPaymentSummaryListController)
                    pvc?.present(navVc, animated: true, completion: nil)
                })
            }
        }else{
            self.dismiss(animated: true, completion: nil)
        }
        
        
    }
    
    
    
    func timeFormatted(_ totalSeconds: Int) -> String {
        let seconds: Int = totalSeconds % 60
        let minutes: Int = (totalSeconds / 60) % 60
        //     let hours: Int = totalSeconds / 3600
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    
    
    // - - -  - -  Resend timer for 120 seconds  - - - - --  --  -
    func startTimerForResend() {
        countdownTimerForResend = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimeForResend), userInfo: nil, repeats: true)
        countDownStoppedForResend = false
    }
    
    @objc func updateTimeForResend() {
        
        if totalTimeForResend != 0 {
            totalTimeForResend -= 1
        } else {
            btnResendOtp.isHidden = false
            endTimerForResend()
        }
    }
    
    
    func endTimerForResend() {
        countdownTimerForResend.invalidate()
        countDownStoppedForResend = true
        
    }
    
    
    // - - -  - -  Logic for resend otp for registration and payment for 120 seconds - - - - - -
    @IBAction func clicked_resendOtp(_ sender: UIButton) {
        print("tap working",countDownStoppedForResend)
        
        if countDownStoppedForResend
        {
            btnResendOtp.isHidden = true
            totalTimeForResend = 120
            startTimerForResend()
            
            // - - - - - hit resend otp api here  - - - - -
            if(!callFrom.elementsEqual("FreepayPayment")){
                apiRetryRegistration()
            }else{
                apiRetryPayment()
            }
        }
    }
    
    
    @IBAction func clicked_verify(_ sender: UIButton) {
        
        if(vwOtpMain.getPin().count != 4)
        {
            var alert = UIAlertView(title: nil, message: "Enter Otp", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
        }
            
        else{
            if (Utility.isConnectedToNetwork()) {
                if(callFrom.elementsEqual("FreepayPayment")){
                    self.apiVerifyOtpPayment()
                }else{
                    self.apiVerifyRegistration()
                }
                
            }else{
                var alert = UIAlertView(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", delegate: nil, cancelButtonTitle: "OK")
                alert.show()
            }
        }
        
    }
    
    
    
    // - - - - - - - - (Freepay API) Verify otp for registration freepay - - - - - - -
    func apiVerifyRegistration(){
        
        self.noDataView.showTransparentView(view: self.noDataView, from: "LOADER")
        
        var json: [String: Any]? = nil
        
        json =  ["otp": vwOtpMain.getPin(),"ClientSecret":"clientsecret","CIN":strCin]
        
        print("VERIFY FREEPAY REGISTRATION  - - - - -",json)
        
        let manager =  DataManager.shared
        
        manager.makeAPICall(url: outsPaymentRegVerifyApi, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            
            DispatchQueue.main.async  { do
            {
                UIApplication.shared.endIgnoringInteractionEvents()
                
                self.VerifyRegistrationOtpMain = try JSONDecoder().decode([VerifyRegistrationOtpLocal].self, from: data!)
                
                let message = self.VerifyRegistrationOtpMain[0].message
                
                let result = self.VerifyRegistrationOtpMain[0].result
                
                print("VERIFY FREEPAY REGISTRATION - - - -",result," - - - - ",message)
                
                if(result ?? false){
                    // - - - - - -  if registration is verified  - - - - - - - -  --
                    self.countdownTimer.invalidate()
                    self.countDownStopped = true
                    
                    weak var pvc = self.presentingViewController
                    self.dismiss(animated: false, completion: {
                        let vcOutstandingCalculationReport  = self.storyboard?.instantiateViewController(withIdentifier: "OutstandingPaymentCalculation") as! OutstandingPaymentCalculationController
                        vcOutstandingCalculationReport.maintainDueSequence = self.dueSequence
                        pvc?.present(vcOutstandingCalculationReport, animated: true, completion: nil)
                    })
                    
                }else{
                    var alert = UIAlertView(title: "Registration OTP Error", message: message, delegate: nil, cancelButtonTitle: "OK")
                    alert.show()
                    
                }
                self.noDataView.hideView(view: self.noDataView)
                
            } catch let errorData {
                print(errorData.localizedDescription)
                self.noDataView.hideView(view: self.noDataView)
                
                var alert = UIAlertView(title: "Registration OTP Error", message: "Something went wrong", delegate: nil, cancelButtonTitle: "OK")
                alert.show()
                
                }}
        }) { (Error) in
            print(Error?.localizedDescription)
            self.noDataView.hideView(view: self.noDataView)
            
            var alert = UIAlertView(title: "Error", message: "Something went wrong", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
            
        }
        
    }
    
    
    // - - - - - - - -(Freepay API) Verify otp for freepay payment - - - - - - -
    func apiVerifyOtpPayment(){
        self.noDataView.showTransparentView(view: self.noDataView, from: "LOADER")
        
        let  json =  ["CIN":strCin,"transactionid":localTrxId,"otp":vwOtpMain.getPin(),"ClientSecret":"clientsecret"]
        
        print("VERIFY OTP FREEPAY  - - - - -",json)
        
        let manager =  DataManager.shared
        
        manager.makeAPICall(url: outsPaymentOtpVerifyApi, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            
            DispatchQueue.main.async  { do
            {
                UIApplication.shared.endIgnoringInteractionEvents()
                
                self.VerifyRegistrationOtpMain = try JSONDecoder().decode([VerifyRegistrationOtpLocal].self, from: data!)
                
                let message = self.VerifyRegistrationOtpMain[0].message
                
                let result = self.VerifyRegistrationOtpMain[0].result
                
                 print("VERIFY OTP FREEPAY - - - -",result," - - - - ",message)
                
                if(result ?? false){
                    // - - - - - -  if payment is verified  - - - - - - - -  --
//                    self.countdownTimer.invalidate()
//                    self.countDownStopped = true
//
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
//                        weak var pvc = self.presentingViewController
//                        self.dismiss(animated: false, completion: {
//                            let vcOutsPaymentSummaryListController =  self.storyboard?.instantiateViewController(withIdentifier: "OutsPaymentSummaryListController") as! OutsPaymentSummaryListController
//                            vcOutsPaymentSummaryListController.callFrom = "otp"
//
//                            let navVc = UINavigationController(rootViewController: vcOutsPaymentSummaryListController)
//
//                            pvc?.present(navVc, animated: true, completion: nil)
//                        })
//                    }
                    var alert = UIAlertView(title: "Success!!!", message: message, delegate: nil, cancelButtonTitle: "OK")
                    alert.show()
                    
                    self.endTimer()
                }else{
                    var alert = UIAlertView(title: "Payment OTP Error", message: message, delegate: nil, cancelButtonTitle: "OK")
                    alert.show()
                    
                }
                
                self.noDataView.hideView(view: self.noDataView)
                
            } catch let errorData {
                print(errorData.localizedDescription)
                
                var alert = UIAlertView(title: "Payment OTP Error", message: "Something went wrong", delegate: nil, cancelButtonTitle: "OK")
                alert.show()
                self.noDataView.hideView(view: self.noDataView)
                }}
        }) { (Error) in
            print(Error?.localizedDescription)
            
            var alert = UIAlertView(title: "Error", message: "Something went wrong", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
            
            if (Utility.isConnectedToNetwork()) {
               self.apiCheckVerifyOtpPayment()
            }else{
                var alert = UIAlertView(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", delegate: nil, cancelButtonTitle: "OK")
                alert.show()
            }
           
            self.noDataView.hideView(view: self.noDataView)
            
        }
        
    }
    

    
    
    // - - - - - - - - checking(Freepay API) Verify otp for freepay payment - - - - - - -
    func apiCheckVerifyOtpPayment(){
        apiHitCount+=1
        
        self.noDataView.showTransparentView(view: self.noDataView, from: "LOADER")
        
        let  json =  ["CIN":strCin,"transactionid":localTrxId,"ClientSecret":"clientsecret"]
      
        print("RECHECK OTP FREEPAY  - - - - -",json)
        
        let manager =  DataManager.shared
        
        manager.makeAPICall(url: outsPaymentOtpRecheckApi, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            
            DispatchQueue.main.async  { do
            {
                UIApplication.shared.endIgnoringInteractionEvents()
                
                self.VerifyRegistrationOtpMain = try JSONDecoder().decode([VerifyRegistrationOtpLocal].self, from: data!)
                
                let message = self.VerifyRegistrationOtpMain[0].message
                
                let result = self.VerifyRegistrationOtpMain[0].result
                
                print("RECHECK OTP FREEPAY - - - -",result," - - - - ",message," ----- ",self.apiHitCount)
                
                if(result ?? false){
                    
                    var alert = UIAlertView(title: "Success!!!", message: message, delegate: nil, cancelButtonTitle: "OK")
                    alert.show()
                    
                     self.noDataView.hideView(view: self.noDataView)
                    
                    self.endTimer()
                }else{
                    if(self.apiHitCount < 3){
                        if (Utility.isConnectedToNetwork()) {
                            self.apiCheckVerifyOtpPayment()
                        }else{
                            var alert = UIAlertView(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", delegate: nil, cancelButtonTitle: "OK")
                            alert.show()
                        }
                    }else{
                        self.apiHitCount = 0
                        
                        var alert = UIAlertView(title: "Payment OTP Error", message: "Something went wrong", delegate: nil, cancelButtonTitle: "OK")
                        alert.show()
                        
                         self.noDataView.hideView(view: self.noDataView)
                    }
                    
//                    var alert = UIAlertView(title: "Payment OTP Error", message: message, delegate: nil, cancelButtonTitle: "OK")
//                    alert.show()
                    
                }
                
            } catch let errorData {
                print(errorData.localizedDescription)
                
                if(self.apiHitCount < 3){
                    self.apiCheckVerifyOtpPayment()
                }else{
                    
                    var alert = UIAlertView(title: "Payment OTP Error", message: "Something went wrong", delegate: nil, cancelButtonTitle: "OK")
                    alert.show()
                    
                    self.apiHitCount = 0
                    
                     self.noDataView.hideView(view: self.noDataView)
                }
                
//                var alert = UIAlertView(title: "Payment OTP Error", message: "Something went wrong", delegate: nil, cancelButtonTitle: "OK")
//                alert.show()
               
                }}
        }) { (Error) in
            print(Error?.localizedDescription)
            
            if(self.apiHitCount < 3){
                self.apiCheckVerifyOtpPayment()
            }else{
                self.apiHitCount = 0
                
                 self.noDataView.hideView(view: self.noDataView)
            }
            
//            var alert = UIAlertView(title: "Error", message: "Something went wrong", delegate: nil, cancelButtonTitle: "OK")
//            alert.show()
            
          //  self.noDataView.hideView(view: self.noDataView)
            
        }
        
    }
    
    
    // - - - - - - - - api to resend otp for freepay registration - - - - - - -
    func apiRetryRegistration(){
        
        self.noDataView.showTransparentView(view: self.noDataView, from: "LOADER")
        
        let  json =  ["CIN":strCin,"ClientSecret":"clientsecret"]
        
        print("RESEND OTP FREEPAY REG  - - - - -",json)
        
        let manager =  DataManager.shared
        
        manager.makeAPICall(url: outsPaymentRegRetryApi, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            
            DispatchQueue.main.async  { do
            {
                self.RegistrationElementMain = try JSONDecoder().decode([GetOtpFreePayElement].self, from: data!)
                self.RegistrationObjMain = self.RegistrationElementMain[0].data
                
                let message = self.RegistrationElementMain[0].message
                
                let result = self.RegistrationElementMain[0].result
                
                let isRegistered = self.RegistrationObjMain[0].isRegistered
                
                 print("RESEND OTP FREEPAY REG - - - -",result," - - - - ",message)
                
                if(result ?? false){
                    // - - - - - -  if otp is sent successfully  - - - - - - - -  --
                    //  self.apiVerifyRegistration()
                    var alert = UIAlertView(title: "Resend Registration Success", message: message, delegate: nil, cancelButtonTitle: "OK")
                    alert.show()
                    
                }else{
                    var alert = UIAlertView(title: "Resend Registration Error", message: message, delegate: nil, cancelButtonTitle: "OK")
                    alert.show()
                    
                }
                self.noDataView.hideView(view: self.noDataView)
            } catch let errorData {
                print(errorData.localizedDescription)
                self.noDataView.hideView(view: self.noDataView)
                var alert = UIAlertView(title: "Resend Registration Error", message: "Something went wrong", delegate: nil, cancelButtonTitle: "OK")
                alert.show()
                
                }}
        }) { (Error) in
            print(Error?.localizedDescription)
            self.noDataView.hideView(view: self.noDataView)
            var alert = UIAlertView(title: "Resend Registration Error", message: "Something went wrong", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
            
        }
        
    }
    
    // - - - -  - - api to resend otp for payment - -  - - - - -
    func apiRetryPayment(){
        apiHitCount = 0
        
        self.noDataView.showTransparentView(view: self.noDataView, from: "LOADER")
        
        let  json =  ["CIN":strCin,"ClientSecret":"clientsecret","transactionid":localTrxId]
        
        print("RESEND OTP FREEPAY PAYMENT  - - - - -",json)
        
        let manager =  DataManager.shared
        
        manager.makeAPICall(url: outsPaymentOtpRetryApi, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            
            DispatchQueue.main.async  { do
            {
                self.VerifyRegistrationOtpMain = try JSONDecoder().decode([VerifyRegistrationOtpLocal].self, from: data!)
                
                let message = self.VerifyRegistrationOtpMain[0].message
                
                let result = self.VerifyRegistrationOtpMain[0].result
                
                 print("RESEND OTP FREEPAY PAYMENT - - - -",result," - - - - ",message)
                
                if(result ?? false){
                    // - - - - - -  if otp is sent successfully  - - - - - - - -  --
                    //  self.apiVerifyOtpPayment()
                    var alert = UIAlertView(title: "Resend Payment Success", message: message, delegate: nil, cancelButtonTitle: "OK")
                    alert.show()
                    
                }else{
                    var alert = UIAlertView(title: "Resend Payment Error", message: message, delegate: nil, cancelButtonTitle: "OK")
                    alert.show()
                    
                }
                self.noDataView.hideView(view: self.noDataView)
            } catch let errorData {
                print(errorData.localizedDescription)
                self.noDataView.hideView(view: self.noDataView)
                var alert = UIAlertView(title: "Resend Payment Error", message: "Something went wrong", delegate: nil, cancelButtonTitle: "OK")
                alert.show()
                
                }}
        }) { (Error) in
            print(Error?.localizedDescription)
            self.noDataView.hideView(view: self.noDataView)
            var alert = UIAlertView(title: "Resend Payment Error", message: "Something went wrong", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
            
        }
        
    }
    
    
    // - - -  - - - - - - API to unblock outstanding details - - - -  - - - - - - -- - -
    func apiUnblockOutstanding() {
        self.noDataView.showTransparentView(view: self.noDataView, from: "LOADER")
        
        
        let json: [String: Any] = ["CIN":strCin,"ClientSecret":"ClientSecret","transactionid":localTrxId,"reasonoffailed":reasonOfFailed]
        
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
                        
                        self.endTimer()
                        
                    }
                    self.noDataView.hideView(view: self.noDataView)
                } catch let errorData {
                    print(errorData.localizedDescription)
                    self.noDataView.hideView(view: self.noDataView)
                    var alert = UIAlertView(title: "Error", message: "Something went wrong", delegate: nil, cancelButtonTitle: "OK")
                    alert.show()
                    
                    self.endTimer()
                    
                }
                
            }
            
        }) { (Error) in
            print(Error?.localizedDescription)
            self.noDataView.hideView(view: self.noDataView)
            self.endTimer()
            
        }
        
    }
    
    
    
}
