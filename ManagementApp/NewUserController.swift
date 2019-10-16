//
//  NewUserController.swift
//  DealorsApp
//
//  Created by Goldmedal on 3/26/18.
//  Copyright © 2018 Goldmedal. All rights reserved.
//

import UIKit
import FirebaseAnalytics

class NewUserController: UIViewController {
    
    @IBOutlet weak var edtCin: UITextField!
    @IBOutlet weak var captchaView: CaptchaView!
    
    var strHeader = String()
    
    var validateCIN = [ValidateCINElement]()
    var validateCINObj = [ValidateCinData]()
    var newUserApi = ""
    
    @IBAction func onClickSubmit(_ sender: Any) {
        
        if((edtCin.text?.trimmingCharacters(in: NSCharacterSet.whitespaces).count)!  < 5)
        {
            var alert = UIAlertView(title: nil, message: "Invalid CIN", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
        } else {
            if(captchaView.checkCaptcha()){
                if (Utility.isConnectedToNetwork()) {
                    self.apiNewUser()
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
    
    @IBAction func clicked_back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    
    func apiNewUser(){
        ViewControllerUtils.sharedInstance.showLoader()
        
        let json: [String: Any] =
            ["CIN":edtCin.text,"Category":"Management","ClientSecret":"sgupta"]
        
        let manager =  DataManager.shared
        
        manager.makeAPICall(url: newUserApi, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            
            do {
                self.validateCIN = try JSONDecoder().decode([ValidateCINElement].self, from: data!)
                self.validateCINObj  = self.validateCIN[0].data
                
                let isSuccess = (self.validateCIN[0].result ?? false)!
                if isSuccess
                {
                    let vcOtp = self.storyboard?.instantiateViewController(withIdentifier: "OtpScreen") as! OtpController
                    
                    vcOtp.strEmailid = self.validateCINObj[0].email ?? ""
                    vcOtp.strMobileNumber = self.validateCINObj[0].mobile ?? ""
                    vcOtp.strCin = self.edtCin.text!
                    
                    self.navigationController?.pushViewController(vcOtp, animated: true)
                    
                }
                ViewControllerUtils.sharedInstance.removeLoader()
            } catch let errorData {
                ViewControllerUtils.sharedInstance.removeLoader()
                print(errorData.localizedDescription)
            }
        }) { (Error) in
            ViewControllerUtils.sharedInstance.removeLoader()
            print(Error?.localizedDescription)
            
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let initialData =  UserDefaults.standard.value(forKey: "initialData") as? Dictionary ?? [:]
        newUserApi = (initialData["baseApi"] as? String ?? "")+""+(initialData["validateCIN"] as? String ?? "")
        
        // Do any additional setup after loading the view.
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationItem.title = strHeader
        
        Analytics.setScreenName("NEW USER SCREEN", screenClass: "NewUserController")
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
