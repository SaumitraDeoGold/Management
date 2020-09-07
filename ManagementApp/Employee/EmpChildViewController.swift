//
//  EmpChildViewController.swift
//  ManagementApp
//
//  Created by Goldmedal on 11/02/20.
//  Copyright © 2020 Goldmedal. All rights reserved.
//

import UIKit
import Charts

class EmpChildViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate{
    //Outlets...
    @IBOutlet weak var CollectionView: IntrinsicCollection!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var CollectionViewTwo: IntrinsicCollection!
    @IBOutlet weak var heightConstraintTwo: NSLayoutConstraint!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var monthHeader: UIView!
    @IBOutlet weak var secondList: UIView!
    @IBOutlet weak var scrollVw: UIScrollView!
    @IBOutlet weak var vwHeaderBar: UIView!
    @IBOutlet weak var vwBarChart: UIView!
    @IBOutlet var barChart: BarChartDataSet!
    //@IBOutlet weak var noDataView: NoDataView!
    
    //Declarations...
    var cellContentIdentifier = "\(CollectionViewCell.self)"
    var employeeChild = [EmployeeChild]()
    var employeeChildObj = [EmployeeChildObj]()
    var filteredItems = [EmployeeChildObj]()
    var tempArray = [EmployeeChildObj]()
    var dataToReceive = [EmployeeDataObj]()
    var deptToReceive = [EmpDeptwiseObj]()
    var desigToReceive = [EmpDesigwiseObj]()
    var dataForLocn = [EmpLocationObj]()
    var empDeptChild = [EmpDeptChild]()
    var empDeptChildObj = [EmpDeptChildObj]()
    var filteredDept = [EmpDeptChildObj]()
    var tempDept = [EmpDeptChildObj]()
    var apiEmployeeDetails = ""
    var apiDeptDetails = ""
    var apiDesigDetails = ""
    var apiJoinLeave = ""
    var apiEmpLocn = ""
    var apiEmpMonthly = ""
    var empDesigChild = [EmpDesigChild]()
    var empDesigChildObj = [EmpDesigChildObj]()
    var filteredDesig = [EmpDesigChildObj]()
    var tempDesig = [EmpDesigChildObj]()
    var empJoinLeave = [EmpJoinLeave]()
    var empJoinLeaveObj = [EmpJoinLeaveObj]()
    var filteredJoin = [EmpJoinLeaveObj]()
    var tempJoin = [EmpJoinLeaveObj]()
    var empLocn = [EmpLocChild]()
    var empLocnObj = [EmpLocChildObj]()
    var filteredLocn = [EmpLocChildObj]()
    var tempLocn = [EmpLocChildObj]()
    var empMonthly = [EmpMonthlyCount]()
    var empMonthlyObj = [EmpMonthlyCountObj]()
    var deptwise = false
    var desigwise = false
    var joinleave = false
    var location = false
    var monthly = false
    var fromDate = ""
    var toDate = ""
    var noOfColumns = Int()
    var type = 0
    var monthEnds = ["30/","31/","30/","31/","31/","30/","31/","30/","31/","31/","29/","31/"]
    var months = ["04/","05/","06/","07/","08/","09/","10/","11/","12/","01/","02/","03/"]
    var slno = 0
    var counter = 0
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        vwHeaderBar.isHidden = true
        vwBarChart.isHidden = true
        if !monthly {
            monthHeader.isHidden = true
            secondList.isHidden = true
            vwHeaderBar.isHidden = true
            vwBarChart.isHidden = true
        }
        noOfColumns = 8
        if joinleave {
            noOfColumns = 9
            if type == 1 {
              self.title = "Joining Data"
            }else if type == 2{
              self.title = "Leaving Data"
            }
            getJoinLeave()
            if monthly {
                getMonthlyCount()
            }
        }else if location {
            noOfColumns = 10
            self.title = self.dataForLocn[0].locationName
            getLocationwise()
        }else if deptwise {
            self.title = self.deptToReceive[0].departmentName
            getDeptDetails()
        }else if desigwise {
            self.title = self.desigToReceive[0].designationName
            getDesigDetails()
        } else{
            apiGetEmployeeDetails()
            self.title = self.dataToReceive[0].branchName
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        apiEmployeeDetails = "https://test2.goldmedalindia.in/api/getEmployeeListDetails"
        apiDeptDetails = "https://test2.goldmedalindia.in/api/getdepartmentwiseempdetail"
        apiDesigDetails = "https://test2.goldmedalindia.in/api/getdesignationwiseempdetail"
        apiJoinLeave = "https://test2.goldmedalindia.in/api/getjoindatewiseempdata"
        apiEmpLocn = "https://test2.goldmedalindia.in/api/getlocationEmployeeListDetails"
        apiEmpMonthly = "https://api.goldmedalindia.in/api/getmonthwiseempjoincount"
        //self.noDataView.hideView(view: self.noDataView)
        ViewControllerUtils.sharedInstance.showLoader()
    }
    
    
    
