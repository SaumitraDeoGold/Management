
//  EnquiryController.swift
//  DealorsApp
//
//  Created by Goldmedal on 3/29/18.
//  Copyright © 2018 Goldmedal. All rights reserved.
//

import UIKit
import FirebaseAnalytics

class EnquiryController: BaseViewController,PopupDateDelegate {
    
    @IBOutlet weak var menuEnquiry: UIBarButtonItem!
    @IBOutlet weak var lblEmailId: UILabel!
    @IBOutlet weak var btnEnquiry: UIButton!
    @IBOutlet weak var edtEnquiryForm: UITextField!
    @IBOutlet weak var btnSendEnquiry: UIButton!
    
    var enquiry = [EnquiryElement]()
    var strCin = ""
    var strEmailId = ""
    var strSlNo = "-1"
    var enquiryApi=""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addSlideMenuButton()
        
        let loginData =  UserDefaults.standard.value(forKey: "loginData") as? Dictionary ?? [:]
        strCin = loginData["userlogid"] as? String ?? ""
        strEmailId = loginData["email"] as! String
        
        let initialData =  UserDefaults.standard.value(forKey: "initialData") as? Dictionary ?? [:]
        enquiryApi = (initialData["baseApi"] as? String ?? "")+""+(initialData["sendEnquiry"] as? String ?? "")
        
        // Do any additional setup after loading the view.
        lblEmailId.text = strEmailId
        
        Analytics.setScreenName("ENQUIRY SCREEN", screenClass: "EnquiryController")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func clicked_send_enquiry(_ sender: UIButton) {
        if((edtEnquiryForm.text?.trimmingCharacters(in: NSCharacterSet.whitespaces).count)!  < 1){
            var alert = UIAlertView(title: nil, message: "Message Cannot be Empty", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
        }else{
            if (Utility.isConnectedToNetwork()) {
                print("Internet connection available")
                if(strSlNo == "-1"){
                    var alert = UIAlertView(title: nil, message: "Please Select a Subject", delegate: nil, cancelButtonTitle: "OK")
                    alert.show()
                }else{
                    self.apiEnquiry()
                }
                
            }
            else{
                print("No internet connection available")
                
                var alert = UIAlertView(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", delegate: nil, cancelButtonTitle: "OK")
                alert.show()
            }
        }
    }
    
    
    @IBAction func clicked_enquiry(_ sender: UIButton) {
        let sb = UIStoryboard(name: "EnquiryPicker", bundle: nil)
        let popup = sb.instantiateInitialViewController() as? EnquiryPickerController
        popup?.delegate = self
        self.present(popup!, animated: true)
    }
    
    func updateEnquiry(value: String, slNo: String) {
        btnEnquiry.setTitle(value, for: .normal)
        strSlNo = slNo
    }
    
    func apiEnquiry(){
        
        let json: [String: Any] =  ["CIN":strCin,"Email":strEmailId,"ClientSecret":"ClientSecret","Subject":strSlNo,"EquiryText":edtEnquiryForm.text]
        
        DataManager.shared.makeAPICall(url: enquiryApi, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            
            do {
                self.enquiry = try JSONDecoder().decode([EnquiryElement].self, from: data!)
                
                let isSuccess = (self.enquiry[0].result ?? false)!
                print(isSuccess)
                
                if(isSuccess){
                    var alert = UIAlertView(title: "Success", message: "Enquiry sent successfully", delegate: nil, cancelButtonTitle: "OK")
                    alert.show()
                    
                    self.edtEnquiryForm.text = ""
                    ViewControllerUtils.sharedInstance.removeLoader()
                }
                else
                {
                    var alert = UIAlertView(title: "Error", message: self.enquiry[0].message, delegate: nil, cancelButtonTitle: "OK")
                    alert.show()
                    ViewControllerUtils.sharedInstance.removeLoader()
                }
            } catch let errorData {
                print(errorData.localizedDescription)
            }
        }) { (Error) in
            ViewControllerUtils.sharedInstance.removeLoader()
            print(Error?.localizedDescription)
        }
        
        
    }
    
    
    
}
