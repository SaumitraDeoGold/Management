//
//  RaiseDisputePopupController.swift
//  DealorsApp
//
//  Created by Goldmedal on 5/2/19.
//  Copyright © 2019 Goldmedal. All rights reserved.
//

import UIKit
import DropDown

struct RaiseDisputeSendElement: Codable {
    let result: Bool?
    let message, servertime: String?
    let data: RaiseDisputeSendObj?
}

struct RaiseDisputeSendObj: Codable {
}


class RaiseDisputePopupController: UIViewController {
    
    @IBOutlet weak var btnSend: UIButton!
    @IBOutlet weak var edtRaiseDisputeForm: UITextField!
    
    var RaiseDisputeElementMain = [RaiseDisputeElement]()
    var RaiseDisputeArr = [RaiseDisputeObj]()
    var strRaiseDisputeArr = [String]()
    
    var sendDisputeElement = [RaiseDisputeSendElement]()
    
    @IBOutlet weak var vwDropDown: RoundView!
    @IBOutlet weak var lblDropdownText: UILabel!
    @IBOutlet weak var imvClose: UIImageView!
    @IBOutlet weak var vwClose: UIView!
    
    var strCin = ""
    var getRaiseDisputeApi=""
    var sendRaiseDisputeApi=""
    var disputeIndex = 0
    var disputeId = -1
    
    let dropDown = DropDown()
    
    var strTrxId = String()
   