    //Auto-Complete Function...
    @objc func searchRecords(_ textfield: UITextField){
        self.filteredItems.removeAll()
        if textfield.text?.count != 0{
            for dealers in tempArray{
                let range = dealers.employeeName!.lowercased().range(of: textfield.text!, options: .caseInsensitive, range: nil, locale: nil)
                let des = dealers.employeeCode!.lowercased().range(of: textfield.text!, options: .caseInsensitive, range: nil, locale: nil)
                let num = dealers.mobileNumber!.lowercased().range(of: textfield.text!, options: .caseInsensitive, range: nil, locale: nil)
                let dept = dealers.department!.lowercased().range(of: textfield.text!, options: .caseInsensitive, range: nil, locale: nil)
                if range != nil{
                    filteredItems.append(dealers)
                }else if des != nil{
                    filteredItems.append(dealers)
                }else if num != nil{
                    filteredItems.append(dealers)
                }else if dept != nil{
                    filteredItems.append(dealers)
                }
            }
        }else{
            for dealers in tempArray{
                filteredItems.append(dealers)
            }
        }
        self.heightConstraint.constant = CGFloat((((self.filteredItems.count+1) * 45) + 10))
        self.CollectionView.reloadData()
        self.CollectionView.collectionViewLayout.invalidateLayout()
    }
    
    @objc func searchDepts(_ textfield: UITextField){
        self.filteredDept.removeAll()
        if textfield.text?.count != 0{
            for dealers in tempDept{
                let range = dealers.employeeName!.lowercased().range(of: textfield.text!, options: .caseInsensitive, range: nil, locale: nil)
                let des = dealers.designationName!.lowercased().range(of: textfield.text!, options: .caseInsensitive, range: nil, locale: nil)
                let num = dealers.mobileNumber!.lowercased().range(of: textfield.text!, options: .caseInsensitive, range: nil, locale: nil)
                let branch = dealers.branchname!.lowercased().range(of: textfield.text!, options: .caseInsensitive, range: nil, locale: nil)
                if range != nil{
                    filteredDept.append(dealers)
                }else if des != nil{
                    filteredDept.append(dealers)
                }else if num != nil{
                    filteredDept.append(dealers)
                }else if branch != nil{
                    filteredDept.append(dealers)
                }
            }
        }else{
            for dealers in tempDept{
                filteredDept.append(dealers)
            }
        }
        self.heightConstraint.constant = CGFloat((((self.filteredDept.count+1) * 45) + 10))
        self.CollectionView.reloadData()
        self.CollectionView.collectionViewLayout.invalidateLayout()
    }
    
    @objc func searchDesig(_ textfield: UITextField){
        self.filteredDesig.removeAll()
        if textfield.text?.count != 0{
            for dealers in tempDesig{
                let range = dealers.employeeName!.lowercased().range(of: textfield.text!, options: .caseInsensitive, range: nil, locale: nil)
                let dept = dealers.departmentname!.lowercased().range(of: textfield.text!, options: .caseInsensitive, range: nil, locale: nil)
                let num = dealers.mobileNumber!.lowercased().range(of: textfield.text!, options: .caseInsensitive, range: nil, locale: nil)
                let branch = dealers.branchname!.lowercased().range(of: textfield.text!, options: .caseInsensitive, range: nil, locale: nil)
                if range != nil{
                    filteredDesig.append(dealers)
                }else if dept != nil{
                    filteredDesig.append(dealers)
                }else if num != nil{
                    filteredDesig.append(dealers)
                }else if branch != nil{
                    filteredDesig.append(dealers)
                }
            }
        }else{
            for dealers in tempDept{
                filteredDept.append(dealers)
            }
        }
        self.heightConstraint.constant = CGFloat((((self.filteredDesig.count+1) * 45) + 10))
        self.CollectionView.reloadData()
        self.CollectionView.collectionViewLayout.invalidateLayout()
    }
    
