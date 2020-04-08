//
//  AttendanceChildController.swift
//  ManagementApp
//
//  Created by Goldmedal on 25/03/20.
//  Copyright © 2020 Goldmedal. All rights reserved.
//

import UIKit

class AttendanceChildController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    //Outlets...
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var textField: UITextField!
   
    
    //Declarations...
    var cellContentIdentifier = "\(CollectionViewCell.self)"
    var attendanceApiUrl = ""
    var locAttendanceApiUrl = ""
    var attendanceChild = [AttendanceChild]()
    var attendanceChildObj = [AttendanceChildObj]()
    var filteredItems = [AttendanceChildObj]()
    var tempAtt = [AttendanceChildObj]()
    var locAttendanceChild = [LocAttendanceChild]()
    var locAttendanceChildObj = [LocAttendanceChildObj]()
    var filteredLoc = [LocAttendanceChildObj]()
    var tempLocAtt = [LocAttendanceChildObj]()
    var dataToRecieve = [AttendanceObj]()
    var locDataToRecieve = [LocationAttendanceObj]()
    var currDate = ""
    var fromLoc = false
    var type = 0
    let tabBarCnt = UITabBarController()

    override func viewDidLoad() {
        super.viewDidLoad()
         ViewControllerUtils.sharedInstance.showLoader()
        tabBarCnt.tabBar.tintColor = UIColor.cyan
        tabBarCnt.tabBar.unselectedItemTintColor = UIColor.lightGray
        tabBarCnt.tabBar.barTintColor = UIColor.black
        attendanceApiUrl = "https://test2.goldmedalindia.in/api/getbranchwiseattdetails"
        locAttendanceApiUrl = "https://api.goldmedalindia.in/api/getlocwiseattdetails"
        if fromLoc{
            apiGetLocAttendance()
        }else{
           apiGetAttendance()
        }
        
    }
    
    //Auto-Complete Function...
    @objc func searchRecords(_ textfield: UITextField){
        self.filteredItems.removeAll()
        if textfield.text?.count != 0{
            for dealers in tempAtt{
                let range = dealers.employeeName!.lowercased().range(of: textfield.text!, options: .caseInsensitive, range: nil, locale: nil)
                let des = dealers.employeeCode!.lowercased().range(of: textfield.text!, options: .caseInsensitive, range: nil, locale: nil)
                let num = dealers.mobileNumber!.lowercased().range(of: textfield.text!, options: .caseInsensitive, range: nil, locale: nil)
                if range != nil{
                    filteredItems.append(dealers)
                }else if des != nil{
                    filteredItems.append(dealers)
                }else if num != nil{
                    filteredItems.append(dealers)
                }
            }
        }else{
            for dealers in tempAtt{
                filteredItems.append(dealers)
            }
        }
        self.collectionView.reloadData()
        self.collectionView.collectionViewLayout.invalidateLayout()
    }
    
    @objc func searchLocRecords(_ textfield: UITextField){
        self.filteredLoc.removeAll()
        if textfield.text?.count != 0{
            for dealers in tempLocAtt{
                let range = dealers.employeeName!.lowercased().range(of: textfield.text!, options: .caseInsensitive, range: nil, locale: nil)
                let des = dealers.employeeCode!.lowercased().range(of: textfield.text!, options: .caseInsensitive, range: nil, locale: nil)
                let num = dealers.mobileNumber!.lowercased().range(of: textfield.text!, options: .caseInsensitive, range: nil, locale: nil)
                if range != nil{
                    filteredLoc.append(dealers)
                }else if des != nil{
                    filteredLoc.append(dealers)
                }else if num != nil{
                    filteredLoc.append(dealers)
                }
            }
        }else{
            for dealers in tempLocAtt{
                filteredLoc.append(dealers)
            }
        }
        self.collectionView.reloadData()
        self.collectionView.collectionViewLayout.invalidateLayout()
    }
    
    //Collection View......
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if fromLoc{
            return self.filteredLoc.count + 1
        }else{
            return self.filteredItems.count + 1
        }
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 6
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellContentIdentifier,
                                                      for: indexPath) as! CollectionViewCell
        cell.layer.borderWidth = 1
        cell.layer.borderColor = UIColor.white.cgColor
        if fromLoc {
            if indexPath.section == 0 {
                cell.contentLabel.font = UIFont(name: "Roboto-Medium", size: 16)
                if #available(iOS 11.0, *) {
                    cell.backgroundColor = UIColor.init(named: "Primary")
                } else {
                    cell.backgroundColor = UIColor.gray
                }
                switch indexPath.row{
                case 0:
                    cell.contentLabel.attributedText = setNormalText(value: "Emp-Code")
                case 1:
                    cell.contentLabel.attributedText = setNormalText(value: "Name")
                case 2:
                    cell.contentLabel.attributedText = setNormalText(value: "In Time")
                case 3:
                    cell.contentLabel.attributedText = setNormalText(value: "Out Time")
                case 4:
                    cell.contentLabel.attributedText = setNormalText(value: "Working hrs")
                case 5:
                    cell.contentLabel.attributedText = setNormalText(value: "Mobile No.")
                    
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
                    cell.contentLabel.attributedText = setNormalText(value: filteredLoc[indexPath.section - 1].employeeCode!)
                    
                case 1:
                    cell.contentLabel.attributedText = setNormalText(value: filteredLoc[indexPath.section - 1].employeeName!)
                case 2:
                    cell.contentLabel.attributedText = setNormalText(value: filteredLoc[indexPath.section - 1].intime ?? "-")
                case 3:
                    cell.contentLabel.attributedText = setNormalText(value: filteredLoc[indexPath.section-1].out ?? "-")
                case 4:
                    let tuple = minutesToHoursMinutes(minutes: Int(filteredLoc[indexPath.section-1].dueration!)!)
                    cell.contentLabel.attributedText = setNormalText(value: "\(tuple.hours) hour \(tuple.leftMinutes) minutes")
                case 5:
                    let attributedString = NSAttributedString(string: NSLocalizedString((filteredLoc[indexPath.section-1].mobileNumber!), comment: ""), attributes:[
                        NSAttributedString.Key.foregroundColor : UIColor(named: "ColorBlue")!,
                        NSAttributedString.Key.underlineStyle:1.0
                        ])
                    cell.contentLabel.attributedText = attributedString
                    
                default:
                    break
                }
                //cell.backgroundColor = UIColor.groupTableViewBackground
            }
            return cell
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
                    cell.contentLabel.attributedText = setNormalText(value: "Emp-Code")
                case 1:
                    cell.contentLabel.attributedText = setNormalText(value: "Name")
                case 2:
                    cell.contentLabel.attributedText = setNormalText(value: "In Time")
                case 3:
                    cell.contentLabel.attributedText = setNormalText(value: "Out Time")
                case 4:
                    cell.contentLabel.attributedText = setNormalText(value: "Working hrs")
                case 5:
                    cell.contentLabel.attributedText = setNormalText(value: "Mobile No.")
                    
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
                    
                    cell.contentLabel.attributedText = setNormalText(value: filteredItems[indexPath.section - 1].employeeCode!)
                case 1:
                    cell.contentLabel.attributedText = setNormalText(value: filteredItems[indexPath.section - 1].employeeName!)
                case 2:
                    cell.contentLabel.attributedText = setNormalText(value: filteredItems[indexPath.section - 1].inTime ?? "-")
                case 3:
                    cell.contentLabel.attributedText = setNormalText(value: filteredItems[indexPath.section-1].out ?? "-")
                    
                case 4:
                    if filteredItems[indexPath.section-1].dueration != ""{
                        let tuple = minutesToHoursMinutes(minutes: Int(filteredItems[indexPath.section-1].dueration ?? "0")!)
                        cell.contentLabel.attributedText = setNormalText(value: "\(tuple.hours) hour \(tuple.leftMinutes) minutes")
                    }else{
                        cell.contentLabel.text = "-"
                    }
                    
                case 5:
                    let attributedString = NSAttributedString(string: NSLocalizedString((filteredItems[indexPath.section-1].mobileNumber!), comment: ""), attributes:[
                        NSAttributedString.Key.foregroundColor : UIColor(named: "ColorBlue")!,
                        NSAttributedString.Key.underlineStyle:1.0
                        ])
                    cell.contentLabel.attributedText = attributedString
                    
                default:
                    break
                }
                //cell.backgroundColor = UIColor.groupTableViewBackground
            }
            return cell
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == 5{
            dialNumber(number: filteredItems[indexPath.section-1].mobileNumber!)
        }else{
            let sb = UIStoryboard(name: "Leaves", bundle: nil)
            let popup = sb.instantiateInitialViewController()! as! CalendarLeaveController
            popup.modalPresentationStyle = .overFullScreen
            popup.username = fromLoc ? filteredLoc[indexPath.section-1].employeeName! : filteredItems[indexPath.section-1].employeeName!
            popup.userId = fromLoc ? filteredLoc[indexPath.section-1].employeeslno! : filteredItems[indexPath.section-1].employeeslno!
            //popup.pickerDataSource = ["low to high Amount","high to low Amount"]
            self.present(popup, animated: true)
//            let leaveStoryBoard: UIStoryboard = UIStoryboard(name: "Leaves", bundle: nil)
//            let attdVc = leaveStoryBoard.instantiateViewController(withIdentifier: "CalendarLeaveController") as! CalendarLeaveController
//            attdVc.tabBarItem = UITabBarItem.init(title: "Attendance", image: UIImage(named: "attendanceMenu"), tag: 1)
//            let controllerArray = [attdVc]
//            tabBarCnt.viewControllers = controllerArray.map{ UINavigationController.init(rootViewController: $0)}
//
//            self.view.addSubview(tabBarCnt.view)
        }
    }
    
    func setNormalText(value: String) -> NSAttributedString{
        let attributedString = NSAttributedString(string: NSLocalizedString(value, comment: ""), attributes:[
            NSAttributedString.Key.foregroundColor : UIColor.black
            ])
        return attributedString
    }
    
    func minutesToHoursMinutes (minutes : Int) -> (hours : Int , leftMinutes : Int) {
        return (minutes / 60, (minutes % 60))
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
    
    //API CALL...
    func apiGetAttendance(){
        let json: [String: Any] = ["CIN":UserDefaults.standard.value(forKey: "userCIN") as! String,"Cat":UserDefaults.standard.value(forKey: "userCategory") as! String,"BranchId":dataToRecieve[0].branchId!,"ClientSecret":"ohdashfl","type":String(type),"date":currDate]
        let manager =  DataManager.shared
        print("Params Sent : \(json)")
        manager.makeAPICall(url: attendanceApiUrl, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            
            do {
                self.attendanceChild = try JSONDecoder().decode([AttendanceChild].self, from: data!)
                self.attendanceChildObj  = self.attendanceChild[0].data
                self.filteredItems  = self.attendanceChild[0].data
                self.tempAtt  = self.attendanceChild[0].data
                self.textField.addTarget(self, action: #selector(self.searchRecords(_ :)), for: .editingChanged)
                self.collectionView.reloadData()
                self.collectionView.collectionViewLayout.invalidateLayout()
                //self.noDataView.hideView(view: self.noDataView)
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
    
    func apiGetLocAttendance(){
        let json: [String: Any] = ["CIN":UserDefaults.standard.value(forKey: "userCIN") as! String,"Cat":UserDefaults.standard.value(forKey: "userCategory") as! String,"LocationId":locDataToRecieve[0].locationId!,"ClientSecret":"ohdashfl","type":String(type),"date":currDate]
        let manager =  DataManager.shared
        print("Params Sent Loc: \(json)")
        manager.makeAPICall(url: attendanceApiUrl, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            
            do {
                self.locAttendanceChild = try JSONDecoder().decode([LocAttendanceChild].self, from: data!)
                self.locAttendanceChildObj  = self.locAttendanceChild[0].data
                self.filteredLoc  = self.locAttendanceChild[0].data
                self.tempLocAtt  = self.locAttendanceChild[0].data
                self.textField.addTarget(self, action: #selector(self.searchLocRecords(_ :)), for: .editingChanged)
                self.collectionView.reloadData()
                self.collectionView.collectionViewLayout.invalidateLayout()
                //self.noDataView.hideView(view: self.noDataView)
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
