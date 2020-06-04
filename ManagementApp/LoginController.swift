//
//  LoginController.swift
//  DealorsApp
//
//  Created by Goldmedal on 3/26/18.
//  Copyright © 2018 Goldmedal. All rights reserved.
//

import UIKit
import FirebaseAnalytics
import CoreLocation

class LoginController: UIViewController , UITextFieldDelegate{
  
    @IBOutlet weak var edtCin: UITextField!
    @IBOutlet weak var edtPassword: UITextField!
    @IBOutlet weak var btnSignUp: UIButton!
    @IBOutlet weak var vwLoginContainer: UIView!
    @IBOutlet weak var captchaView: CaptchaView!
   
    var login = [LoginElement]()
    var loginData = [LoginData]()
    var category = [Category]()
    var categoryObj = [CategoryObj]()
    var MpinElementMain = [CheckMpinElement]()
    var MpinDataMain = [CheckMpinData]()
    
    let appDeletegate = UIApplication.shared.delegate as! AppDelegate
    var strToken = ""
    
    var mLat:Double = 0
    var mLong:Double = 0
    
    var appVersion = ""
    var osVersion = ""
    var ipAddress = ""
    var deviceId = ""
    var checkMpinApi = "https://api.goldmedalindia.in//api/mpinchecks"
    
    var loginApi=""
    var getCategoryApi = ""
    
    var lastCin = ""
    var currCin = ""
    
    let locationManager = CLLocationManager()
  