    @objc func searchJoins(_ textfield: UITextField){
        self.filteredJoin.removeAll()
        if textfield.text?.count != 0{
            for dealers in tempJoin{
                let range = dealers.employeeName!.lowercased().range(of: textfield.text!, options: .caseInsensitive, range: nil, locale: nil)
                let des = dealers.employeeCode!.lowercased().range(of: textfield.text!, options: .caseInsensitive, range: nil, locale: nil)
                let num = dealers.mobileNumber!.lowercased().range(of: textfield.text!, options: .caseInsensitive, range: nil, locale: nil)
                let dept = dealers.departmentName!.lowercased().range(of: textfield.text!, options: .caseInsensitive, range: nil, locale: nil)
                if range != nil{
                    filteredJoin.append(dealers)
                }else if des != nil{
                    filteredJoin.append(dealers)
                }else if num != nil{
                    filteredJoin.append(dealers)
                }else if dept != nil{
                    filteredJoin.append(dealers)
                }
            }
        }else{
            for dealers in tempJoin{
                filteredJoin.append(dealers)
            }
        }
        self.heightConstraint.constant = CGFloat((((self.filteredJoin.count+1) * 45) + 10))
        self.CollectionView.reloadData()
        self.CollectionView.collectionViewLayout.invalidateLayout()
    }
    
    @objc func searchLocn(_ textfield: UITextField){
        self.filteredLocn.removeAll()
        if textfield.text?.count != 0{
            for dealers in tempLocn{
                let range = dealers.employeeName!.lowercased().range(of: textfield.text!, options: .caseInsensitive, range: nil, locale: nil)
                let des = dealers.employeeCode!.lowercased().range(of: textfield.text!, options: .caseInsensitive, range: nil, locale: nil)
                let num = dealers.mobileNumber!.lowercased().range(of: textfield.text!, options: .caseInsensitive, range: nil, locale: nil)
                let dept = dealers.department!.lowercased().range(of: textfield.text!, options: .caseInsensitive, range: nil, locale: nil)
                
                if range != nil{
                    filteredLocn.append(dealers)
                }else if des != nil{
                    filteredLocn.append(dealers)
                }else if num != nil{
                    filteredLocn.append(dealers)
                }else if dept != nil{
                    filteredLocn.append(dealers)
                }
            }
        }else{
            for dealers in tempLocn{
                filteredLocn.append(dealers)
            }
        }
        self.heightConstraint.constant = CGFloat((((self.filteredLocn.count+1) * 45) + 10))
        self.CollectionView.reloadData()
        self.CollectionView.collectionViewLayout.invalidateLayout()
    }
    
