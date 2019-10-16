//
//  FeedbackController.swift
//  DealorsApp
//
//  Created by Goldmedal on 3/29/18.
//  Copyright © 2018 Goldmedal. All rights reserved.
//

import UIKit
import FirebaseAnalytics

class FeedbackController: BaseViewController {

    @IBOutlet weak var menuFeedback: UIBarButtonItem!
    @IBOutlet weak var edtFeedback: UITextField!
    @IBOutlet weak var btnSubmit: UIButton!
    @IBOutlet weak var vwFloatRating: FloatRatingView!
    
    var feedback = [FeedbackElement]()
    var strCin = ""
    var feedbackApi=""
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addSlideMenuButton()
    
        // Do any additional setup after loading the view.
        let loginData =  UserDefaults.standard.value(forKey: "loginData") as? Dictionary ?? [:]
        strCin = loginData["userlogid"] as? String ?? ""
        
        let initialData =  UserDefaults.standard.value(forKey: "initialData") as? Dictionary ?? [:]
        feedbackApi = (initialData["baseApi"] as? String ?? "")+""+(initialData["sendFeedback"] as? String ?? "")
        
        Analytics.setScreenName("FEEDBACK SCREEN", screenClass: "FeedbackController")
    }

    @IBAction func clicked_feedback_submit(_ sender: UIButton) {
        
        if((edtFeedback.text?.trimmingCharacters(in: NSCharacterSet.whitespaces).count)!  < 1){
            var alert = UIAlertView(title: nil, message: "Message Cannot be Empty", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
        }else{
            if (Utility.isConnectedToNetwork()) {
                print("Internet connection available")
                self.apiFeedback()
            }
            else{
                print("No internet connection available")
                
                var alert = UIAlertView(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", delegate: nil, cancelButtonTitle: "OK")
                alert.show()
            }
        }
        
      
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func apiFeedback(){
      
          let json: [String: Any] =  ["CIN":strCin,"ClientSecret":"ClientSecret","Rating":Int(vwFloatRating.rating),"FeedbackText":edtFeedback.text]
        
        DataManager.shared.makeAPICall(url: feedbackApi, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            
            do {
                self.feedback = try JSONDecoder().decode([FeedbackElement].self, from: data!)
                
                let isSuccess = (self.feedback[0].result ?? false)!
                
                print(isSuccess)
                
                 if(isSuccess){
                    var alert = UIAlertView(title: "Success", message: "Feedback sent successfully", delegate: nil, cancelButtonTitle: "OK")
                    alert.show()
                    
                    self.edtFeedback.text = ""
                    
                    ViewControllerUtils.sharedInstance.removeLoader()
                 }
               else
                  {
                    var alert = UIAlertView(title: "Error", message: self.feedback[0].message, delegate: nil, cancelButtonTitle: "OK")
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
