//
//  MyProfileController.swift
//  DealorsApp
//
//  Created by Goldmedal on 5/14/18.
//  Copyright © 2018 Goldmedal. All rights reserved.
//

import UIKit
import FirebaseAnalytics

class MyProfileController: BaseViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imvEditIcon: UIImageView!
    @IBOutlet weak var imvProfileImage: UIImageView!
    @IBOutlet weak var lblProfileName: UILabel!
    @IBOutlet weak var lblCinNo: UILabel!
    @IBOutlet weak var lblEmailId: UILabel!
    @IBOutlet weak var lblMobileNo: UILabel!
    @IBOutlet weak var lblGstNo: UILabel!
    @IBOutlet weak var lblFirmName: UILabel!
    @IBOutlet weak var lblExecutive: UILabel!
    @IBOutlet weak var lblExecHeadMobNo: UILabel!
    @IBOutlet weak var lblHeadBranch: UILabel!
    @IBOutlet weak var lblImmExecHead: UILabel!
    @IBOutlet weak var lblExecMobNo: UILabel!
    var imageData: Data? = nil
    var newUserApi = ""
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var strCin = ""
    var fromDealer = false
    
    var textExMobileNo = ""
    var textExHeadMobileNo = ""
    
    var validateCIN = [ValidateCINElement]()
    var validateCINObj = [ValidateCinData]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        addSlideMenuButton()
        
    
        self.imvProfileImage.layer.borderWidth = 2
        self.imvProfileImage.layer.masksToBounds = false
        self.imvProfileImage.layer.borderColor = UIColor.black.cgColor
        self.imvProfileImage.layer.cornerRadius = self.imvProfileImage.frame.size.width/2
        self.imvProfileImage.clipsToBounds = true
        
       //Add profile detail here
        let loginData =  UserDefaults.standard.value(forKey: "loginData") as? Dictionary ?? [:]
        let initialData =  UserDefaults.standard.value(forKey: "initialData") as? Dictionary ?? [:]
        newUserApi = (initialData["baseApi"] as? String ?? "")+""+(initialData["validateCIN"] as? String ?? "")
        if fromDealer{
           strCin = appDelegate.sendCin
        }else{
          strCin = loginData["userlogid"] as? String ?? ""
        }

        self.lblProfileName.text = (loginData["usernm"] as? String)?.capitalized
        self.lblEmailId.text = (loginData["email"] as? String)?.capitalized
        self.lblFirmName.text = (loginData["firmname"] as? String)?.capitalized
        self.lblCinNo.text = (loginData["userlogid"] as? String)?.capitalized
        self.lblGstNo.text = loginData["gstno"] as? String
        self.lblMobileNo.text = loginData["mobile"] as? String
        
        self.lblHeadBranch.text = (loginData["branchnm"] as? String)?.capitalized
        self.lblExecutive.text = (loginData["exname"] as? String)?.capitalized
        self.lblExecMobNo.text = loginData["exmobile"] as? String
        self.lblImmExecHead.text = (loginData["exhead"] as? String)?.capitalized
        self.lblExecHeadMobNo.text = loginData["exheadmobile"] as? String
        
        if(loginData["exmobile"] as? String != ""){
            textExMobileNo = (loginData["exmobile"] as? String)!
        }else{
             textExMobileNo = "NA"
        }
       
        if(loginData["exheadmobile"] as? String != ""){
            textExHeadMobileNo = (loginData["exheadmobile"] as? String)!
        }else{
            textExHeadMobileNo = "NA"
        }
        
        // ----------------- Executive mobile number
        let attributedExecMobNo = NSMutableAttributedString(string: textExMobileNo)
        attributedExecMobNo.addAttribute(NSAttributedStringKey.underlineStyle, value: NSUnderlineStyle.styleSingle.rawValue, range: NSRange(location: 0, length: (textExMobileNo.count)))
        self.lblExecMobNo.attributedText = attributedExecMobNo
        
        let tapExMobNo = UITapGestureRecognizer(target: self, action: #selector(self.tapFunctiontapExMobNo))
        self.lblExecMobNo.isUserInteractionEnabled = true
        self.lblExecMobNo.addGestureRecognizer(tapExMobNo)
        
        // ----------------- Executive head mobile number
        let attributedExecHeadMobNo = NSMutableAttributedString(string: textExHeadMobileNo)
        attributedExecHeadMobNo.addAttribute(NSAttributedStringKey.underlineStyle, value: NSUnderlineStyle.styleSingle.rawValue, range: NSRange(location: 0, length: (textExHeadMobileNo.count)))
        self.lblExecHeadMobNo.attributedText = attributedExecHeadMobNo
        
        let tapExHeadMobNo = UITapGestureRecognizer(target: self, action: #selector(self.tapFunctionExHeadMobNo))
        self.lblExecHeadMobNo.isUserInteractionEnabled = true
        self.lblExecHeadMobNo.addGestureRecognizer(tapExHeadMobNo)
    
        let tabEditImage = UITapGestureRecognizer(target: self, action: #selector(CaptchaView.tapFunction))
        imvEditIcon.addGestureRecognizer(tabEditImage)
        
        imageData = UserDefaults.standard.object(forKey: "SavedImage") as? Data ?? nil
        if(imageData != nil)
        {
            imvProfileImage.image = UIImage(data:imageData as! Data)
        }
        
        Analytics.setScreenName("MY PROFILE SCREEN", screenClass: "MyProfileController")
    }
    
    @objc func tapFunction(sender:UITapGestureRecognizer) {
        print("Edit Icon Clicked")
        chooseImage()
    }
    
  @objc  func tapFunctiontapExMobNo(sender:UITapGestureRecognizer) {
        print("Phone working")
        if(textExMobileNo != "NA"){
            let url = URL(string: "tel://\(textExMobileNo)")
            UIApplication.shared.open(url!)
        }
    }
    
   @objc  func tapFunctionExHeadMobNo(sender:UITapGestureRecognizer) {
        print("Phone working")
        if(textExHeadMobileNo != "NA"){
            let url = URL(string: "tel://\(textExHeadMobileNo)")
            UIApplication.shared.open(url!)
        }
    }
    
    
    func chooseImage(){

        let actionSheet = UIAlertController(title: "Photo Source", message: "Choose a Source", preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action:UIAlertAction) in
            self.openGallary(type: 1)

        }))
        
        actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { (action:UIAlertAction) in
            self.openGallary(type: 2)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        
        self.present(actionSheet, animated: true, completion: nil)
    }


    func openGallary(type: Int) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = (type == 1) ? .camera : .photoLibrary
        self.present(imagePickerController, animated: true, completion: nil)
    }

    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
       let profileImage = info[UIImagePickerControllerOriginalImage] as! UIImage
       
        let ImageData:NSData = UIImageJPEGRepresentation(profileImage, 1.0)! as NSData
        UserDefaults.standard.set(ImageData, forKey: "SavedImage")
        
        imageData = UserDefaults.standard.object(forKey: "SavedImage") as! NSData as Data
        
        imvProfileImage.image = UIImage(data:imageData as! Data)
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func clicked_change_password(_ sender: UIButton) {
        apiNewUser()
    }
    
    
    func apiNewUser(){
        ViewControllerUtils.sharedInstance.showLoader()
        
        let json: [String: Any] =
            ["CIN":strCin,"Category":"Party","ClientSecret":"sgupta"]
        
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
                    vcOtp.callFrom = "CHANGE"
                    vcOtp.strEmailid = self.validateCINObj[0].email ?? ""
                    vcOtp.strMobileNumber = self.validateCINObj[0].mobile ?? ""
                    vcOtp.strCin = self.strCin
                    
                    self.navigationController?.pushViewController(vcOtp, animated: true)
                    self.dismiss(animated: true, completion: nil)
                }
                
                ViewControllerUtils.sharedInstance.removeLoader()
            } catch let errorData {
                ViewControllerUtils.sharedInstance.removeLoader()
                print(errorData.localizedDescription)
            }
        }) { (Error) in
            print(Error?.localizedDescription)
            ViewControllerUtils.sharedInstance.removeLoader()
        }
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
