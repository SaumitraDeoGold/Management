//
//  SetPasswordControllerViewController.swift
//  DealorsApp
//
//  Created by Goldmedal on 4/19/18.
//  Copyright © 2018 Goldmedal. All rights reserved.
//

import UIKit
import FirebaseAnalytics

class SetPasswordController: UIViewController {
    @IBOutlet weak var edtOldPassword: UITextField!
    @IBOutlet weak var edtNewPassword: UITextField!
    @IBOutlet weak var edtConfirmPassword: UITextField!
    @IBOutlet weak var btnSetPassword: UIButton!
    
    var setPassword = [SetPasswordElement]()
    var strCin = String()
    
    var callFrom = String()
    var setPasswordApi=""
    
    @IBAction func clicked_setpassword(_ sender: UIButton) {
      
        if(callFrom == "CHANGE" && (edtOldPassword.text?.trimmingCharacters(in: NSCharacterSet.whitespaces).count)!  == 0)
        {
            var alert = UIAlertView(title: nil, message: "Please enter old password", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
        }else if((edtNewPassword.text?.trimmingCharacters(in: NSCharacterSet.whitespaces).count)!  == 0)
        {
            var alert = UIAlertView(title: nil, message: "Please enter new password", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
        }
        else if(edtNewPassword.text != edtConfirmPassword.text)
        {
            var alert = UIAlertView(title: nil, message: "Confirm Password does not match", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
        }
        else{
           self.apiCheckPassword()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let initialData =  UserDefaults.standard.value(forKey: "initialData") as? Dictionary ?? [:]
        setPasswordApi = (initialData["baseApi"] as? String ?? "")+""+(initialData["setPassword"] as? String ?? "")

        self.navigationController?.setNavigationBarHidden(false, animated: true)
        if(callFrom == "SET"){
            edtOldPassword.isHidden = true
        }
        
        Analytics.setScreenName("SET PASSWORD SCREEN", screenClass: "SetPasswordController")
        
    }
    
    @IBAction func clicked_back(_ sender: Any) {
         if(callFrom == "SET"){
            let vcLogin = self.storyboard?.instantiateViewController(withIdentifier: "LoginScreen") as! LoginController
            self.navigationController?.pushViewController(vcLogin, animated: true)
        }else{
            let vcHome = self.storyboard?.instantiateViewController(withIdentifier: "Dashboard") as! DashboardController
            self.navigationController!.pushViewController(vcHome, animated: false)
        }
         self.dismiss(animated: true, completion: nil)
      
    }
    
     func apiCheckPassword(){
     ViewControllerUtils.sharedInstance.showLoader()
        
        let json: [String: Any] =
             ["CIN":strCin,"Category":"Party","OldPassword":edtOldPassword.text,"NewPassword":edtNewPassword.text,"ClientSecret":"sgupta"]
        
        let manager =  DataManager.shared
        
        manager.makeAPICall(url: setPasswordApi, params: json, method: .POST, success: { (response) in
            
            let data = response as? Data
            
            do {
                self.setPassword = try JSONDecoder().decode([SetPasswordElement].self, from: data!)
             
                let isSuccess = (self.setPassword[0].result ?? false)!
                if isSuccess
                {  
                    let loginData = UserDefaults.standard
                    loginData.removeObject(forKey: "loginData")
                    
                    let vcLogin = self.storyboard?.instantiateViewController(withIdentifier: "LoginScreen") as! LoginController
                    self.navigationController?.pushViewController(vcLogin, animated: true)
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
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