    override func viewDidLoad() {
        super.viewDidLoad()

        let loginData =  UserDefaults.standard.value(forKey: "loginData") as? Dictionary ?? [:]
        strCin = loginData["userlogid"] as? String ?? ""
        
        let initialData =  UserDefaults.standard.value(forKey: "initialData") as? Dictionary ?? [:]
        getRaiseDisputeApi = (initialData["baseApi"] as? String ?? "")+""+(initialData["disputeType"] as? String ?? "")
        sendRaiseDisputeApi = (initialData["baseApi"] as? String ?? "")+""+(initialData["raiseDispute"] as? String ?? "")
//        getRaiseDisputeApi = "https://api.goldmedalindia.in//api/getDisputeType"
//        sendRaiseDisputeApi = "https://api.goldmedalindia.in//api/RaiseDispute"
        
        // Do any additional setup after loading the view.
        if (Utility.isConnectedToNetwork()) {
            print("Internet connection available")
            OperationQueue.main.addOperation {
                self.apiGetRaiseDisputeList()
            }
        }
        else{
            print("No internet connection available")
            
            var alert = UIAlertView(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
        }
        
        let gesture = UITapGestureRecognizer(target: self, action: "clickDropdown:")
        vwDropDown.addGestureRecognizer(gesture)
    
        
        let tabClose = UITapGestureRecognizer(target: self, action: #selector(self.tapFunction))
        vwClose.addGestureRecognizer(tabClose)
    }
    
    @objc func tapFunction(sender:UITapGestureRecognizer) {
        print("tap working")
        dismiss(animated: true)
    }
    
    
    
    // - - - - - - - - -  - Get raise dispute list - - - - -  - - - - - -
    func apiGetRaiseDisputeList(){
        ViewControllerUtils.sharedInstance.showLoader()
        
        let json: [String: Any] = ["CIN":strCin,"ClientSecret":"ClientSecret"]
        
        DataManager.shared.makeAPICall(url: getRaiseDisputeApi, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            
            DispatchQueue.main.async {
                do {
                    self.RaiseDisputeElementMain = try JSONDecoder().decode([RaiseDisputeElement].self, from: data!)
                    self.RaiseDisputeArr = self.RaiseDisputeElementMain[0].data
               
                } catch let errorData {
                    print(errorData.localizedDescription)
                    
                    var alert = UIAlertView(title: "Error", message: "No Data Available", delegate: nil, cancelButtonTitle: "OK")
                    alert.show()
                    
                    self.dismiss(animated: true, completion: nil)
                }
                
                if(self.RaiseDisputeArr.count>0){
                    for i in 0...(self.RaiseDisputeArr.count-1) 
                    {
                        self.strRaiseDisputeArr.append(self.RaiseDisputeArr[i].reason ?? "-")
                    }
                    self.dropDown.dataSource = self.strRaiseDisputeArr
                    
                    self.lblDropdownText.text = self.dropDown.dataSource[0]
                    self.disputeId =  (self.RaiseDisputeArr[0].disputeid ?? -1)!
                    self.dropDown.dismissMode = .onTap

                }else{
                    var alert = UIAlertView(title: "Error", message: "No Data Available", delegate: nil, cancelButtonTitle: "OK")
                    alert.show()
                    
                    self.dismiss(animated: true, completion: nil)
                }
                
                ViewControllerUtils.sharedInstance.removeLoader()
                
            }
        }) { (Error) in
            ViewControllerUtils.sharedInstance.removeLoader()
            print(Error?.localizedDescription)
           
            var alert = UIAlertView(title: "Error", message: "No Data Available", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
            
            self.dismiss(animated: true, completion: nil)
        }
        
    }
    
    
    @objc func clickDropdown(_ sender:UITapGestureRecognizer){
        
        dropDown.show()
        
        // The view to which the drop down will appear on
        dropDown.anchorView = vwDropDown // UIView or UIBarButtonItem
        
        
        // Action triggered on selection
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            print("Selected item: \(item) at index: \(index)")
            self.lblDropdownText.text = item
            self.disputeIndex = index
             print("DISPUTE INDEX - - -",self.disputeIndex)
            self.disputeId = (self.RaiseDisputeArr[self.disputeIndex].disputeid ?? -1)!
             print("DISPUTE ID - - -",self.disputeId)
           
            self.dropDown.hide()
        }
    }
    
    
    
    @IBAction func clicked_send_enquiry(_ sender: UIButton) {
        if((edtRaiseDisputeForm.text?.trimmingCharacters(in: NSCharacterSet.whitespaces).count)!  < 1){
            var alert = UIAlertView(title: nil, message: "Message Cannot be Empty", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
        }else{
            if (Utility.isConnectedToNetwork()) {
                print("Internet connection available")
                if(disputeId == -1){
                    var alert = UIAlertView(title: nil, message: "Please Select Dispute reason", delegate: nil, cancelButtonTitle: "OK")
                    alert.show()
                }else{
                    self.apiSendDisputeQuery()
                }
                
            }
            else{
                print("No internet connection available")
                
                var alert = UIAlertView(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", delegate: nil, cancelButtonTitle: "OK")
                alert.show()
            }
        }
    }
    
    
    // - - - - - - - - - - - - send raise dispute query - - - - - - - - -  -
    func apiSendDisputeQuery(){
        ViewControllerUtils.sharedInstance.showLoader()
        
        let json: [String: Any] = ["CIN":strCin,"ClientSecret":"ClientSecret","disputeid":disputeId,"details":(edtRaiseDisputeForm.text)!,"transactionid":strTrxId]
        
        print("dispute raised - - - ",json)
        
        DataManager.shared.makeAPICall(url: sendRaiseDisputeApi, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            
            DispatchQueue.main.async {
                do {
                     self.sendDisputeElement = try JSONDecoder().decode([RaiseDisputeSendElement].self, from: data!)
                    
                    let result = self.sendDisputeElement[0].result
                    
                    if(result ?? false){
                        var alert = UIAlertView(title: "Success", message: "Outstanding dispute raised successfully", delegate: nil, cancelButtonTitle: "OK")
                        alert.show()
                        
                        self.dismiss(animated: true, completion: nil)
                    }else{
                        var alert = UIAlertView(title: "Failed", message: "Outstanding Dispute failed", delegate: nil, cancelButtonTitle: "OK")
                        alert.show()
                    }
                    
                } catch let errorData {
                    print(errorData.localizedDescription)
                    
                    var alert = UIAlertView(title: "Error", message: "Outstanding Dispute failed", delegate: nil, cancelButtonTitle: "OK")
                    alert.show()
                }
              
                ViewControllerUtils.sharedInstance.removeLoader()
                
            }
        }) { (Error) in
            ViewControllerUtils.sharedInstance.removeLoader()
            
            var alert = UIAlertView(title: "Error", message: "Server Error", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
            
            print(Error?.localizedDescription)
        
        }
        
    }
    

}
