//
//  EmployeeDataController.swift
//  ManagementApp
//
//  Created by Goldmedal on 17/02/20.
//  Copyright © 2020 Goldmedal. All rights reserved.
//

import UIKit

class EmployeeDataController: BaseViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    //Outlets
    @IBOutlet weak var vwToday: UIView!
    @IBOutlet weak var vwMonthly: UIView!
    @IBOutlet weak var vwQuarterly: UIView!
    @IBOutlet weak var vwYearly: UIView!
    @IBOutlet weak var lblJoinM: UILabel!
    @IBOutlet weak var lblLeaveM: UILabel!
    @IBOutlet weak var lblJoinY: UILabel!
    @IBOutlet weak var lblLeaveY: UILabel!
    @IBOutlet weak var lblSaleQtrly: UILabel!
    @IBOutlet weak var lblPayQtrly: UILabel!
    @IBOutlet weak var lblSaleYrly: UILabel!
    @IBOutlet weak var lblPayYrly: UILabel!
    @IBOutlet weak var CollectionView: IntrinsicCollectionViews!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var btnState: RoundButton!
    @IBOutlet weak var btnBranch: RoundButton!
    @IBOutlet weak var sort: UIImageView!
    @IBOutlet weak var vwYearJoin: UIStackView!
    @IBOutlet weak var vwYearLeave: UIStackView!
    @IBOutlet weak var vwMonthJoin: UIStackView!
    @IBOutlet weak var vwMonthLeave: UIStackView!
    
     
    //Declarations...
    var apiDeptwise = ""
    var empDeptwise = [EmpDeptwise]()
    var empDeptwiseObj = [EmpDeptwiseObj]()
    var filteredDept = [EmpDeptwiseObj]()
    var apiDesigwise = ""
    var empDesigwisedata = [EmpDesigwise]()
    var empDesigwiseObj = [EmpDesigwiseObj]()
    var filteredDesig = [EmpDesigwiseObj]()
    var cellContentIdentifier = "\(CollectionViewCell.self)"
    var apiJoinDate = ""
    var empData = [EmpJoinData]()
    var empDataObj = [EmpJoinDataObj]()
    var showDesig = false
    var showMonthly = false
    var type = 0
    

    override func viewDidLoad() {
        super.viewDidLoad()
        apiDeptwise = "https://test2.goldmedalindia.in/api/getdeptwiseemployeecount"
        apiDesigwise = "https://test2.goldmedalindia.in/api/getdesignationemployeecount"
        apiJoinDate = "https://test2.goldmedalindia.in/api/getjoindatewiseempcount"
        addSlideMenuButton()
        ViewControllerUtils.sharedInstance.showLoader()
        apiGetEmployeeDept()
        apiGetJoin()
        let monthlyClick = UITapGestureRecognizer(target: self, action: #selector(self.clickedMonthly))
        vwMonthJoin.addGestureRecognizer(monthlyClick)
        let yearlyClick = UITapGestureRecognizer(target: self, action: #selector(self.clickedYearly))
        vwYearJoin.addGestureRecognizer(yearlyClick)
        
        let monthlyLeaveClick = UITapGestureRecognizer(target: self, action: #selector(self.clickedMonthlyL))
        vwMonthLeave.addGestureRecognizer(monthlyLeaveClick)
        let yearlyLeaveClick = UITapGestureRecognizer(target: self, action: #selector(self.clickedYearlyL))
        vwYearLeave.addGestureRecognizer(yearlyLeaveClick)
    }
    
    //Button Clicks...
    @objc func clickedMonthly(sender: UITapGestureRecognizer) {
        showMonthly = true
        type = 1
        performSegue(withIdentifier: "ByJoin", sender: self)
    }
    
    @objc func clickedYearly(sender: UITapGestureRecognizer) {
        showMonthly = false
        type = 1
        performSegue(withIdentifier: "ByJoin", sender: self)
    }
    
    @objc func clickedMonthlyL(sender: UITapGestureRecognizer) {
        showMonthly = true
        type = 2
        performSegue(withIdentifier: "ByJoin", sender: self)
    }
    
    @objc func clickedYearlyL(sender: UITapGestureRecognizer) {
        showMonthly = false
        type = 2
        performSegue(withIdentifier: "ByJoin", sender: self)
    }
    
    @IBAction func clickedDesig(_ sender: Any) {
        showDesig = true
        btnBranch.backgroundColor = UIColor.init(named: "primaryDark")
        btnState.backgroundColor = UIColor.white
        ViewControllerUtils.sharedInstance.showLoader()
        apiGetEmployeeDesig()
    }
    
    @IBAction func clickedDept(_ sender: Any) {
        showDesig = false
        btnBranch.backgroundColor = UIColor.white
        btnState.backgroundColor = UIColor.init(named: "primaryDark")
        ViewControllerUtils.sharedInstance.showLoader()
        apiGetEmployeeDept()
    }
    
    
    //CollectionView Functions...
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if showDesig {
            return self.filteredDesig.count + 1
        } else {
           return self.filteredDept.count + 1
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = CollectionView.dequeueReusableCell(withReuseIdentifier: cellContentIdentifier,
                                                      for: indexPath) as! CollectionViewCell
        cell.layer.borderWidth = 1
        cell.layer.borderColor = UIColor.white.cgColor
        //Header of CollectionView...
        if indexPath.section == 0 {
            cell.contentLabel.font = UIFont(name: "Roboto-Medium", size: 16)
            if #available(iOS 11.0, *) {
                cell.backgroundColor = UIColor.init(named: "Primary")
            } else {
                cell.backgroundColor = UIColor.gray
            }
            switch indexPath.row{
            case 0:
                cell.contentLabel.text = (showDesig) ?"Designation Name" : "Department Name"
            case 1:
                cell.contentLabel.text = "Employee Count"
            default:
                break
            }
            
        }
        else {
            cell.contentLabel.font = UIFont(name: "Roboto-Regular", size: 14)
            if #available(iOS 11.0, *) {
                cell.backgroundColor = UIColor.init(named: "primaryLight")
            } else {
                cell.backgroundColor = UIColor.lightGray
            }
            
            switch indexPath.row{
            case 0:
                cell.contentLabel.text = (showDesig) ? filteredDesig[indexPath.section-1].designationName : filteredDept[indexPath.section-1].departmentName
            case 1:
                cell.contentLabel.text = (showDesig) ? String(filteredDesig[indexPath.section-1].empCount!) : String(filteredDept[indexPath.section-1].empCount!)
            default:
                break
            }
            
        }
        
        return cell
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "ByJoin") {
            if let destination = segue.destination as? EmpChildViewController{
                destination.joinleave = true
                destination.type = type
                destination.monthly = showMonthly ? true : false
                (destination.fromDate, destination.toDate) = showMonthly ? Utility.getMonthly() : Utility.yearDate()
                
            }else{
                
            }
        }else{
            if let destination = segue.destination as? EmpChildViewController,
                let index = CollectionView.indexPathsForSelectedItems?.first{
                if showDesig{
                    destination.desigToReceive = [filteredDesig[index.section-1]]
                    destination.desigwise = true
                }else{
                    destination.deptToReceive = [filteredDept[index.section-1]]
                    destination.deptwise = true
                }
                
            }
        }
        
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if let index = CollectionView.indexPathsForSelectedItems?.first{
            if((index.section) > 0){
                if showDesig{
                    if index.section == self.filteredDesig.count + 1{
                        return false
                    }else{
                        return true
                    }
                }else{
                    if index.section == self.filteredDept.count + 1{
                        return false
                    }else{
                        return true
                    }
                }
            }else{
                return false
            }
        }else{
            return false
        }
        
        
    }
    
    
 
    //API CALLS..............
    func apiGetEmployeeDept(){
        
        let json: [String: Any] = ["CIN":UserDefaults.standard.value(forKey: "userCIN") as! String,"Cat":UserDefaults.standard.value(forKey: "userCategory") as! String,"ClientSecret":"ClientSecret"]
        
        let manager =  DataManager.shared
        print("Get Emp Dept Params \(json)")
        manager.makeAPICall(url: apiDeptwise, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            
            do {
                self.empDeptwise = try JSONDecoder().decode([EmpDeptwise].self, from: data!)
                self.empDeptwiseObj = self.empDeptwise[0].data
                self.filteredDept = self.empDeptwise[0].data
                print("Get Emp Dept Data \(self.empDeptwise[0].data)")
                self.CollectionView.reloadData()
                self.CollectionView.collectionViewLayout.invalidateLayout()
                ViewControllerUtils.sharedInstance.removeLoader()
            } catch let errorData {
                print(errorData.localizedDescription)
                ViewControllerUtils.sharedInstance.removeLoader()
            }
        }) { (Error) in
            print(Error?.localizedDescription as Any)
            ViewControllerUtils.sharedInstance.removeLoader()
        }
        
    }
    
    func apiGetEmployeeDesig(){
        
        let json: [String: Any] = ["CIN":UserDefaults.standard.value(forKey: "userCIN") as! String,"Cat":UserDefaults.standard.value(forKey: "userCategory") as! String,"ClientSecret":"ClientSecret"]
        
        let manager =  DataManager.shared
        print("Get Emp Desig Params \(json)")
        manager.makeAPICall(url: apiDesigwise, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            
            do {
                self.empDesigwisedata = try JSONDecoder().decode([EmpDesigwise].self, from: data!)
                self.empDesigwiseObj = self.empDesigwisedata[0].data
                self.filteredDesig = self.empDesigwisedata[0].data
                print("Get Emp Desig Data \(self.empDesigwisedata[0].data)")
                self.CollectionView.reloadData()
                self.CollectionView.collectionViewLayout.invalidateLayout()
                ViewControllerUtils.sharedInstance.removeLoader()
            } catch let errorData {
                print(errorData.localizedDescription)
                ViewControllerUtils.sharedInstance.removeLoader()
            }
        }) { (Error) in
            print(Error?.localizedDescription as Any)
            ViewControllerUtils.sharedInstance.removeLoader()
        }
        
    }
    
    func apiGetJoin(){
        
        let json: [String: Any] = ["CIN":UserDefaults.standard.value(forKey: "userCIN") as! String,"Cat":UserDefaults.standard.value(forKey: "userCategory") as! String,"ClientSecret":"ClientSecret"]
        
        let manager =  DataManager.shared
        print("Get Join Params \(json)")
        manager.makeAPICall(url: apiJoinDate, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            
            do {
                self.empData = try JSONDecoder().decode([EmpJoinData].self, from: data!)
                self.empDataObj = self.empData[0].data
                self.lblJoinM.text = String(self.empDataObj[0].monthCount!)
                self.lblJoinY.text = String(self.empDataObj[0].yearCount!)
                self.lblLeaveM.text = String(self.empDataObj[0].monthCountLeaving!)
                self.lblLeaveY.text = String(self.empDataObj[0].yearCountLeaving!)
                print("Get Join Data \(self.empData[0].data)")
                self.CollectionView.reloadData()
                self.CollectionView.collectionViewLayout.invalidateLayout()
                ViewControllerUtils.sharedInstance.removeLoader()
            } catch let errorData {
                print(errorData.localizedDescription)
                ViewControllerUtils.sharedInstance.removeLoader()
            }
        }) { (Error) in
            print(Error?.localizedDescription as Any)
            ViewControllerUtils.sharedInstance.removeLoader()
        }
        
    }
    
    

}