    //CollectionView Functions...
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if collectionView == self.CollectionViewTwo{
            return empMonthlyObj.count + 1
        }else{
            if deptwise {
                return self.filteredDept.count+1
            }else if desigwise {
                return self.filteredDesig.count+1
            }else if joinleave {
                return self.filteredJoin.count+1
            }else if location {
                return self.filteredLocn.count+1
            }else{
                return self.filteredItems.count+1
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.CollectionViewTwo{
            return 3
        }else{
           return noOfColumns
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.CollectionViewTwo{
            let cell = CollectionView.dequeueReusableCell(withReuseIdentifier: cellContentIdentifier,
                                                          for: indexPath) as! CollectionViewCell
            
            cell.layer.borderWidth = 1
            cell.layer.borderColor = UIColor.white.cgColor
            if indexPath.section == 0 {
                cell.contentLabel.font = UIFont(name: "Roboto-Medium", size: 16)
                if #available(iOS 11.0, *) {
                    cell.backgroundColor = UIColor.init(named: "Primary")
                } else {
                    cell.backgroundColor = UIColor.gray
                }
                switch indexPath.row{
                case 0:
                    cell.contentLabel.text = "Month Name"
                case 1:
                    cell.contentLabel.text = "Joining Count"
                case 2:
                    cell.contentLabel.text = "Leaving Count"
                default:
                    break
                }
                //cell.backgroundColor = UIColor.lightGray
            } else {
                cell.contentLabel.font = UIFont(name: "Roboto-Regular", size: 14)
                if #available(iOS 11.0, *) {
                    cell.backgroundColor = UIColor.init(named: "primaryLight")
                } else {
                    cell.backgroundColor = UIColor.lightGray
                }
                switch indexPath.row{
                case 0:
                    cell.contentLabel.text = empMonthlyObj[indexPath.section - 1].month
                case 1:
                        cell.contentLabel.text = String(empMonthlyObj[indexPath.section - 1].empCount!)
                case 2:
                        cell.contentLabel.text = String(empMonthlyObj[indexPath.section - 1].leave!)
                default:
                    break
                }
                //cell.backgroundColor = UIColor.groupTableViewBackground
            }
            return cell
        }else{
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
                cell.contentLabel.attributedText = setText(value: "SlNo")
            case 1:
                cell.contentLabel.attributedText = setText(value: "Employee Name")
            case 2:
                cell.contentLabel.attributedText = location ? setText(value: "BranchName") : deptwise ? setText(value: "BranchName") : desigwise ? setText(value: "BranchName") :  joinleave ? setText(value: "BranchName") : setText(value: "Designation")
            case 3:
                cell.contentLabel.attributedText = location ? setText(value: "Sub-Location") :  deptwise ? setText(value: "Designation") :desigwise ? setText(value: "Department Name") : joinleave ? setText(value: "Designation") : setText(value: "Department")
            case 4:
                cell.contentLabel.attributedText = location ? setText(value: "Department") :  joinleave ? setText(value: "Department") : setText(value: "Joining Date")
            case 5:
                cell.contentLabel.attributedText = setText(value: "Location")
            case 6:
                cell.contentLabel.attributedText = location ? setText(value: "Designation") :  joinleave ? setText(value: "Joining Date") : setText(value: "Working Period")
            case 7:
                cell.contentLabel.attributedText = location ? setText(value: "Joining Date") :  joinleave ? setText(value: "Working Period") : setText(value: "Mobile No")
            case 8:
                cell.contentLabel.attributedText = location ? setText(value: "Working Period") : setText(value: "Mobile No")
            case 9:
                cell.contentLabel.attributedText = setText(value: "Mobile No")
             
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
                cell.contentLabel.attributedText = setText(value: "\(indexPath.section)")
            case 1:
                cell.contentLabel.attributedText = location ? setText(value: filteredLocn[indexPath.section-1].employeeName ?? "-") : deptwise ? setText(value: filteredDept[indexPath.section-1].employeeName ?? "-") : desigwise ? setText(value: filteredDesig[indexPath.section-1].employeeName ?? "-") : joinleave ? setText(value: filteredJoin[indexPath.section-1].employeeName ?? "-") : setText(value: filteredItems[indexPath.section-1].employeeName ?? "-")
            case 2:
                cell.contentLabel.attributedText = location ? setText(value: filteredLocn[indexPath.section-1].branchName ?? "-") : deptwise ? setText(value: filteredDept[indexPath.section-1].branchname ?? "-") : desigwise ? setText(value: filteredDesig[indexPath.section-1].branchname ?? "-") :  joinleave ? setText(value: filteredJoin[indexPath.section-1].branchname ?? "-") : setText(value: filteredItems[indexPath.section-1].employeeCode ?? "-")
            case 3:
                cell.contentLabel.attributedText = location ? setText(value: filteredLocn[indexPath.section-1].sublocation ?? "-") : deptwise ? setText(value: filteredDept[indexPath.section-1].designationName ?? "-") : desigwise ? setText(value: filteredDesig[indexPath.section-1].departmentname ?? "-") :  joinleave ? setText(value: filteredJoin[indexPath.section-1].designationName ?? "-") : setText(value: filteredItems[indexPath.section-1].department ?? "-")
            case 4:
                cell.contentLabel.attributedText = location ? setText(value: filteredLocn[indexPath.section-1].department ?? "-") : deptwise ? setText(value: filteredDept[indexPath.section-1].joinDate ?? "-") : desigwise ? setText(value: filteredDesig[indexPath.section-1].joinDate ?? "-") :  joinleave ? setText(value: filteredJoin[indexPath.section-1].departmentName ?? "-") : setText(value: filteredItems[indexPath.section-1].joinDate ?? "-")
            case 5:
                cell.contentLabel.attributedText = location ? setText(value: filteredLocn[indexPath.section-1].location ?? "-") : deptwise ? setText(value: filteredDept[indexPath.section-1].location ?? "-") : desigwise ? setText(value: filteredDesig[indexPath.section-1].location ?? "-") :  joinleave ? setText(value: filteredJoin[indexPath.section-1].location ?? "-") : setText(value: filteredItems[indexPath.section-1].location ?? "-")
            case 6:
                cell.contentLabel.attributedText = location ? setText(value: filteredLocn[indexPath.section-1].employeeCode ?? "-") : deptwise ? setText(value: filteredDept[indexPath.section-1].workYear ?? "-") : desigwise ? setText(value: filteredDesig[indexPath.section-1].workYear ?? "-") :  joinleave ? setText(value: filteredJoin[indexPath.section-1].joinDate ?? "-") : setText(value: filteredItems[indexPath.section-1].workYear ?? "-")
            case 7:
                let attributedString = NSAttributedString(string: NSLocalizedString(location ?filteredLocn[indexPath.section-1].mobileNumber! : deptwise ?filteredDept[indexPath.section-1].mobileNumber! : (desigwise ? filteredDesig[indexPath.section-1].mobileNumber :  joinleave ? filteredJoin[indexPath.section-1].mobileNumber : filteredItems[indexPath.section-1].mobileNumber!)!, comment: ""), attributes:[
                    NSAttributedString.Key.foregroundColor : UIColor(named: "ColorBlue")!,
                    NSAttributedString.Key.underlineStyle:1.0
                    ])
                cell.contentLabel.attributedText = location ? setText(value: filteredLocn[indexPath.section-1].joinDate ?? "-") : joinleave ? setText(value: filteredJoin[indexPath.section-1].workYear ?? "-") : attributedString
            case 8:
                let attributedString = NSAttributedString(string: NSLocalizedString((location ?filteredLocn[indexPath.section-1].mobileNumber! : filteredJoin[indexPath.section-1].mobileNumber!), comment: ""), attributes:[
                    NSAttributedString.Key.foregroundColor : UIColor(named: "ColorBlue")!,
                    NSAttributedString.Key.underlineStyle:1.0
                    ])
                cell.contentLabel.attributedText = location ? setText(value: filteredLocn[indexPath.section-1].workYear ?? "-") : attributedString
            case 9:
                let attributedString = NSAttributedString(string: NSLocalizedString((filteredLocn[indexPath.section-1].mobileNumber!), comment: ""), attributes:[
                    NSAttributedString.Key.foregroundColor : UIColor(named: "ColorBlue")!,
                    NSAttributedString.Key.underlineStyle:1.0
                    ])
                cell.contentLabel.attributedText = attributedString
            default:
                break
            }
            
        }
        
