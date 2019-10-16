//
//  SpinWheelController.swift
//  DealorsApp
//
//  Created by Goldmedal on 10/6/18.
//  Copyright © 2018 Goldmedal. All rights reserved.
//

import UIKit
import TTFortuneWheel
import FirebaseAnalytics

struct SpinCnElement:Codable {
    let result: Bool?
    let message, servertime: String?
}

class SpinWheelController: BaseViewController {
    
     var startWheel = true

    @IBOutlet weak var spinningWheel: TTFortuneWheel!
    
    @IBOutlet weak var lblTotalSpins: UILabel!
    @IBOutlet weak var lblRemainingSpins: UILabel!
    @IBOutlet weak var lblTotalAmnt: UILabel!
    @IBOutlet weak var btnDetails: UIButton!
    
    var strCin = ""
    var getSpinDataApi = ""
    var setSpinDataApi = ""
    var applyCnApi = ""
    
    var SpinElementMain = [SpinElement]()
    var SpinDataMain = [SpinObj]()
    
    var SpinConfirmElementMain = [SpinConfirmElement]()
    var SpinConfirmDataMain = [SpinConfirmObj]()
    
     var SpinCnElementMain = [SpinCnElement]()
    
    var totalSpins = ""
    var remainingSpins = ""
    var totalAmount = ""
    
    var nxtWinningAmnt:Int = 0
    var nxtWinningIndex:Int = 0
    
    var SlNo:Int = 0
    
    //To show popup for applying credit note
    var isApplyCN = false
    
    //To check if spin is active or not
    var isActiveSpin = false
    
    var spinClicked = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addSlideMenuButton()
        
        SlNo = 0
        
        let slices = [ CarnivalWheelSlice.init(title: "\u{20B9} 3000"),
                       CarnivalWheelSlice.init(title: "\u{20B9} 4500"),
                       CarnivalWheelSlice.init(title: "\u{20B9} 6000")]
        self.spinningWheel.slices = slices
        self.spinningWheel.equalSlices = true
        self.spinningWheel.frameStroke.width = 0
        self.spinningWheel.slices.enumerated().forEach { (pair) in
            let slice = pair.element as! CarnivalWheelSlice
            let offset = pair.offset
            switch offset % 3 {
            case 0: slice.style = .deepBlue
            case 1: slice.style = .deepPink
            case 2: slice.style = .deepYellow
            default: slice.style = .deepBlue
            }
        }
        
        let loginData =  UserDefaults.standard.value(forKey: "loginData") as? Dictionary ?? [:]
        strCin = loginData["userlogid"] as? String ?? ""
        
        let initialData =  UserDefaults.standard.value(forKey: "initialData") as? Dictionary ?? [:]
        getSpinDataApi = (initialData["baseApi"] as? String ?? "")+""+(initialData["wheelSpins"] as? String ?? "")
        setSpinDataApi = (initialData["baseApi"] as? String ?? "")+""+(initialData["amountConfirmation"] as? String ?? "")
        applyCnApi = (initialData["baseApi"] as? String ?? "")+""+(initialData["applyCN"] as? String ?? "")
        
