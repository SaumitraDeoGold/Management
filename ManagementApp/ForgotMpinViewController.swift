//
//  ForgotMpinViewController.swift
//  DealorsApp
//
//  Created by Goldmedal on 1/14/19.
//  Copyright © 2019 Goldmedal. All rights reserved.
//

import UIKit
import FirebaseAnalytics

class ForgotMpinViewController: UIViewController,UITextFieldDelegate {
        
        @IBOutlet weak var edtOldMpin: UITextField!
        @IBOutlet weak var edtNewMpin: UITextField!
        @IBOutlet weak var edtConfirmMpin: UITextField!
        @IBOutlet weak var btnConfirm: UIButton!
        
        var setMpinElementMain = [SetMpinElement]()
        var setMpinDataMain = [SetMpinData]()
        
        var ChangeMpinApi = ""
        var deviceId = ""
        var callFrom = String()
        var strOldMpin = ""
        var strCin = String()
        
        let MAX_LENGTH_QTY = 4
        let ACCEPTABLE_NUMBERS = "0123456789"
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            // Do any additional setup after loading the view.
            
          //  ChangeMpinApi = "https://api.goldmedalindia.in//api/mpinadds"
            let initialData =  UserDefaults.standard.value(forKey: "initialData") as? Dictionary ?? [:]
            ChangeMpinApi = (initialData["baseApi"] as? String ?? "")+""+(initialData["mpinadds"] as? String ?? "")
            
            let loginData =  UserDefaults.standard.value(forKey: "loginData") as? Dictionary ?? [:]
            strCin = loginData["userlogid"] as? String ?? ""
            
            if(callFrom.elementsEqual("ForgotMpin")){
                edtOldMpin.isHidden = true
            }else{
                edtOldMpin.isHidden = false
            }
            
            deviceId = UIDevice.current.identifierForVendor!.uuidString
            if(deviceId.isEqual("")){
                deviceId = "-"
            }
            
            edtOldMpin.addTarget(self, action: #selector(self.textFieldDidChange(_:)),
                                 for: UIControlEvents.editingChanged)
            edtOldMpin.delegate = self
            edtOldMpin.tag = 1
            
            edtNewMpin.addTarget(self, action: #selector(self.textFieldDidChange(_:)),
                                 for: UIControlEvents.editingChanged)
            edtNewMpin.delegate = self
            edtNewMpin.tag = 2
            
            edtConfirmMpin.addTarget(self, action: #selector(self.textFieldDidChange(_:)),
                                     for: UIControlEvents.editingChanged)
            edtConfirmMpin.delegate = self
            edtConfirmMpin.tag = 3
            
