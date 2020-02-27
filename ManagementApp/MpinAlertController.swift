//
//  MpinAlertController.swift
//  DealorsApp
//
//  Created by Goldmedal on 5/23/19.
//  Copyright © 2019 Goldmedal. All rights reserved.
//

import UIKit
import SVPinView

class MpinAlertController: UIViewController {
    
    @IBOutlet weak var btnCheck: UIButton!
    @IBOutlet weak var btnForgot: UIButton!
    @IBOutlet weak var vwOtpMain: SVPinView!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var mpin = ""
    var CheckMpinApi = ""
    var strCin = ""
    var mPinAttempts = Int()
    
    var validateCIN = [ValidateCINElement]()
    var validateCINObj = [ValidateCinData]()
  
    
    var MpinElementMain = [CheckMpinElement]()
    var MpinDataMain = [CheckMpinData]()
    var serverTime = String()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.configurePinView()
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
        self.mpin = pin
     //   showAlert(title: "Success", message: "The Pin entered is \(pin)")
        if (Utility.isConnectedToNetwork()) {
           self.apiCheckMpin()
        }else{
            var alert = UIAlertView(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
        
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                exit(0)
            }
        }
    }
    
    func dismissPopup(){
        let rootViewController = appDelegate.window!.rootViewController as! UINavigationController
        rootViewController.dismiss(animated: true, completion: nil)
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
    
    
    // - - - - - API to generate opt request for mpin  change - -  - - - --
    func apiNewUser(){
        ViewControllerUtils.sharedInstance.showLoader()
        
        let loginData =  UserDefaults.standard.value(forKey: "loginData") as? Dictionary ?? [:]
        let initialData =  UserDefaults.standard.value(forKey: "initialData") as? Dictionary ?? [:]
        var newUserApi = (initialData["baseApi"] as? String ?? "")+""+(initialData["validateCIN"] as? String ?? "")
        
        if(!loginData.isEmpty){
            strCin = loginData["userlogid"] as? String ?? ""
        }
        
        let rootViewController = appDelegate.window!.rootViewController as! UINavigationController
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        let json: [String: Any] =
            ["CIN":strCin,"Category":UserDefaults.standard.value(forKey: "userCategory") as! String,"ClientSecret":"sgupta"]
        
        let manager =  DataManager.shared
        
        manager.makeAPICall(url: newUserApi, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            
            do {
                self.validateCIN = try JSONDecoder().decode([ValidateCINElement].self, from: data!)
                self.validateCINObj  = self.validateCIN[0].data
                
                let isSuccess = (self.validateCIN[0].result ?? false)!
                if isSuccess
                {
                    let vcOtp = rootViewController.storyboard?.instantiateViewController(withIdentifier: "OtpScreen") as! OtpController
                    vcOtp.callFrom = "ForgotMpin"
                    vcOtp.strEmailid = self.validateCINObj[0].email ?? ""
                    vcOtp.strMobileNumber = self.validateCINObj[0].mobile ?? ""
                    vcOtp.strCin = self.strCin
                    
                    rootViewController.pushViewController(vcOtp, animated: true)
                    rootViewController.dismiss(animated: true, completion: nil)
                }
                
                ViewControllerUtils.sharedInstance.removeLoader()
            } catch let errorData {
                ViewControllerUtils.sharedInstance.removeLoader()
                print(errorData.localizedDescription)
                var alert = UIAlertView(title: "Server Error", message: "Data not available. Please try again later !!", delegate: nil, cancelButtonTitle: "OK")
                alert.show()
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    exit(0)
                }
            }
        }) { (Error) in
            print(Error?.localizedDescription)
            ViewControllerUtils.sharedInstance.removeLoader()
            var alert = UIAlertView(title: "Server Error", message: "Server Error. Please try again later !!", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                exit(0)
            }
        }
    }
    
    
    //  - - - - - - - API to check if Mpin is valid or not - - - - - --  - - - -
    func apiCheckMpin(){
      
        let rootViewController = appDelegate.window!.rootViewController as! UINavigationController
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let loginData =  UserDefaults.standard.value(forKey: "loginData") as? Dictionary ?? [:]
        if(!loginData.isEmpty){
            strCin = loginData["userlogid"] as? String ?? ""
        }
        
        var DeviceId = UIDevice.current.identifierForVendor!.uuidString
        if(DeviceId.isEqual("")){
            DeviceId = "-"
        }
        
        let initialData =  UserDefaults.standard.value(forKey: "initialData") as? Dictionary ?? [:]
        var checkMpinApi = (initialData["baseApi"] as? String ?? "")+""+(initialData["mpinchecks"] as? String ?? "")
      
        let json: [String: Any] =  ["CIN":strCin,
                                    "ClientSecret":"ScreenId",
                                    "category":UserDefaults.standard.value(forKey: "userCategory") as! String,
                                    "newmpin":self.mpin,
                                    "deviceId":DeviceId,
                                    "appid":3]
        
        print("CHECK MPIN GLOBAL - - - - -",json)
        print("APIURL \(checkMpinApi)")
        let manager =  DataManager.shared
        
        manager.makeAPICall(url: checkMpinApi, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            
            DispatchQueue.main.async {
                do {
                    self.MpinElementMain = try JSONDecoder().decode([CheckMpinElement].self, from: data!)
                    self.MpinDataMain = (self.MpinElementMain[0].data ?? nil)!
                    
                    var isBlock = false
                    
                    if(self.MpinDataMain != nil){
                        isBlock = (self.MpinDataMain[0].isBlock ?? false)!
                    }
                    
                    if(isBlock){
                        var alert = UIAlertView(title: "BLOCKED", message: "Your account is blocked temporarily!!", delegate: nil, cancelButtonTitle: "OK")
                        alert.show()
                    }else if                                      (self.MpinDataMain[0].isForcedLogout!){
                        print("Logout\n", terminator: "")
                        UserDefaults.standard.removeObject(forKey: "mpinAttempts")
                        UserDefaults.standard.removeObject(forKey: "serverTime")
                        
                        let loginData = UserDefaults.standard
                        loginData.removeObject(forKey: "loginData")
                        
                        let vcLogin = mainStoryboard.instantiateViewController(withIdentifier: "LoginScreen") as! LoginController
                        rootViewController.pushViewController(vcLogin, animated: false)
                        rootViewController.dismiss(animated: true, completion: nil)
                    }else{
                        if(self.MpinElementMain[0].result ?? false){
                            //                            var alert = UIAlertView(title: "Success", message: "Mpin verified successfully!!!", delegate: nil, cancelButtonTitle: "OK")
                            //                            alert.show()
                            UserDefaults.standard.removeObject(forKey: "mpinTime")
                            
                            var prevDate = Date()
                            UserDefaults.standard.set(prevDate, forKey:"mpinTime")
                            print("saved date rrr - - - ",UserDefaults.standard.object(forKey: "mpinTime") as? Date ?? nil)
                            
                              self.dismissPopup()
                        }else{
                            self.serverTime = (UserDefaults.standard.object(forKey: "serverTime") as? String ?? "")
                            
                            if(self.serverTime.elementsEqual("") && (self.MpinElementMain[0].servertime ?? nil)! != nil){
                                UserDefaults.standard.set(self.MpinElementMain[0].servertime!, forKey: "serverTime")
                                self.serverTime = (UserDefaults.standard.object(forKey: "serverTime") as? String ?? nil)!
                            }
                            
                            if(!(self.MpinElementMain[0].servertime ?? "")!.isEmpty){
                                if(self.isBlockRemoved(prevServerTime: self.serverTime, newServerTime: self.MpinElementMain[0].servertime!) ?? false){
                                    UserDefaults.standard.removeObject(forKey: "mpinAttempts")
                                    UserDefaults.standard.removeObject(forKey: "serverTime")
                                    
                                    self.serverTime = (UserDefaults.standard.object(forKey: "serverTime") as? String ?? "")
                                    
                                    if(self.serverTime.elementsEqual("") && (self.MpinElementMain[0].servertime ?? nil)! != nil){
                                        UserDefaults.standard.set(self.MpinElementMain[0].servertime!, forKey: "serverTime")
                                        self.serverTime = (UserDefaults.standard.object(forKey: "serverTime") as? String ?? nil)!
                                    }
                                }
                            }
                            
                            self.mPinAttempts = UserDefaults.standard.object(forKey: "mpinAttempts") as? Int ?? -1
                            
                            if(self.mPinAttempts == -1){
                                self.mPinAttempts = 2
                            }
                            
                            UserDefaults.standard.set(self.mPinAttempts - 1, forKey: "mpinAttempts")
                            
                            print("mpinattempts - - - - - -",self.mPinAttempts)
                            if(self.mPinAttempts > 0){
                                var alertAttempt = UIAlertView(title: "Failed", message: "Entered Mpin is Wrong!! You have \(String(self.mPinAttempts)+" attempt left")", delegate: nil, cancelButtonTitle: nil)
                                alertAttempt.show()
                                
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                    alertAttempt.dismiss(withClickedButtonIndex: 0, animated: true)
                                    if(!self.strCin.isEmpty){
//                                        self.appDelegate.checkMpin()
//                                        self.dismissPopup()
                                        self.clearPin()
                                        
                                   //     self.apiCheckMpin()
                                    }
                                }
                            }
                            else if(self.mPinAttempts == 0){
                                var alertBlocked = UIAlertView(title: "Blocked", message: "You are blocked temporarily!! Please try again after sometime", delegate: nil, cancelButtonTitle: nil)
                                alertBlocked.show()
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                    alertBlocked.dismiss(withClickedButtonIndex: 0, animated: true)
                                    UserDefaults.standard.removeObject(forKey: "mpinAttempts")
                                    UserDefaults.standard.removeObject(forKey: "serverTime")
                                    
                                    let loginData = UserDefaults.standard
                                    loginData.removeObject(forKey: "loginData")
                                    
                                    let vcLogin = mainStoryboard.instantiateViewController(withIdentifier: "LoginScreen") as! LoginController
                                    rootViewController.pushViewController(vcLogin, animated: false)
                                    rootViewController.dismiss(animated: true, completion: nil)
                                }
                            }
                            
                        }
                    }
                    
                }
                catch let errorData {
                    var alert = UIAlertView(title: "Invalid", message: "Mpin entered is not valid", delegate: nil, cancelButtonTitle: "OK")
                    alert.show()
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        exit(0)
                    }
                    print(errorData.localizedDescription)
                }
                
            }
            
        }) { (Error) in
            var alert = UIAlertView(title: "Server Error", message: "Server Error. Please try again later !!", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                exit(0)
            }
            print(Error?.localizedDescription)
        }
        
    }
    
    
    func isBlockRemoved(prevServerTime:String,newServerTime:String) -> Bool?{
        var isBlocked = false
        
        var prevServerDate = Date()
        var newServerDate = Date()
        
        var dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy HH:mm:ss"
        
        prevServerDate = (dateFormatter.date(from: prevServerTime) ?? nil)!
        newServerDate = (dateFormatter.date(from: newServerTime) ?? nil)!
        
        prevServerDate = prevServerDate.addingTimeInterval(3600)
        
        if prevServerDate < newServerDate {
            print("Block is removed")
            isBlocked = true
        }else{
            print("User is still blocked")
            isBlocked = false
        }
        
        return (isBlocked ?? false)
    }
    
    
    @IBAction func clicked_forgotMpin(_ sender: UIButton) {
        if (Utility.isConnectedToNetwork()) {
            self.apiNewUser()
            dismissPopup()
        }else{
            var alert = UIAlertView(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
        }
    }
    
}
