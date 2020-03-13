//
//  EmployeeInfoController.swift
//  ManagementApp
//
//  Created by Goldmedal on 27/02/20.
//  Copyright © 2020 Goldmedal. All rights reserved.
//

import UIKit
import MessageUI

class EmployeeInfoController: UIViewController {
    
    //Outlets...
    @IBOutlet weak var workButton: UILabel!
    @IBOutlet weak var personalButton: UILabel!
    @IBOutlet weak var workUnderline: UIView!
    @IBOutlet weak var personalUnderline: UIView!
    @IBOutlet weak var workVw: UIView!
    @IBOutlet weak var personalVw: UIView!
    
    @IBOutlet weak var dept: UILabel!
    @IBOutlet weak var desig: UILabel!
    @IBOutlet weak var branch: UILabel!
    @IBOutlet weak var locn: UILabel!
    @IBOutlet weak var deptName: UILabel!
    @IBOutlet weak var desigName: UILabel!
    @IBOutlet weak var branchName: UILabel!
    @IBOutlet weak var locnName: UILabel!
    @IBOutlet weak var joining: UILabel!
    @IBOutlet weak var joningDate: UILabel!
    @IBOutlet weak var workexp: UILabel!
    @IBOutlet weak var workexpData: UILabel!
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var titleDesig: UILabel!
    @IBOutlet weak var empCode: UILabel!
    
    //Declarations...
    var showWork = true
    var employeeInfo = [EmployeeInfo]()
    var employeeInfoObj = [EmployeeInfoObj]()
    var apiGetEmpInfo = ""
    var slno = 0
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    override func viewDidLoad() {
        super.viewDidLoad()
        
        apiGetEmpInfo = "https://api.goldmedalindia.in/api/getemployeedetailList"
        let workClick = UITapGestureRecognizer(target: self, action: #selector(self.clickedWork))
        workVw.addGestureRecognizer(workClick)
        let personalClick = UITapGestureRecognizer(target: self, action: #selector(self.clickedPersonal))
        personalVw.addGestureRecognizer(personalClick)
        let phoneDial = UITapGestureRecognizer(target: self, action: #selector(self.clickedNumber))
        desigName.addGestureRecognizer(phoneDial)
        let sendEmail = UITapGestureRecognizer(target: self, action: #selector(self.clickedMail))
        branchName.addGestureRecognizer(sendEmail)
        ViewControllerUtils.sharedInstance.showLoader()
        apiGetEmpInformation()
    }
    
    @objc func clickedWork(sender: UITapGestureRecognizer) {
        showWork = true
        workButton.textColor = UIColor.black
        workUnderline.backgroundColor = UIColor.black
        personalButton.textColor = UIColor.init(named: "primaryDark")
        personalUnderline.backgroundColor = UIColor.white
        dept.text = "Department"
        deptName.text = employeeInfoObj[0].department
        desig.text = "Designation"
        desigName.text = employeeInfoObj[0].designation
        desigName.textColor = UIColor.black
        branch.text = "Branch"
        branchName.text = employeeInfoObj[0].branch
        branchName.textColor = UIColor.black
        locn.text = "Location / Sub-Location"
        locnName.text = "\(employeeInfoObj[0].location!) / \(employeeInfoObj[0].sublocation!)"
        joining.text = "Joining Date"
        joningDate.text = employeeInfoObj[0].joinDate
        workexp.text = "Work Experience"
        workexpData.text = employeeInfoObj[0].workExp
    }
    
    @objc func clickedPersonal(sender: UITapGestureRecognizer) {
        showWork = false
        personalButton.textColor = UIColor.black
        personalUnderline.backgroundColor = UIColor.black
        workButton.textColor = UIColor.init(named: "primaryDark")
        workUnderline.backgroundColor = UIColor.white
        dept.text = "DOB"
        deptName.text = employeeInfoObj[0].dob
        desig.text = "Contact No"
        desigName.text = employeeInfoObj[0].contactNo
        desigName.textColor = UIColor(named: "ColorBlue")
        branch.text = "Email"
        branchName.text = employeeInfoObj[0].email
        branchName.textColor = UIColor(named: "ColorBlue")
        locn.text = "Address"
        locnName.text = employeeInfoObj[0].address
        joining.text = "Father's Name"
        joningDate.text = employeeInfoObj[0].father
        workexp.text = "Mother's Name"
        workexpData.text = employeeInfoObj[0].mother
        
    }
    
    func fillData(){
        empCode.text = employeeInfoObj[0].empcode
        name.text = employeeInfoObj[0].name
        titleDesig.text = employeeInfoObj[0].designation
        deptName.text = employeeInfoObj[0].department
        desigName.text = employeeInfoObj[0].designation
        branchName.text = employeeInfoObj[0].branch
        locn.text = "Location / Sub-Location"
        locnName.text = "\(employeeInfoObj[0].location!) / \(employeeInfoObj[0].sublocation!)"
        joningDate.text = employeeInfoObj[0].joinDate
        workexpData.text = employeeInfoObj[0].workExp
    }
    
    @objc func clickedNumber(sender: UITapGestureRecognizer) {
        if !showWork{
            dialNumber(number : desigName.text!)
        }
    }
    
    func dialNumber(number : String) {
            if let url = URL(string: "tel://\(number)"),
                UIApplication.shared.canOpenURL(url) {
                if #available(iOS 10, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler:nil)
                } else {
                    UIApplication.shared.openURL(url)
                }
            } else {
                // add error message here
            }
    }
    
    @objc func clickedMail(sender: UITapGestureRecognizer) {
        if !showWork{
            sendMail()
        }
    }
    
    func sendMail(){
        let email = employeeInfoObj[0].email
        if let url = URL(string: "mailto:\(email!)") {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    //API Function...
    func apiGetEmpInformation(){
        let json: [String: Any] = ["CIN":UserDefaults.standard.value(forKey: "userCIN") as! String,"Category":UserDefaults.standard.value(forKey: "userCategory") as! String,"ClientSecret":"ClientSecret","slno":slno]
        let manager =  DataManager.shared
        print("vendorArray Params \(json)")
        manager.makeAPICall(url: apiGetEmpInfo, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            
            do {
                self.employeeInfo = try JSONDecoder().decode([EmployeeInfo].self, from: data!)
                self.employeeInfoObj  = self.employeeInfo[0].data
                print("Emp Info Result \(self.employeeInfo[0].data)")
                self.fillData()
                ViewControllerUtils.sharedInstance.removeLoader()
                
            } catch let errorData {
                print("Caught Error ------>\(errorData.localizedDescription)")
                ViewControllerUtils.sharedInstance.removeLoader()
            }
        }) { (Error) in
            print("Error -------> \(Error?.localizedDescription as Any)")
            ViewControllerUtils.sharedInstance.removeLoader()
        }
        
    }
 
}
