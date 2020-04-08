//
//  AttendanceViewController.swift
//  ManagementApp
//



//  Created by Goldmedal on 05/03/20.
//  Copyright © 2020 Goldmedal. All rights reserved.
//

import UIKit
import Charts

class AttendanceViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, PopupDateDelegate {
    
    
    
    //Outlets...
    @IBOutlet weak var totalEmployees: UILabel!
    @IBOutlet weak var empPresent: UIButton!
    @IBOutlet weak var empAbsent: UIButton!
    @IBOutlet var empPieChart: PieChartView!
    @IBOutlet weak var totalChart: UILabel!
    @IBOutlet weak var CollectionView: IntrinsicCollectionViews!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var btnLocation: RoundButton!
    @IBOutlet weak var btnBranch: RoundButton!
    @IBOutlet weak var lblDate: UILabel!
    
    //Declarations...
    var apiBranchAttendance = ""
    var apiLocAttendance = ""
    var attendanceData = [Attendance]()
    var attendanceObj = [AttendanceObj]()
    var filteredItems = [AttendanceObj]()
    var locAttendanceData = [LocationAttendance]()
    var locAttendanceObj = [LocationAttendanceObj]()
    var filteredLoc = [LocationAttendanceObj]()
    var present = 0
    var absent = 0
    var salesPresent = 0
    var salesAbsent = 0
    var totalPresent = 0
    var totalAbsent = 0
    let colorArray = [UIColor.red, UIColor.green, UIColor.blue, UIColor.orange, UIColor.brown, UIColor.yellow, UIColor.purple, UIColor.yellow, UIColor.magenta,UIColor.darkGray,UIColor.red, UIColor.green, UIColor.blue, UIColor.orange, UIColor.brown, UIColor.cyan, UIColor.purple, UIColor.yellow, UIColor.magenta,UIColor.darkGray]
    var todayDate = ""
    var cellContentIdentifier = "\(CollectionViewCell.self)"
    var showLoc = false
    var toDate: Date?
    let currDate = Date()
    var dateFormatter = DateFormatter()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        todayDate = getCurrentDate()
        //attendanceApiUrl = "https://test2.goldmedalindia.in/api/getbranchwiseattdetails"
        apiBranchAttendance = "https://test2.goldmedalindia.in/api/getbranchwiseattcount"
        apiLocAttendance = "https://test2.goldmedalindia.in/api/getlocationwiseattcount"
        ViewControllerUtils.sharedInstance.showLoader()
        apiBranchwiseAtt()
        
        let dateClick = UITapGestureRecognizer(target: self, action: #selector(self.clickedDate))
        lblDate.addGestureRecognizer(dateClick)
        
        dateFormatter.dateFormat = "dd/MM/yyyy"
        toDate = dateFormatter.date(from: dateFormatter.string(from: currDate))
        print("Today Date : \(toDate!)")
        lblDate.text = "Date : \(getIndianDate(value: todayDate))"
    }
    
    func getIndianDate(value: String) -> String{
        var inFormatDate = value.split{$0 == "-"}.map(String.init)
        let temp = "\(inFormatDate[1])/\(inFormatDate[0])/\(inFormatDate[2])"
        return temp
    }
    
    func getCurrentDate() -> String{
        let now = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy"
        let todayDate = dateFormatter.string(from: now)
        return todayDate
    }
    
    //Date Clicked....
    @objc func clickedDate(_ sender: UIButton) {
        let sb = UIStoryboard(name: "DatePicker", bundle: nil)
        let popup = sb.instantiateInitialViewController()  as? DatePickerController
        popup?.delegate = self
        popup?.toDate = toDate
        popup?.fromDate = toDate
        popup?.isFromDate = true
        self.present(popup!, animated: true)
    }
    
