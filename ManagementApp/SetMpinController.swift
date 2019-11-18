//
//  SetMpinController.swift
//  DealorsApp
//
//  Created by Goldmedal on 1/14/19.
//  Copyright © 2019 Goldmedal. All rights reserved.
//

import UIKit
import FirebaseAnalytics

class SetMpinController: UIViewController,UITextFieldDelegate {
    
    @IBOutlet weak var edtSetMpin: UITextField!
    @IBOutlet weak var edtConfirmMpin: UITextField!
    @IBOutlet weak var btnSet: UIButton!
    
    var setMpinElementMain = [SetMpinElement]()
    var setMpinDataMain = [SetMpinData]()
    
    var SetMpinApi = ""
    var strCin = String()
    var loginData:Any!
    var deviceId = ""
    
    let MAX_LENGTH_QTY = 4
    let ACCEPTABLE_NUMBERS = "0123456789"
   
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let initialData =  UserDefaults.standard.value(forKey: "initialData") as? Dictionary ?? [:]
        SetMpinApi = (initialData["baseApi"] as? String ?? "")+""+(initialData["mpinadds"] as? String ?? "")
        //SetMpinApi = "https://api.goldmedalindia.in//api/mpinadds"
        
        deviceId = UIDevice.current.identifierForVendor!.uuidString
        if(deviceId.isEqual("")){
            deviceId = "-"
        }
        
        edtSetMpin.addTarget(self, action: #selector(self.textFieldDidChange(_:)),
                              for: UIControlEvents.editingChanged)
        edtSetMpin.delegate = self
        edtSetMpin.tag = 1
        
        edtConfirmMpin.addTarget(self, action: #selector(self.textFieldDidChange(_:)),
                             for: UIControlEvents.editingChanged)
        edtConfirmMpin.delegate = self
        edtConfirmMpin.tag = 2
        
        Analytics.setScreenName("SET MPIN SCREEN", screenClass: "SetMpinController")
        //SQLiteDB.instance.addAnalyticsData(ScreenName: "SET MPIN SCREEN", ScreenId: Int64(GlobalConstants.init().SET_MPIN))
      
    }
    
    // - - - -- -  Textfield triggered events on screen -  --  - - - - - - - -
    @objc func textFieldDidChange(_ textField: UITextField) {
        print("TEXT DID CHANGE")
        if(textField.tag == 1)
        {
            edtSetMpin.text = textField.text!
        }
        
        if(textField.tag == 2)
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
    
    
    func apiSetMpin(){
        ViewControllerUtils.sharedInstance.showLoader()
        
        
        let json: [String: Any] =  ["CIN":strCin,
                                    "ClientSecret":"ScreenId",
                                    "category":UserDefaults.standard.value(forKey: "userCategory") as! String,
                                    "oldmpin":"000000",
                                    "newmpin":edtConfirmMpin.text ?? "",
                                    "deviceId":deviceId,
                                    "appid":3]

        print("SET MPIN - - - - -",json)

        let manager =  DataManager.shared

        manager.makeAPICall(url: SetMpinApi, params: json, method: .POST, success: { (response) in
            let data = response as? Data

            do {
                self.setMpinElementMain = try JSONDecoder().decode([SetMpinElement].self, from: data!)
                
                let isSuccess = (self.setMpinElementMain[0].result ?? false)!
                
                if isSuccess
                {
                    var alert = UIAlertView(title: "Success", message: "M-Pin set successfully !!!", delegate: nil, cancelButtonTitle: "OK")
                    alert.show()
                    
                    //UserDefaults.standard.set(self.loginData, forKey: "loginData")
                    
                    let vcHome = self.storyboard?.instantiateViewController(withIdentifier: "Dashboard") as! DashboardController
                    self.navigationController!.pushViewController(vcHome, animated: true)
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

    
    @IBAction func clicked_set(_ sender: UIButton) {
        
        if((edtSetMpin.text?.trimmingCharacters(in: NSCharacterSet.whitespaces).count)!  != 4)
        {
            var alert = UIAlertView(title: nil, message: "Enter Valid Set Mpin", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
        }else if((edtConfirmMpin.text?.trimmingCharacters(in: NSCharacterSet.whitespaces).count)!  != 4)
        {
            var alert = UIAlertView(title: nil, message: "Enter valid Confirm Mpin", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
        }else if(edtSetMpin.text != edtConfirmMpin.text)
        {
            var alert = UIAlertView(title: nil, message: "Confirm Mpin does not match", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
        }
        else{
            if (Utility.isConnectedToNetwork()) {
               apiSetMpin()
            }
            else{
                var alert = UIAlertView(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", delegate: nil, cancelButtonTitle: "OK")
                alert.show()
            }
        }
        
    }
    
}