            Analytics.setScreenName("FORGOT MPIN SCREEN", screenClass: "ForgotMpinViewController")
//            SQLiteDB.instance.addAnalyticsData(ScreenName: "FORGOT MPIN SCREEN", ScreenId: Int64(GlobalConstants.init().FORGOT_MPIN))
        
        }
        
        // - - - -- -  Textfield triggered events on screen -  --  - - - - - - - -
        @objc func textFieldDidChange(_ textField: UITextField) {
            print("TEXT DID CHANGE")
            if(textField.tag == 1)
            {
                edtOldMpin.text = textField.text!
            }
            
            if(textField.tag == 2)
            {
                edtNewMpin.text = textField.text!
            }
            
            if(textField.tag == 3)
            {
                edtConfirmMpin.text = textField.text!
            }
            
        }
        
        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            print("TEXT RANGE")
            
            let newLength: Int = textField.text!.characters.count + string.characters.count - range.length
            let numberOnly = NSCharacterSet.init(charactersIn: ACCEPTABLE_NUMBERS).inverted
            let strValid = string.rangeOfCharacter(from: numberOnly) == nil
            
            return (strValid && (newLength <= MAX_LENGTH_QTY))
        }
    
    
    
    @IBAction func clicked_back(_ sender: Any) {
            let vcHome = self.storyboard?.instantiateViewController(withIdentifier: "Dashboard") as! DashboardController
            self.navigationController!.pushViewController(vcHome, animated: false)
            self.dismiss(animated: true, completion: nil)
    }
        
        // - - - - - -  API to change or reset mpin -  - - - - - - - - -
        func apiChangeMpin(){
            ViewControllerUtils.sharedInstance.showLoader()
            
            if(callFrom.elementsEqual("ChangeMpin")){
                strOldMpin = (edtOldMpin.text ?? "-")!
            }else if(callFrom.elementsEqual("ForgotMpin")){
                strOldMpin = "000000"
            }

            
            let json: [String: Any] =  ["CIN":strCin,
                                        "ClientSecret":"ScreenId",
                                        "category":UserDefaults.standard.value(forKey: "userCategory") as! String,
                                        "oldmpin":strOldMpin,
                                        "newmpin":edtNewMpin.text ?? "",
                                        "deviceId":deviceId,
                                        "appid":3]
            
            print("CHANGE MPIN - - - - -",json)
            
            let manager =  DataManager.shared
            
            manager.makeAPICall(url: ChangeMpinApi, params: json, method: .POST, success: { (response) in
                let data = response as? Data
                
                do {
                    self.setMpinElementMain = try JSONDecoder().decode([SetMpinElement].self, from: data!)
                    
                    let isSuccess = (self.setMpinElementMain[0].result ?? false)!
                    
                    if isSuccess
                    {
                        var alert = UIAlertView(title: "Success", message: "M-Pin Changed successfully !!!", delegate: nil, cancelButtonTitle: "OK")
                        alert.show()
                      
                        let vcHome = self.storyboard?.instantiateViewController(withIdentifier: "Dashboard") as! DashboardController
                        self.navigationController!.pushViewController(vcHome, animated: true)
                    }else{
                        var alert = UIAlertView(title: "Failed", message: "Invalid Mpin", delegate: nil, cancelButtonTitle: "OK")
                        alert.show()
                    }
                    ViewControllerUtils.sharedInstance.removeLoader()
                } catch let errorData {
                    print(errorData.localizedDescription)
                    ViewControllerUtils.sharedInstance.removeLoader()
                    
                    var alert = UIAlertView(title: "Failed", message: "Server Error", delegate: nil, cancelButtonTitle: "OK")
                    alert.show()
                }
            }) { (Error) in
                ViewControllerUtils.sharedInstance.removeLoader()
                print(Error?.localizedDescription)
                
                var alert = UIAlertView(title: "Server Error", message: "Server Error", delegate: nil, cancelButtonTitle: "OK")
                alert.show()
            }
            
        }
        
        
        @IBAction func clicked_set(_ sender: UIButton) {
            
            if(callFrom.elementsEqual("Change") && (edtOldMpin.text?.trimmingCharacters(in: NSCharacterSet.whitespaces).count)!  != 4)
            {
                var alert = UIAlertView(title: nil, message: "Enter Valid Old Mpin", delegate: nil, cancelButtonTitle: "OK")
                alert.show()
            }
            else if((edtNewMpin.text?.trimmingCharacters(in: NSCharacterSet.whitespaces).count)!  != 4)
            {
                var alert = UIAlertView(title: nil, message: "Enter valid New Mpin", delegate: nil, cancelButtonTitle: "OK")
                alert.show()
            }else if(edtNewMpin.text != edtConfirmMpin.text)
            {
                var alert = UIAlertView(title: nil, message: "Confirm Mpin does not match", delegate: nil, cancelButtonTitle: "OK")
                alert.show()
            }
            else{
                if (Utility.isConnectedToNetwork()) {
                    apiChangeMpin()
                }
                else{
                    var alert = UIAlertView(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", delegate: nil, cancelButtonTitle: "OK")
                    alert.show()
                }
            }
            
        }
        
}