    func updateDate(value: String, date: Date) {
        lblDate.text = "Date : \(value)"
        var usFormatDate = value.split{$0 == "/"}.map(String.init)
        todayDate = "\(usFormatDate[1])-\(usFormatDate[0])-\(usFormatDate[2])"
        if showLoc{
            apiLocnAttendance()
        }else{
            apiBranchwiseAtt()
        }
    }
    
    //Tab Click Func...
    @IBAction func clickedBranch(_ sender: Any) {
        showLoc = false
        btnBranch.backgroundColor = UIColor.darkGray
        btnBranch.setTitleColor(UIColor.white, for: .normal)
        btnLocation.backgroundColor = UIColor.white
        btnLocation.setTitleColor(UIColor.black, for: .normal)
        ViewControllerUtils.sharedInstance.showLoader()
        apiBranchwiseAtt()
    }
    
    @IBAction func clickedLocn(_ sender: Any) {
        showLoc = true
        btnBranch.backgroundColor = UIColor.white
        btnBranch.setTitleColor(UIColor.black, for: .normal)
        btnLocation.backgroundColor = UIColor.darkGray
        btnLocation.setTitleColor(UIColor.white, for: .normal)
        ViewControllerUtils.sharedInstance.showLoader()
        apiLocnAttendance()
    }
    
    //CollectionView Functions......
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if showLoc{
            return filteredLoc.count + 2
        }else{
            return filteredItems.count + 2
        }
        
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = CollectionView.dequeueReusableCell(withReuseIdentifier: cellContentIdentifier,
                                                      for: indexPath) as! CollectionViewCell
        cell.layer.borderWidth = 1
        cell.layer.borderColor = UIColor.white.cgColor
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
                    cell.contentLabel.text = "Location"
                case 1:
                    cell.contentLabel.text = "Bk Ofc Pr"
                case 2:
                    cell.contentLabel.text = "Bk Ofc Ab"
                case 3:
                    cell.contentLabel.text = "Sales-Ex Pr"
                case 4:
                    cell.contentLabel.text = "Sales-Ex Ab"
                    
