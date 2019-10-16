//
//  ContactUsController.swift
//  DealorsApp
//
//  Created by Goldmedal on 3/29/18.
//  Copyright © 2018 Goldmedal. All rights reserved.
//

import UIKit
import FirebaseAnalytics

class ContactUsController: BaseViewController {

    @IBOutlet weak var lblHelplineNo: UILabel!
    @IBOutlet weak var lblEmailId: UILabel!
    @IBOutlet weak var lblBranchOfficeAddress: UILabel!
    @IBOutlet weak var lblBranchOfficeName: UILabel!
    @IBOutlet weak var lblHeadOfficeAddress: UILabel!
    @IBOutlet weak var lblHeadOfficeName: UILabel!
    @IBOutlet weak var menuContactUs: UIBarButtonItem!
    
    var textPhone = ""
     var textEmail = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addSlideMenuButton()
        
        //Add profile detail here
        let loginData =  UserDefaults.standard.value(forKey: "loginData") as? Dictionary ?? [:]
        
        self.lblBranchOfficeName.text = (loginData["branchnm"] as? String)!.capitalized
        self.lblBranchOfficeAddress.text = (loginData["branchadd"] as? String)!.capitalized
        
        //For email id
        if(loginData["branchemail"] as? String != ""){
            textEmail = (loginData["branchemail"] as? String)!.capitalized
        }else{
            textEmail = "NA"
        }
        let attributedTextEmail = NSMutableAttributedString(string: textEmail)
        attributedTextEmail.addAttribute(NSAttributedStringKey.underlineStyle, value: NSUnderlineStyle.styleSingle.rawValue, range: NSRange(location: 0, length: (textEmail.count)))
        self.lblEmailId.attributedText = attributedTextEmail
        
        let tapEmail = UITapGestureRecognizer(target: self, action: #selector(ContactUsController.tapFunctionEmail))
        self.lblEmailId.isUserInteractionEnabled = true
        self.lblEmailId.addGestureRecognizer(tapEmail)
     
        //For branch contact number
        if(loginData["branchphone"] as? String != ""){
            textPhone = (loginData["branchphone"] as? String)!
        }else{
            textPhone = "NA"
        }
        let attributedTextPhone = NSMutableAttributedString(string: textPhone)
        attributedTextPhone.addAttribute(NSAttributedStringKey.underlineStyle, value: NSUnderlineStyle.styleSingle.rawValue, range: NSRange(location: 0, length: (textPhone.count)))
        self.lblHelplineNo.attributedText = attributedTextPhone
        
        let tapPhone = UITapGestureRecognizer(target: self, action: #selector(ContactUsController.tapFunctionPhone))
        self.lblHelplineNo.isUserInteractionEnabled = true
        self.lblHelplineNo.addGestureRecognizer(tapPhone)
        
        Analytics.setScreenName("CONTACT US SCREEN", screenClass: "ContactUsController")
        
    }

    @objc func tapFunctionEmail(sender:UITapGestureRecognizer) {
        print("Email working")
        if(textEmail != "NA"){
        let url = URL(string: "mailto:\(textEmail)")
        UIApplication.shared.open(url!)
        }
    }
    
  @objc func tapFunctionPhone(sender:UITapGestureRecognizer) {
        print("Phone working")
        if(textPhone != "NA"){
        let url = URL(string: "tel://\(textPhone)")
        UIApplication.shared.open(url!)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   
}