         if (Utility.isConnectedToNetwork()) {
            print("Internet connection available")
            OperationQueue.main.addOperation {
                self.apiGetSpinData()
            }
        }
        else {
            print("No internet connection available")
            var alert = UIAlertView(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
        }
        
        spinClicked = false
        
         Analytics.setScreenName("SPIN WHEEL SCREEN", screenClass: "SpinWheelController")
    }
    
    
    @IBAction func clicked_spinDetails(_ sender: UIButton) {
        let sb = UIStoryboard(name: "SpinTotalPopup", bundle: nil)
        let popup = sb.instantiateInitialViewController()!
        self.present(popup, animated: true)
    }
    
    
    // - - - - - - - - Get spin data here
    func apiGetSpinData(){
      
        let json: [String: Any] =
            ["ClientSecret":"1170004","CIN":strCin]
        
        print("GET SPIN WHEEL ------ ",json)
        
        DataManager.shared.makeAPICall(url: getSpinDataApi, params: json, method: .POST, success: { (response) in
            let data = response as? Data
           
            DispatchQueue.main.async {
                do {
                    self.SpinElementMain = try JSONDecoder().decode([SpinElement].self, from: data!)
                    self.SpinDataMain = self.SpinElementMain[0].data
                    
                    print("GET SPIN DATA   - - -",self.SpinDataMain)
                    
                     self.totalSpins = self.SpinDataMain[0].noOfSpin ?? ""
                     self.remainingSpins = self.SpinDataMain[0].remSpin ?? ""
                     self.totalAmount = self.SpinDataMain[0].winAmt ?? "0"
                    
                    self.SlNo = self.SpinDataMain[0].slNo ?? 0
                    
                    self.nxtWinningAmnt = self.SpinDataMain[0].nxtDrwAmt ?? 0
                    
                    self.lblTotalSpins.text = self.totalSpins
                    self.lblRemainingSpins.text = String(Int(self.totalSpins)! - Int(self.remainingSpins)!)
                    self.lblTotalAmnt.text = Utility.formatRupee(amount: Double(self.totalAmount)!)
                    
                    self.isActiveSpin = self.SpinDataMain[0].active ?? false
                    self.isApplyCN = self.SpinDataMain[0].applyCN ?? false
                    
                    if(!self.isActiveSpin){
                   
                        let alertSpinActive = UIAlertController(title: "Not yet started Sorry!", message: "We are yet to open! Please try after a few days!", preferredStyle: .alert)
                        
                        alertSpinActive.addAction(UIAlertAction(title: "OK", style: .default, handler: { (alertAction) -> Void in
                            self.openViewControllerBasedOnIdentifier("Dashboard")
                        }))
                        
                        self.present(alertSpinActive, animated: true, completion: nil)
                     
                    }
                    
                    
                    if(self.nxtWinningAmnt == 3000){
                        self.nxtWinningIndex = 1
                    }else if(self.nxtWinningAmnt == 4500){
                         self.nxtWinningIndex = 2
                    }else if(self.nxtWinningAmnt == 6000){
                         self.nxtWinningIndex = 3
                    }
                    
                    //- - - - - - - - check for CN
                    if(self.isActiveSpin && (Int(self.remainingSpins) == 0)){
                            self.showCnAlert()
                    }
                    
                    
                } catch let errorData {
                    print(errorData.localizedDescription)
                }
           
            }
        }) { (Error) in
            print(Error?.localizedDescription)
        }
    }
    
