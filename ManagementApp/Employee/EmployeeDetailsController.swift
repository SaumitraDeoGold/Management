//
//  EmployeeDetailsController.swift
//  ManagementApp
//
//  Created by Goldmedal on 11/02/20.
//  Copyright © 2020 Goldmedal. All rights reserved.
//

import UIKit

class EmployeeDetailsController: BaseViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    //Outlets...
    @IBOutlet weak var CollectionView: IntrinsicCollection!
    @IBOutlet weak var btnDivision: RoundButton!
    @IBOutlet weak var btnBranch: RoundButton!
    @IBOutlet weak var vwHeader: UIStackView!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    
    //Declarations...
    var cellContentIdentifier = "\(CollectionViewCell.self)"
    var employeeData = [EmployeeData]()
    var employeeDataObj = [EmployeeDataObj]()
    var filteredItems = [EmployeeDataObj]()
    var emplocnData = [EmpLocation]()
    var emplocnObj = [EmpLocationObj]()
    var filteredLoc = [EmpLocationObj]()
    var apiEmployeeDetails = ""
    var apiEmployeeLocn = ""
    var showLoc = false
    var totalemp = 0
    var execCount = 0
    var intEmpCount = 0
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if UserDefaults.standard.value(forKey: "userCategory") as! String == "Agent"{
            vwHeader.isHidden = true
            heightConstraint.constant = 0
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addSlideMenuButton()
        apiEmployeeDetails = "https://api.goldmedalindia.in/api/getEmployeeList"
        apiEmployeeLocn = "https://api.goldmedalindia.in/api/getlocationEmployeeList"
        ViewControllerUtils.sharedInstance.showLoader()
        apiGetEmployeeDetails()
    }
    
    //Tab Click Func...
    @IBAction func clickedBranch(_ sender: Any) {
        showLoc = false
        btnBranch.backgroundColor = UIColor.darkGray
        btnBranch.setTitleColor(UIColor.white, for: .normal)
        btnDivision.backgroundColor = UIColor.white
        btnDivision.setTitleColor(UIColor.black, for: .normal)
        ViewControllerUtils.sharedInstance.showLoader()
        apiGetEmployeeDetails()
    }
    
    @IBAction func clickedLocn(_ sender: Any) {
        showLoc = true
        btnBranch.backgroundColor = UIColor.white
        btnBranch.setTitleColor(UIColor.black, for: .normal)
        btnDivision.backgroundColor = UIColor.darkGray
        btnDivision.setTitleColor(UIColor.white, for: .normal)
        ViewControllerUtils.sharedInstance.showLoader()
        apiGetEmployeeLocn()
    }
    
    //Sort Related...
    @IBAction func clicked_sort(_ sender: Any) {
        let sb = UIStoryboard(name: "Sorting", bundle: nil)
        let popup = sb.instantiateInitialViewController()! as! SortViewController
        popup.modalPresentationStyle = .overFullScreen
        popup.delegate = self
        popup.showPicker = 1
        popup.pickerDataSource = ["A-Z","Z-A","low to high Employee Count","high to low Employee Count"]
        self.present(popup, animated: true)
    }
    
    func sortBy(value: String, position: Int) {
        if showLoc{
            switch position {
            case 0:
                self.filteredLoc = self.emplocnObj.sorted{($0.locationName)!.localizedCaseInsensitiveCompare($1.locationName!) == .orderedAscending}
            case 1:
                self.filteredLoc = self.emplocnObj.sorted{($0.locationName)!.localizedCaseInsensitiveCompare($1.locationName!) == .orderedDescending}
            case 2:
                self.filteredLoc = self.emplocnObj.sorted(by: {Double($0.employeeCount!) < Double($1.employeeCount!)})
            case 3:
                self.filteredLoc = self.emplocnObj.sorted(by: {Double($0.employeeCount!) > Double($1.employeeCount!)})
            default:
                break
            }
        }else{
            switch position {
            case 0:
                self.filteredItems = self.employeeDataObj.sorted{($0.branchName)!.localizedCaseInsensitiveCompare($1.branchName!) == .orderedAscending}
            case 1:
                self.filteredItems = self.employeeDataObj.sorted{($0.branchName)!.localizedCaseInsensitiveCompare($1.branchName!) == .orderedDescending}
            case 2:
                self.filteredItems = self.employeeDataObj.sorted(by: {Double($0.employeeCount!) < Double($1.employeeCount!)})
            case 3:
                self.filteredItems = self.employeeDataObj.sorted(by: {Double($0.employeeCount!) > Double($1.employeeCount!)})
            default:
                break
            }
        }
        
        self.CollectionView.reloadData()
        self.CollectionView.collectionViewLayout.invalidateLayout()
    }
    
    //CollectionView Functions...
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if showLoc{
            return self.filteredLoc.count + 2
        }else{
            return self.filteredItems.count + 2
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = CollectionView.dequeueReusableCell(withReuseIdentifier: cellContentIdentifier,
                                                      for: indexPath) as! CollectionViewCell
        cell.layer.borderWidth = 1
        cell.layer.borderColor = UIColor.white.cgColor
        //Header of CollectionView...
        
        
        if showLoc{
            if indexPath.section == 0 {
                cell.contentLabel.font = UIFont(name: "Roboto-Medium", size: 16)
                if #available(iOS 11.0, *) {
                    cell.backgroundColor = UIColor.init(named: "Primary")
                } else {
                    cell.backgroundColor = UIColor.gray
                }
                switch indexPath.row{
                case 0:
                    cell.contentLabel.text = "Location Name"
                case 1:
                    cell.contentLabel.text = "Employee Count"
                case 2:
                    cell.contentLabel.text = "Executive Count"
                case 3:
                    cell.contentLabel.text = "Back Ofc. Count"
                default:
                    break
                }
                
            }else if indexPath.section == filteredLoc.count + 1{
                    cell.contentLabel.font = UIFont(name: "Roboto-Medium", size: 16)
                    if #available(iOS 11.0, *) {
                        cell.backgroundColor = UIColor.init(named: "Primary")
                    } else {
                        cell.backgroundColor = UIColor.gray
                    }
                    switch indexPath.row{
                    case 0:
                        cell.contentLabel.text = "TOTAL"
                    case 1:
                        cell.contentLabel.text = String(totalemp)
                    case 2:
                        cell.contentLabel.text = String(execCount)
                    case 3:
                        cell.contentLabel.text = String(intEmpCount)
                    default:
                        break
                    }
            } else{
                cell.contentLabel.font = UIFont(name: "Roboto-Regular", size: 14)
                if #available(iOS 11.0, *) {
                    cell.backgroundColor = UIColor.init(named: "primaryLight")
                } else {
                    cell.backgroundColor = UIColor.lightGray
                }
                
                switch indexPath.row{
                case 0:
                    cell.contentLabel.text = filteredLoc[indexPath.section-1].locationName
                case 1:
                    cell.contentLabel.text = String(filteredLoc[indexPath.section-1].employeeCount!)
                case 2:
                    cell.contentLabel.text = String(filteredLoc[indexPath.section-1].execCount!)
                case 3:
                    cell.contentLabel.text = String(filteredLoc[indexPath.section-1].internalEmpCount!)
                default:
                    break
                }
            }
        }else{
            if indexPath.section == 0 {
                cell.contentLabel.font = UIFont(name: "Roboto-Medium", size: 16)
                if #available(iOS 11.0, *) {
                    cell.backgroundColor = UIColor.init(named: "Primary")
                } else {
                    cell.backgroundColor = UIColor.gray
                }
                switch indexPath.row{
                case 0:
                    cell.contentLabel.text = "Branch Name"
                case 1:
                    cell.contentLabel.text = "Employee Count"
                case 2:
                    cell.contentLabel.text = "Executive Count"
                case 3:
                    cell.contentLabel.text = "Back Ofc. Count"
                default:
                    break
                }
                
            }else if indexPath.section == filteredItems.count + 1{
                    cell.contentLabel.font = UIFont(name: "Roboto-Medium", size: 16)
                    if #available(iOS 11.0, *) {
                        cell.backgroundColor = UIColor.init(named: "Primary")
                    } else {
                        cell.backgroundColor = UIColor.gray
                    }
                    switch indexPath.row{
                    case 0:
                        cell.contentLabel.text = "TOTAL"
                    case 1:
                        cell.contentLabel.text = String(totalemp)
                    case 2:
                        cell.contentLabel.text = String(execCount)
                    case 3:
                        cell.contentLabel.text = String(intEmpCount)
                    default:
                        break
                    }
                
            }else{
                cell.contentLabel.font = UIFont(name: "Roboto-Regular", size: 14)
                if #available(iOS 11.0, *) {
                    cell.backgroundColor = UIColor.init(named: "primaryLight")
                } else {
                    cell.backgroundColor = UIColor.lightGray
                }
                
                switch indexPath.row{
                case 0:
                    cell.contentLabel.text = filteredItems[indexPath.section-1].branchName
                case 1:
                    cell.contentLabel.text = String(filteredItems[indexPath.section-1].employeeCount!)
                case 2:
                    cell.contentLabel.text = String(filteredItems[indexPath.section-1].execCount!)
                case 3:
                    cell.contentLabel.text = String(filteredItems[indexPath.section-1].internalEmpCount!)
                default:
                    break
                }
            }
        }
        
        return cell
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? EmpChildViewController,
            let index = CollectionView.indexPathsForSelectedItems?.first{
            if showLoc {
                destination.dataForLocn = [filteredLoc[index.section-1]]
                destination.location = true
                destination.type = index.row == 2 ? 1 : 2
            }else{
                destination.dataToReceive = [filteredItems[index.section-1]]
                destination.type = index.row == 2 ? 1 : 2
            }
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if let index = CollectionView.indexPathsForSelectedItems?.first{
            if((index.section) > 0){
                if((index.row) == 0 || (index.row) == 1){
                    return false
                }
                if index.section == self.filteredItems.count + 1{
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
    
    //API CALLS..............
    func apiGetEmployeeDetails(){
        
        let json: [String: Any] = ["CIN":UserDefaults.standard.value(forKey: "userCIN") as! String,"Cat":UserDefaults.standard.value(forKey: "userCategory") as! String,"ClientSecret":"ClientSecret"]
        
        let manager =  DataManager.shared
        print("Get Emp Details Params \(json)")
        manager.makeAPICall(url: apiEmployeeDetails, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            
            do {
                self.employeeData = try JSONDecoder().decode([EmployeeData].self, from: data!)
                self.employeeDataObj = self.employeeData[0].data
                self.filteredItems = self.employeeData[0].data
                self.totalemp = Int(self.filteredItems.reduce(0, { $0 + Double($1.employeeCount!) }))
                self.execCount = Int(self.filteredItems.reduce(0, { $0 + Double($1.execCount!) }))
                self.intEmpCount = Int(self.filteredItems.reduce(0, { $0 + Double($1.internalEmpCount!) }))
                print("Get Emp Details Data \(self.employeeData[0].data)")
                self.CollectionView.reloadData()
                self.CollectionView.collectionViewLayout.invalidateLayout()
                self.CollectionView.setContentOffset(CGPoint.zero, animated: false)
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
    
    func apiGetEmployeeLocn(){
        
        let json: [String: Any] = ["CIN":UserDefaults.standard.value(forKey: "userCIN") as! String,"Cat":UserDefaults.standard.value(forKey: "userCategory") as! String,"ClientSecret":"ClientSecret"]
        
        let manager =  DataManager.shared
        print("Get Emp Locn Params \(json)")
        manager.makeAPICall(url: apiEmployeeLocn, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            
            do {
                self.emplocnData = try JSONDecoder().decode([EmpLocation].self, from: data!)
                self.emplocnObj = self.emplocnData[0].data
                self.filteredLoc = self.emplocnData[0].data
                self.totalemp = Int(self.filteredLoc.reduce(0, { $0 + Double($1.employeeCount!) }))
                self.execCount = Int(self.filteredLoc.reduce(0, { $0 + Double($1.execCount!) }))
                self.intEmpCount = Int(self.filteredLoc.reduce(0, { $0 + Double($1.internalEmpCount!) }))
                print("Get Emp Locn Data \(self.emplocnData[0].data)")
                self.CollectionView.reloadData()
                self.CollectionView.collectionViewLayout.invalidateLayout()
                self.CollectionView.setContentOffset(CGPoint.zero, animated: false)
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