                default:
                    break
                }
                //cell.backgroundColor = UIColor.lightGray
            }else if indexPath.section == filteredLoc.count+1{
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
                    cell.contentLabel.text = Utility.formatRupee(amount: Double(present))
                    cell.contentLabel.textColor = UIColor.black
                case 2:
                    cell.contentLabel.text = Utility.formatRupee(amount: Double(absent))
                case 3:
                    cell.contentLabel.text = Utility.formatRupee(amount: Double(salesPresent))
                case 4:
                    cell.contentLabel.text = Utility.formatRupee(amount: Double(salesAbsent))
                default:
                    break
                }
            } else {
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
                    cell.contentLabel.text = filteredLoc[indexPath.section-1].employeePresent
                case 2:
                    cell.contentLabel.text = filteredLoc[indexPath.section-1].employeeAbsent
                case 3:
                    cell.contentLabel.text = filteredLoc[indexPath.section-1].salesexecPresent
                case 4:
                    cell.contentLabel.text = filteredLoc[indexPath.section-1].salesexecPresent
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
                    cell.contentLabel.text = "Branch Name"
                case 1:
                    cell.contentLabel.text = "Bk Ofc Pr"
                case 2:
                    cell.contentLabel.text = "Bk Ofc Ab"
                case 3:
                    cell.contentLabel.text = "Sales-Ex Pr"
                case 4:
                    cell.contentLabel.text = "Sales-Ex Ab"
                    
                default:
                    break
                }
                //cell.backgroundColor = UIColor.lightGray
            }else if indexPath.section == filteredItems.count+1{
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
                    cell.contentLabel.text = Utility.formatRupee(amount: Double(present))
                    cell.contentLabel.textColor = UIColor.black
                case 2:
                    cell.contentLabel.text = Utility.formatRupee(amount: Double(absent))
                case 3:
                    cell.contentLabel.text = Utility.formatRupee(amount: Double(salesPresent))
                case 4:
                    cell.contentLabel.text = Utility.formatRupee(amount: Double(salesAbsent))
                default:
                    break
                }
            } else {
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
                    cell.contentLabel.text = filteredItems[indexPath.section-1].employeePresent
                case 2:
                    cell.contentLabel.text = filteredItems[indexPath.section-1].employeeAbsent
                case 3:
                    cell.contentLabel.text = filteredItems[indexPath.section-1].salesexecPresent
                case 4:
                    cell.contentLabel.text = filteredItems[indexPath.section-1].salesexecAbsent
                default:
                    break
                }
                //cell.backgroundColor = UIColor.groupTableViewBackground
            }
            return cell
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if(indexPath.section == 0 && indexPath.row == 0 && !showLoc){
            let sb = UIStoryboard(name: "Search", bundle: nil)
            let popup = sb.instantiateInitialViewController()! as! SearchViewController
            popup.modalPresentationStyle = .overFullScreen
            popup.delegate = self
            popup.from = "branch"
            self.present(popup, animated: true)
        }
    }
    
    func showSearchValue(value: String) {
        if value == "ALL" {
            filteredItems = self.attendanceObj
            self.CollectionView.reloadData()
            self.CollectionView.collectionViewLayout.invalidateLayout()
            return
        }
        filteredItems = self.attendanceObj.filter { $0.branchName == value }
        self.CollectionView.reloadData()
        self.CollectionView.collectionViewLayout.invalidateLayout()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if let destination = segue.destination as? AttendanceChildController,
                let index = CollectionView.indexPathsForSelectedItems?.first{
                if index.section > 0{
                    if showLoc{
                        destination.locDataToRecieve = [filteredLoc[index.section-1]]
                        destination.currDate = todayDate
                        destination.fromLoc = true
                        destination.type = index.row == 1 ? 3 : index.row == 2 ? 4 : index.row == 3 ? 1 : 2
                    }else{
                        destination.dataToRecieve = [filteredItems[index.section-1]]
                        destination.currDate = todayDate
                        destination.fromLoc = false
                        destination.type = index.row == 1 ? 3 : index.row == 2 ? 4 : index.row == 3 ? 1 : 2
                    }
                }
                else{
                    return
                }
            }
    }


    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        //Block Segue if branchname is clicked...
        if let index = CollectionView.indexPathsForSelectedItems?.first{
            if((index.section) > 0){
                if showLoc{
                    if index.section == self.filteredLoc.count + 1{
                        return false
                    } else {
                        return true
                    }
                }else{
                    if index.section == self.filteredItems.count + 1{
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
 
    //API CALL...
    func apiBranchwiseAtt(){
        let json: [String: Any] = ["CIN":UserDefaults.standard.value(forKey: "userCIN") as! String,"Cat":UserDefaults.standard.value(forKey: "userCategory") as! String,"ClientSecret":"ClientSecret","date":todayDate]
        let manager =  DataManager.shared
        print("Params Sent : \(json)")
        manager.makeAPICall(url: apiBranchAttendance, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            
            do {
                self.attendanceData = try JSONDecoder().decode([Attendance].self, from: data!)
                self.attendanceObj  = self.attendanceData[0].data
                self.filteredItems  = self.attendanceData[0].data
                self.present = Int(self.filteredItems.reduce(0, { $0 + Double($1.employeePresent!)! }))
                self.absent = Int(self.filteredItems.reduce(0, { $0 + Double($1.employeeAbsent!)! }))
                self.salesPresent = Int(self.filteredItems.reduce(0, { $0 + Double($1.salesexecPresent!)! }))
                self.salesAbsent = Int(self.filteredItems.reduce(0, { $0 + Double($1.salesexecAbsent!)! }))
                self.totalPresent = self.present + self.salesPresent
                self.totalAbsent = self.absent + self.salesAbsent
                self.empPresent.setAttributedTitle(self.setPresent(value: "Present : \(self.totalPresent)", present: "Present"), for: .normal)
                self.empAbsent.setAttributedTitle(self.setAbsent(value: "Absent : \(self.totalAbsent)", present: "Absent"), for: .normal)
                
                self.totalEmployees.text = "Total Employees : \(self.totalAbsent + self.totalPresent)"
                self.totalChart.text = "\(self.totalPresent + self.totalAbsent)"
                self.setChart(dataPoints: ["Absent,Present"], values: ["\(self.totalAbsent)","\(self.totalPresent)"])
                self.heightConstraint.constant = CGFloat((((self.filteredItems.count+1) * 35) + 10))
                self.CollectionView.reloadData()
                self.CollectionView.collectionViewLayout.invalidateLayout()
//                self.noDataView.hideView(view: self.noDataView)
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
    
    func apiLocnAttendance(){
        let json: [String: Any] = ["CIN":UserDefaults.standard.value(forKey: "userCIN") as! String,"Cat":UserDefaults.standard.value(forKey: "userCategory") as! String,"ClientSecret":"ClientSecret","date":todayDate]
        let manager =  DataManager.shared
        print("Params Sent : \(json)")
        manager.makeAPICall(url: apiLocAttendance, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            
            do {
                self.locAttendanceData = try JSONDecoder().decode([LocationAttendance].self, from: data!)
                self.locAttendanceObj  = self.locAttendanceData[0].data
                self.filteredLoc  = self.locAttendanceData[0].data
                self.present = Int(self.filteredLoc.reduce(0, { $0 + Double($1.employeePresent!)! }))
                self.absent = Int(self.filteredLoc.reduce(0, { $0 + Double($1.employeeAbsent!)! }))
                self.salesPresent = Int(self.filteredLoc.reduce(0, { $0 + Double($1.salesexecPresent!)! }))
                self.salesAbsent = Int(self.filteredLoc.reduce(0, { $0 + Double($1.salesexecAbsent!)! }))
                self.totalPresent = self.present + self.salesPresent
                self.totalAbsent = self.absent + self.salesAbsent
                self.heightConstraint.constant = CGFloat((((self.filteredLoc.count+1) * 35) + 10))
                self.CollectionView.reloadData()
                self.CollectionView.collectionViewLayout.invalidateLayout()
                //                self.noDataView.hideView(view: self.noDataView)
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
    
    
    
    func setPresent(value: String, present: String) -> NSAttributedString{
        let strNumber: NSString = value as NSString // you must set your
        let range = (strNumber).range(of: String(present))
        let attribute = NSMutableAttributedString.init(string: strNumber as String)
            attribute.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.green , range: range)
        return attribute
    }
    
    func setAbsent(value: String, present: String) -> NSAttributedString{
        let strNumber: NSString = value as NSString // you must set your
        let range = (strNumber).range(of: String(present))
        let attribute = NSMutableAttributedString.init(string: strNumber as String)
        attribute.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.red , range: range)
        return attribute
    }
    
    //PieChart Functions...
    func setChart(dataPoints: [String], values: [String]){
        
        var dataEntries: [PieChartDataEntry] = []
        
        empPieChart.drawHoleEnabled = true
        empPieChart.holeRadiusPercent = 0.5
        empPieChart.chartDescription?.text = ""
        empPieChart.rotationEnabled = false
        empPieChart.highlightPerTapEnabled = false
        empPieChart.legend.enabled = false
        empPieChart.animate(yAxisDuration: 1.5, easingOption: ChartEasingOption.easeOutBack)
        
        for i in 0..<values.count {
            let dataEntry = PieChartDataEntry(value: Double(values[i])!, label: "")
            dataEntries.append(dataEntry)
        }
        
        //print("DATA ENTRIES ------------------------  ",dataEntries)
        
        let chartDataSet = PieChartDataSet(entries: dataEntries, label: "")
        chartDataSet.drawValuesEnabled = false
        chartDataSet.colors = colorArray
        
        let chartData = PieChartData(dataSet: chartDataSet)
        empPieChart.data = chartData
        
    }

}