    @IBAction func onLoginClicked(_ sender: Any) {
      
        if((edtCin.text?.trimmingCharacters(in: NSCharacterSet.whitespaces).count)!  < 5)
        {
            let okAlertBtn = UIAlertAction(title: "Okay", style: .default){
                action in
            }
            let alert = UIAlertController(title: "Invalid Email", message: "Please Enter Valid Email", preferredStyle: .alert)
            alert.addAction(okAlertBtn)
            self.present(alert, animated: true){
                
            }
        }else if ((edtPassword.text?.trimmingCharacters(in: NSCharacterSet.whitespaces).count)!  == 0) {
            var alert = UIAlertView(title: nil, message: "Please Enter Password", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
        } else {
            if(captchaView.checkCaptcha()){
                if (Utility.isConnectedToNetwork()) {
                    apiGetCategory()
                    //apiLogin()
                }
                else{
                    var alert = UIAlertView(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", delegate: nil, cancelButtonTitle: "OK")
                    alert.show()
                }
            }else{
                var alert = UIAlertView(title: nil, message: "Invalid Captcha", delegate: nil, cancelButtonTitle: "OK")
                alert.show()
            }
        
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        edtCin.becomeFirstResponder()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getCategoryApi = "https://api.goldmedalindia.in/api/GetUserType"
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        locationManager.requestLocation()
        
        print("IP ADDRESS - - - - ",getIPAddress())
        
        ipAddress = (getIPAddress() ?? "-")!
        
        strToken = (appDeletegate.tokenString ?? "-")!
        if(strToken.isEqual("")){
            strToken = "-"
        }
        
        print("STR TOKEN",(strToken))
        
        deviceId = UIDevice.current.identifierForVendor!.uuidString
        if(deviceId.isEqual("")){
            deviceId = "-"
        }
      
        osVersion = UIDevice.current.systemVersion
        if(osVersion.isEqual("")){
            osVersion = "-"
        }
        
        appVersion = (Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String)!
        if(appVersion.isEqual("")){
            appVersion = "-"
        }
        
        let initialData =  UserDefaults.standard.value(forKey: "initialData") as? Dictionary ?? [:]
        loginApi = (initialData["baseApi"] as? String ?? "")+""+(initialData["validateUserDealer"] as? String ?? "")
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        Analytics.setScreenName("LOGIN SCREEN", screenClass: "LoginController")
        }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    @IBAction func clicked_newUser(_ sender: UIButton) {
       let vcNewUser = self.storyboard?.instantiateViewController(withIdentifier: "NewUserID") as! NewUserController
        vcNewUser.strHeader = "SIGN UP"
        self.navigationController!.pushViewController(vcNewUser, animated: true)
    }
    
    
    @IBAction func clicked_forgotPassword(_ sender: UIButton) {
        let vcForgotPassword = self.storyboard?.instantiateViewController(withIdentifier: "NewUserID") as! NewUserController
        vcForgotPassword.strHeader = "FORGOT PASSWORD"
        self.navigationController!.pushViewController(vcForgotPassword, animated: true)
    }
    
    
    func apiGetCategory(){
        
        let json: [String: Any] = ["userid":(edtCin.text ?? "")!,"ClientSecret":"Internal User"]
        let manager =  DataManager.shared
        print("get category \(json)")
        manager.makeAPICall(url: getCategoryApi, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            //print("get category result\(data)")
            do {
                self.category = try JSONDecoder().decode([Category].self, from: data!)
                self.categoryObj  = self.category[0].data
                _ = UIApplication.shared.delegate as! AppDelegate
                UserDefaults.standard.set(self.categoryObj[0].usertype, forKey: "userCategory")
                UserDefaults.standard.set(self.categoryObj[0].userid, forKey: "userCIN")
                //appDelegate.userCategory = self.categoryObj[0].usertype
                //appDelegate.userCIN = self.categoryObj[0].userid
                self.apiLogin()
            } catch let errorData {
                print(errorData.localizedDescription)
                ViewControllerUtils.sharedInstance.removeLoader()
                return
            }
            
        }) { (Error) in
            print(Error?.localizedDescription as Any)
            ViewControllerUtils.sharedInstance.removeLoader()
        }
        
    }
    
    
    func apiLogin(){
        ViewControllerUtils.sharedInstance.showLoader()
      
        let json: [String: Any] =  ["CIN":(edtCin.text ?? "")!,"Pushwooshid":strToken,"Category": UserDefaults.standard.value(forKey: "userCategory") as! String,"Password":(edtPassword.text ?? "")!,"ClientSecret":"sgupta","Deviceid":deviceId,"DeviceType":"Ios","AppVerion":appVersion,"OsVersion":osVersion,"Long": String(mLong),"Lat":String(mLat),"IP": ipAddress]
      
        print("LOGIN apiname \(loginApi) and Params \(json)")
        
        let manager =  DataManager.shared
        
        manager.makeAPICall(url: loginApi, params: json, method: .POST, success: { (response) in
             let data = response as? Data
            print("LOGIN result",data)
            do {
            let responseData = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers)
                
            self.login = try JSONDecoder().decode([LoginElement].self, from: data!)
                
            let isSuccess = self.login[0].result ?? false
         
            if isSuccess
            {
                let loginData = ((responseData as? Array ?? [])[0] as? Dictionary ?? [:])["data"]
                UserDefaults.standard.set(loginData, forKey: "loginData")
                print("LOGIN RESPONSE - - - - -",loginData)
                
                self.currCin = (self.login[0].data?.userlogid) ?? ""
                UserDefaults.standard.set(self.login[0].data?.slno, forKey: "userID")
                self.apiCheckMpin()
                //print("LOGIN USRID - - - - -",UserDefaults.standard.value(forKey: "userID") as! Int)
//                if let arrViewCartData = UserDefaults.standard.object(forKey: "addToCart") as? Data {
//                    let decoder = JSONDecoder()
//                    if var decodedData = try? decoder.decode([[OrderDetailData]].self, from: arrViewCartData) {
//
//                        if(decodedData.count > 0){
//
//                            if((UserDefaults.standard.value(forKey: "CartCount")) as? String != nil){
//
//                                self.lastCin = UserDefaults.standard.value(forKey: "CartCount") as! String
//                                if(self.lastCin.isEqual(self.currCin)){
//
//                                }else{
//                                     UserDefaults.standard.removeObject(forKey: "CartCount")
//                                     UserDefaults.standard.removeObject(forKey: "addToCart")
//                                }
//                            }
//                        }else{
//                            print("USER CLEAR")
//                            UserDefaults.standard.removeObject(forKey: "CartCount")
//                        }
//                    }
//                }
      
                //let vcHome = self.storyboard?.instantiateViewController(withIdentifier: "Dashboard") as! DashboardController
                //self.navigationController!.pushViewController(vcHome, animated: true)
            }else{
                var alert = UIAlertView(title: "Error", message: self.login[0].message, delegate: nil, cancelButtonTitle: "OK")
                alert.show()
                }
                ViewControllerUtils.sharedInstance.removeLoader()
            } catch let errorData {
              
                print(errorData.localizedDescription)
                ViewControllerUtils.sharedInstance.removeLoader()
            }
        }) { (Error) in
            ViewControllerUtils.sharedInstance.removeLoader()
            print(Error?.localizedDescription)
           
        }
   
    }
    
    
    // - - - - - - - - Check mpin here - -  - - - - - - - - - -
    func apiCheckMpin(){
        
        let json: [String: Any] =  ["CIN":(edtCin.text ?? "")!,
                                    "ClientSecret":"ScreenId",
                                    "category":UserDefaults.standard.value(forKey: "userCategory") as! String,
                                    "newmpin":"",
                                    "deviceId":deviceId,
                                    "appid":3]
        
        print("CHECK MPIN AT LOGIN - - - - -",json)
        
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
                    }else if (self.MpinDataMain[0].isForcedLogout!){
//                        print("Logout\n", terminator: "")
//                        let loginData = UserDefaults.standard
//                        loginData.removeObject(forKey: "loginData")
//
//                        let vcLogin = self.storyboard?.instantiateViewController(withIdentifier: "LoginScreen") as! LoginController
//                        self.navigationController!.pushViewController(vcLogin, animated: false)
//                        self.dismiss(animated: true, completion: nil)
                    }else{
                        if(self.MpinElementMain[0].result ?? false){
                            // - - - -  Mpin is set already
                            //UserDefaults.standard.set(self.loginData, forKey: "loginData")
                            
//                            if let arrViewCartData = UserDefaults.standard.object(forKey: "addToCart") as? Data {
//                                let decoder = JSONDecoder()
//                                if var decodedData = try? decoder.decode([[OrderDetailData]].self, from: arrViewCartData) {
//
//                                    if(decodedData.count > 0){
//                                        if(self.lastCin.isEqual(self.currCin)){
//
//                                        }else{
//                                            UserDefaults.standard.removeObject(forKey: "addToCart")
//                                        }
//                                    }
//                                }
//                            }
                            
                            let vcHome = self.storyboard?.instantiateViewController(withIdentifier: "Dashboard") as! DashboardController
                            self.navigationController!.pushViewController(vcHome, animated: true)
                            
                        }else{
                            // - - - -  Mpin is not set
                            let vcSetMpin = self.storyboard?.instantiateViewController(withIdentifier: "SetMpin") as! SetMpinController
                            UserDefaults.standard.removeObject(forKey: "addToCart")
                            vcSetMpin.loginData = self.loginData
                            vcSetMpin.strCin = (self.edtCin.text ?? "-")!
                            self.navigationController?.pushViewController(vcSetMpin, animated: true)
                        }
                    }
                    
                }
                catch let errorData {
                    print(errorData.localizedDescription)
                }
                
            }
            
        }) { (Error) in
            print(Error?.localizedDescription)
        }
        
    }
    
    func getIPAddress() -> String? {
        var address : String?
        
        // Get list of all interfaces on the local machine:
        var ifaddr : UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0 else { return nil }
        guard let firstAddr = ifaddr else { return nil }
        
        // For each interface ...
        for ifptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
            let interface = ifptr.pointee
            
            // Check for IPv4 or IPv6 interface:
            let addrFamily = interface.ifa_addr.pointee.sa_family
            if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {
                
                // Check interface name:
                let name = String(cString: interface.ifa_name)
                if  name == "en0" || name == "pdp_ip0" {
                    
                    // Convert interface address to a human readable string:
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    getnameinfo(interface.ifa_addr, socklen_t(interface.ifa_addr.pointee.sa_len),
                                &hostname, socklen_t(hostname.count),
                                nil, socklen_t(0), NI_NUMERICHOST)
                    address = String(cString: hostname)
                }
            }
        }
        freeifaddrs(ifaddr)
        
        return (address ?? "")!
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

extension LoginController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let lat = locations.last?.coordinate.latitude, let long = locations.last?.coordinate.longitude {
            print("LAT LONG - - - \(lat),\(long)")
            mLat = lat
            mLong = long
        } else {
            print("No coordinates")
        }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