        return cell}
        
    }
    
    
    
    func setText(value: String) -> NSAttributedString{
        let attributedString = NSAttributedString(string: NSLocalizedString(value, comment: ""), attributes:[
            NSAttributedString.Key.foregroundColor : UIColor.black
            ])
        return attributedString
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == self.CollectionViewTwo{
            var splitDate = self.empMonthlyObj[indexPath.section-1].month!.split{$0 == "-"}.map(String.init)
            fromDate = "\(months[indexPath.section-1])01/\(splitDate[1])"
            toDate = "\(months[indexPath.section-1])\(monthEnds[indexPath.section-1])\(splitDate[1])"
            if indexPath.row == 1{
                if empMonthlyObj[indexPath.section-1].empCount == 0{
                    let alert = UIAlertController(title: "No Data", message: "Employee Joining Count is Zero", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    return
                }
                type = 1
                getJoinLeave()
                scrollVw.setContentOffset(CGPoint.zero, animated: true)
            }else if indexPath.row == 2{
                if empMonthlyObj[indexPath.section-1].leave == 0{
                    let alert = UIAlertController(title: "No Data", message: "Employee Leave Count is Zero", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    return
                }
                type = 2
                getJoinLeave()
                scrollVw.setContentOffset(CGPoint.zero, animated: true)
            }
            
        }else{
            if indexPath.row == 7{
                if deptwise{
                    dialNumber(number: filteredDept[indexPath.section-1].mobileNumber!)
                }else if desigwise{
                    dialNumber(number: filteredDesig[indexPath.section-1].mobileNumber!)
                }else{
                    dialNumber(number: filteredItems[indexPath.section-1].mobileNumber!)
                }
                
            }else if indexPath.row == 7{
                dialNumber(number: filteredItems[indexPath.section-1].mobileNumber!)
            }else if indexPath.row == 8{
                dialNumber(number: filteredJoin[indexPath.section-1].mobileNumber!)
            }else if indexPath.row == 9{
                dialNumber(number: filteredLocn[indexPath.section-1].mobileNumber!)
            }
        }
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? EmployeeInfoController,
            let index = CollectionView.indexPathsForSelectedItems?.first{
            if index.section > 0 {
                destination.slno = getSlno(value: index.section-1)//filteredItems[index.section-1].slno!
            }
            else{
                return
            }
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if let index = CollectionView.indexPathsForSelectedItems?.first{
            if((index.section) > 0){
                    if index.section == counter{
                        return false
                    }else{
                        return true
                    }
            }else{
                return false
            }
        }else{
            return false
        }
    }
    
    func getSlno(value: Int) -> Int{
        if joinleave {
            return filteredJoin[value].slno!
        }else if location {
            return filteredLocn[value].slno!
        }else if deptwise {
            return filteredDept[value].slno!
        }else if desigwise {
            return filteredDesig[value].slno!
        } else{
            return filteredItems[value].slno!
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
    
    //API CALLS..............
    func apiGetEmployeeDetails(){
        
        let json: [String: Any] = ["CIN":UserDefaults.standard.value(forKey: "userCIN") as! String,"Cat":UserDefaults.standard.value(forKey: "userCategory") as! String,"ClientSecret":"ClientSecret","BranchId":dataToReceive[0].branchId!, "type":type]
        
        let manager =  DataManager.shared
        print("Get EmpChild Details Params \(json)")
        manager.makeAPICall(url: apiEmployeeDetails, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            
            do {
                self.employeeChild = try JSONDecoder().decode([EmployeeChild].self, from: data!)
                self.employeeChildObj = self.employeeChild[0].data
                self.filteredItems = self.employeeChild[0].data
                for dealers in self.filteredItems{
                    self.tempArray.append(dealers)
                }
                self.textField.addTarget(self, action: #selector(self.searchRecords(_ :)), for: .editingChanged)
                self.heightConstraint.constant = CGFloat((((self.filteredItems.count+1) * 45) + 10))
                self.counter = self.filteredItems.count + 1
                print("Get EmpChild Details Data \(self.employeeChild[0].data)")
                self.CollectionView.reloadData()
                self.CollectionView.collectionViewLayout.invalidateLayout()
                ViewControllerUtils.sharedInstance.removeLoader()
            } catch let errorData {
                print(errorData.localizedDescription)
                //self.noDataView.showView(view: self.noDataView, from: "NDA")
                ViewControllerUtils.sharedInstance.removeLoader()
            }
        }) { (Error) in
            print(Error?.localizedDescription as Any)
            //self.noDataView.showView(view: self.noDataView, from: "NDA")
            ViewControllerUtils.sharedInstance.removeLoader()
        }
        
    }
    
    func getDeptDetails(){
        
        let json: [String: Any] = ["CIN":UserDefaults.standard.value(forKey: "userCIN") as! String,"Cat":UserDefaults.standard.value(forKey: "userCategory") as! String,"ClientSecret":"ClientSecret","DeptId":deptToReceive[0].departmentId!]
        
        let manager =  DataManager.shared
        print("Get Emp Dept Details Params \(json)")
        manager.makeAPICall(url: apiDeptDetails, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            
            do {
                self.empDeptChild = try JSONDecoder().decode([EmpDeptChild].self, from: data!)
                self.empDeptChildObj = self.empDeptChild[0].data
                self.filteredDept = self.empDeptChild[0].data
                for dealers in self.filteredDept{
                    self.tempDept.append(dealers)
                }
                self.textField.addTarget(self, action: #selector(self.searchDepts(_ :)), for: .editingChanged)
                self.heightConstraint.constant = CGFloat((((self.filteredDept.count+1) * 45) + 10))
                print("Get emp Dept Child Details Data \(self.empDeptChild[0].data)")
                self.counter = self.filteredDept.count + 1
                self.CollectionView.reloadData()
                self.CollectionView.collectionViewLayout.invalidateLayout()
                ViewControllerUtils.sharedInstance.removeLoader()
            } catch let errorData {
                print(errorData.localizedDescription)
                //self.noDataView.showView(view: self.noDataView, from: "NDA")
                ViewControllerUtils.sharedInstance.removeLoader()
            }
        }) { (Error) in
            print(Error?.localizedDescription as Any)
            //self.noDataView.showView(view: self.noDataView, from: "NDA")
            ViewControllerUtils.sharedInstance.removeLoader()
        }
        
    }
    
    func getDesigDetails(){
        
        let json: [String: Any] = ["CIN":UserDefaults.standard.value(forKey: "userCIN") as! String,"Cat":UserDefaults.standard.value(forKey: "userCategory") as! String,"ClientSecret":"ClientSecret","DesigId":desigToReceive[0].designationId!]
        
        let manager =  DataManager.shared
        print("Get Emp Desig Details Params \(json)")
        manager.makeAPICall(url: apiDesigDetails, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            
            do {
                self.empDesigChild = try JSONDecoder().decode([EmpDesigChild].self, from: data!)
                self.empDesigChildObj = self.empDesigChild[0].data
                self.filteredDesig = self.empDesigChild[0].data
                for dealers in self.filteredDesig{
                    self.tempDesig.append(dealers)
                }
                self.textField.addTarget(self, action: #selector(self.searchDesig(_ :)), for: .editingChanged)
                self.heightConstraint.constant = CGFloat((((self.filteredDesig.count+1) * 45) + 10))
                self.counter = self.filteredDesig.count + 1
                print("Get emp Desig Child Details Data \(self.empDesigChild[0].data)")
                self.CollectionView.reloadData()
                self.CollectionView.collectionViewLayout.invalidateLayout()
                ViewControllerUtils.sharedInstance.removeLoader()
            } catch let errorData {
                print(errorData.localizedDescription)
                //self.noDataView.showView(view: self.noDataView, from: "NDA")
                ViewControllerUtils.sharedInstance.removeLoader()
            }
        }) { (Error) in
            print(Error?.localizedDescription as Any)
            //self.noDataView.showView(view: self.noDataView, from: "NDA")
            ViewControllerUtils.sharedInstance.removeLoader()
        }
        
    }
    
    func getJoinLeave(){
        
        let json: [String: Any] = ["CIN":UserDefaults.standard.value(forKey: "userCIN") as! String,"Cat":UserDefaults.standard.value(forKey: "userCategory") as! String,"ClientSecret":"ClientSecret","fromdate":fromDate,"todate":toDate, "type":type]
        
        let manager =  DataManager.shared
        print("Get Emp Join Params \(json)")
        manager.makeAPICall(url: apiJoinLeave, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            
            do {
                self.empJoinLeave = try JSONDecoder().decode([EmpJoinLeave].self, from: data!)
                self.empJoinLeaveObj = self.empJoinLeave[0].data
                self.filteredJoin = self.empJoinLeave[0].data
                for dealers in self.filteredJoin{
                    self.tempJoin.append(dealers)
                }
                self.textField.addTarget(self, action: #selector(self.searchJoins(_ :)), for: .editingChanged)
                print("Get emp join Details Data \(self.filteredJoin.count)")
                self.heightConstraint.constant = CGFloat((((self.filteredJoin.count+1) * 45) + 10))
                self.counter = self.filteredJoin.count + 1
                self.CollectionView.reloadData()
                self.CollectionView.collectionViewLayout.invalidateLayout()
                self.CollectionView.layoutIfNeeded()
                ViewControllerUtils.sharedInstance.removeLoader()
                if self.filteredJoin.count == 0 {
                    //self.noDataView.showView(view: self.noDataView, from: "NDA")
                }
            } catch let errorData {
                print(errorData.localizedDescription)
                //self.noDataView.showView(view: self.noDataView, from: "NDA")
                ViewControllerUtils.sharedInstance.removeLoader()
            }
        }) { (Error) in
            print(Error?.localizedDescription as Any)
            //self.noDataView.showView(view: self.noDataView, from: "NDA")
            ViewControllerUtils.sharedInstance.removeLoader()
        }
        
    }
    
    func getLocationwise(){
        
        let json: [String: Any] = ["CIN":UserDefaults.standard.value(forKey: "userCIN") as! String,"Cat":UserDefaults.standard.value(forKey: "userCategory") as! String,"ClientSecret":"ClientSecret","LocationId":self.dataForLocn[0].locationId!, "type":type]
        
        let manager =  DataManager.shared
        print("Get Emp Loc Params \(json)")
        manager.makeAPICall(url: apiEmpLocn, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            
            do {
                self.empLocn = try JSONDecoder().decode([EmpLocChild].self, from: data!)
                self.empLocnObj = self.empLocn[0].data
                self.filteredLocn = self.empLocn[0].data
                for dealers in self.filteredLocn{
                    self.tempLocn.append(dealers)
                }
                self.textField.addTarget(self, action: #selector(self.searchLocn(_ :)), for: .editingChanged)
                self.counter = self.filteredLocn.count + 1
                self.heightConstraint.constant = CGFloat((((self.filteredLocn.count+1) * 45) + 10))
                self.CollectionView.reloadData()
                self.CollectionView.collectionViewLayout.invalidateLayout()
                ViewControllerUtils.sharedInstance.removeLoader()
                if self.filteredLocn.count == 0 {
                    //self.noDataView.showView(view: self.noDataView, from: "NDA")
                }
            } catch let errorData {
                print(errorData.localizedDescription)
                //self.noDataView.showView(view: self.noDataView, from: "NDA")
                ViewControllerUtils.sharedInstance.removeLoader()
            }
        }) { (Error) in
            print(Error?.localizedDescription as Any)
            //self.noDataView.showView(view: self.noDataView, from: "NDA")
            ViewControllerUtils.sharedInstance.removeLoader()
        }
        
    }
    
    
    func getMonthlyCount(){
        
        let json: [String: Any] = ["CIN":UserDefaults.standard.value(forKey: "userCIN") as! String,"Cat":UserDefaults.standard.value(forKey: "userCategory") as! String,"ClientSecret":"ClientSecret"]
        
        let manager =  DataManager.shared
        print("Get Emp Monthly Params \(json)")
        manager.makeAPICall(url: apiEmpMonthly, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            
            do {
                self.empMonthly = try JSONDecoder().decode([EmpMonthlyCount].self, from: data!)
                self.empMonthlyObj = self.empMonthly[0].data
                //self.filteredLocn = self.empLocn[0].data
                self.heightConstraintTwo.constant = CGFloat((((self.empMonthlyObj.count+1) * 45) + 10))
                self.counter = self.empMonthlyObj.count + 1
                self.CollectionViewTwo.reloadData()
                self.CollectionViewTwo.collectionViewLayout.invalidateLayout()
                ViewControllerUtils.sharedInstance.removeLoader()
                if self.empMonthlyObj.count == 0 {
                    //self.noDataView.showView(view: self.noDataView, from: "NDA")
                }
            } catch let errorData {
                print(errorData.localizedDescription)
                //self.noDataView.showView(view: self.noDataView, from: "NDA")
                ViewControllerUtils.sharedInstance.removeLoader()
            }
        }) { (Error) in
            print(Error?.localizedDescription as Any)
            //self.noDataView.showView(view: self.noDataView, from: "NDA")
            ViewControllerUtils.sharedInstance.removeLoader()
        }
        
    }
    
    //BAR CHART...
    
    
 
}

class IntrinsicCollection: UICollectionView {
    var showNoData = false
    override var contentSize:CGSize {
        didSet {
            self.invalidateIntrinsicContentSize()
        }
    }
    
    override var intrinsicContentSize: CGSize {
        self.layoutIfNeeded()
        return CGSize(width: UIViewNoIntrinsicMetric, height: contentSize.height+60)
    }
    
}