    // - - - - - - Alert for CN
    func showCnAlert(){
        if(!self.isApplyCN){
        let alertCn = UIAlertController(title: "Claim Your CN", message: "Congratulations! Your total earnings is \u{20B9}\(String(self.totalAmount)). Please click Apply to claim your CN!", preferredStyle: .alert)
            
            alertCn.addAction(UIAlertAction(title: "OK", style: .default, handler: { (alertAction) -> Void in
                if (Utility.isConnectedToNetwork()) {
                    print("Internet connection available")
                    self.apiApplyCN()
                }
                else {
                    print("No internet connection available")
                    var alert = UIAlertView(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", delegate: nil, cancelButtonTitle: "OK")
                    alert.show()
                }
            }))
            
//            alertCn.addAction(UIAlertAction(title: "CANCEL", style: .default, handler: { (alertAction) -> Void in
//                self.openViewControllerBasedOnIdentifier("Dashboard")
//            }))
            
            
        self.present(alertCn, animated: true, completion: nil)
        }else{
            var alert = UIAlertView(title: "Already applied for CN", message: "Sorry! You've already applied for a CN worth \u{20B9}\(String(self.totalAmount)).You don't have any more chances left to spin!", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
        }
    }
    
    
     // - - - - - - - - Set spin data here
    func apiSetSpinData(){
        
        let json: [String: Any] =
            ["ClientSecret":"1170004","CIN":strCin,"SlNo":SlNo,"prizemoney":nxtWinningAmnt]
     
        print("SET SPIN WHEEL ------ ",json)
        
        DataManager.shared.makeAPICall(url: setSpinDataApi, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            
            DispatchQueue.main.async {
                do {
                    self.SpinConfirmElementMain = try JSONDecoder().decode([SpinConfirmElement].self, from: data!)
                    self.SpinConfirmDataMain = self.SpinConfirmElementMain[0].data
                    
                    print("SET SPIN DATA   - - -",self.SpinConfirmDataMain)
                    
                    self.SlNo = self.SpinConfirmDataMain[0].slNo ?? 0
                    
                    if (self.SpinConfirmElementMain[0].result ?? false){
                    
                        if(self.SpinConfirmDataMain[0].amount != 0){
                            if(self.nxtWinningAmnt == 3000){
                                var alert = UIAlertView(title: "Congratulations!!!", message: "Well done! You can do better - try again to win more!", delegate: nil, cancelButtonTitle: "OK")
                                alert.show()
                            }else if(self.nxtWinningAmnt == 4500){
                                var alert = UIAlertView(title: "Congratulations!!!", message: "Congratulations! You almost scored maximum!", delegate: nil, cancelButtonTitle: "OK")
                                alert.show()
                            }else if(self.nxtWinningAmnt == 6000){
                                var alert = UIAlertView(title: "Congratulations!!!", message: "Simply amazing! You've won maximum! ", delegate: nil, cancelButtonTitle: "OK")
                                alert.show()
                            }
                        }
                        self.nxtWinningAmnt = self.SpinConfirmDataMain[0].amount ?? 0
                        
                        
                        if(self.nxtWinningAmnt == 3000){
                            self.nxtWinningIndex = 1
                        }else if(self.nxtWinningAmnt == 4500){
                            self.nxtWinningIndex = 2
                        }else if(self.nxtWinningAmnt == 6000){
                            self.nxtWinningIndex = 3
                        }
                        
                        //check for CN
                        if(self.isActiveSpin && (Int(self.remainingSpins) == 0)){
                            self.showCnAlert()
                        }
                        
                    }else{
                        var alert = UIAlertView(title: "Failed!!!", message: "Invalid try!! Please try again", delegate: nil, cancelButtonTitle: "OK")
                        alert.show()
                    }
              
                } catch let errorData {
                    print(errorData.localizedDescription)
                }
                
                if (Utility.isConnectedToNetwork()) {
                    self.apiGetSpinData()
                }
                else {
                    var alert = UIAlertView(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", delegate: nil, cancelButtonTitle: "OK")
                    alert.show()
                }
                
            }
        }) { (Error) in
            print(Error?.localizedDescription)
        }
    }
    
    
 // - - - - - - - - Apply CN spin data here
    func apiApplyCN(){
        
        let json: [String: Any] =
            ["ClientSecret":"201010","CIN":strCin,"Amount":totalAmount]
        
        print("Apply CN ------ ",json)
        
        DataManager.shared.makeAPICall(url: applyCnApi, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            
            DispatchQueue.main.async {
                do {
                    self.SpinCnElementMain = try JSONDecoder().decode([SpinCnElement].self, from: data!)
                    
                    let result = self.SpinCnElementMain[0].result
                    let msg = self.SpinCnElementMain[0].message
                  
                    if (result ?? false)
                    {
                        var alert = UIAlertView(title: "Successfully Applied For CN", message: "You've successfully applied for your CN. Please find details of your CN  in the Reports section of App!", delegate: nil, cancelButtonTitle: "OK")
                        alert.show()
                    }else{
                        var alert = UIAlertView(title: "Invalid", message: msg, delegate: nil, cancelButtonTitle: "OK")
                        alert.show()
                    }
                    
                    
                } catch let errorData {
                    print(errorData.localizedDescription)
                }
                
            }
        }) { (Error) in
            print(Error?.localizedDescription)
        }
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func rotateButton(_ sender: Any) {
   
        if (Utility.isConnectedToNetwork()) {
            // -- - - - - - on click of spin button
                let totalSpinsAvailable:Int? = Int(self.remainingSpins) ?? 0
            
            print("REM SPINS IN BUTTON CLICK   - - -",self.remainingSpins)
                
                if(self.isActiveSpin){
                    if(totalSpinsAvailable! > 0 && self.SpinElementMain[0].result ?? false){
                        if(self.startWheel){
                            self.startWheel = false
                            
                            print(self.nxtWinningIndex)
                            
                            self.spinningWheel.startAnimating()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                self.spinningWheel.startAnimating(fininshIndex: self.nxtWinningIndex ?? 1) { (finished) in
                                    print(finished)
                                    self.startWheel = true
                                    
                                    if((Int(self.remainingSpins) ?? 0) > 0){
                                        self.apiSetSpinData()
                                    }
                                 
                                }
                            }
                        }
                        
                    }else{
                        var alert = UIAlertView(title: "No Spin Available", message: "Oops! You've already claimed all your chances. You can order more combos to get more chances to play!", delegate: nil, cancelButtonTitle: "OK")
                        alert.show()
                    }
                }else{
                    var alert = UIAlertView(title: "Not yet started Sorry!", message: "We are yet to open! Please try after a few days!", delegate: nil, cancelButtonTitle: "OK")
                    alert.show()
                }
        }
        else {
            print("No internet connection available")
            var alert = UIAlertView(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
        }
        
    }
}


