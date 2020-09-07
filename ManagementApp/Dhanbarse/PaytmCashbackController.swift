//
//  PaytmCashbackController.swift
//  ManagementApp
//
//  Created by Goldmedal on 15/08/20.
//  Copyright © 2020 Goldmedal. All rights reserved.
//
struct PaytmCashbackCat: Codable {
    let result: Bool?
    let message, servertime: String?
    let data: [PaytmCashbackCatObj]
}


struct PaytmCashbackCatObj: Codable {
    let sateName: String?
    let sateId, retailer, electrician, counterBoy: String?
}

struct PaytmCashDiv: Codable {
    let result: Bool?
    let message, servertime: String?
    let data: [PaytmCashDivObj]
}


struct PaytmCashDivObj: Codable {
    let sateId, sateName, wiringdevices, wirecable: String?
    let mcbdbs: String?
}

import UIKit
import Charts

class PaytmCashbackController: BaseViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    //Outlets...
    @IBOutlet weak var fromDate: UIButton!
    @IBOutlet weak var toDate: UIButton!
    @IBOutlet var pieChart: PieChartView!
    @IBOutlet weak var totalChart: UILabel!
    @IBOutlet weak var CollectionView: IntrinsicCollectionViews!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var btnState: RoundButton!
    @IBOutlet weak var btnBranch: RoundButton!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var sort: UIBarButtonItem!
    
    //Declaration...
    var apiDhanbarse = ""
    var dhanData = [PaytmCashbackCat]()
    var dhanObj = [PaytmCashbackCatObj]()
    var filteredItems = [PaytmCashbackCatObj]()
    var apiDhanbarseMonth = ""
    var dhanMonthData = [PaytmCashDiv]()
    var dhanMonthObj = [PaytmCashDivObj]()
    var filteredMonths = [PaytmCashDivObj]()
    var totalElectrician = 0
    var totalRetailer = 0
    var totalCounterboy = 0
    var showState = true
    var cellContentIdentifier = "\(CollectionViewCell.self)"
    let colorArray = [UIColor.red, UIColor.green, UIColor.yellow, UIColor.orange, UIColor.brown, UIColor.yellow, UIColor.purple, UIColor.yellow, UIColor.magenta,UIColor.darkGray,UIColor.red, UIColor.green, UIColor.blue, UIColor.orange, UIColor.brown, UIColor.cyan, UIColor.purple, UIColor.yellow, UIColor.magenta,UIColor.darkGray]
//    var fromDateString = "06/01/2019"
//    var toDateString = Utility.currDate()
//    var fromDateCalender: Date?
//    var toDateCalender: Date?
//    let currDate = Date()
//    var dateFormatter = DateFormatter()
//    let formatter = DateFormatter()
//    var someDateTime = Date()
    var fromclicked = false
    var status = "1"
    var index = 0
    var sumOfTotals = 0
    var isagent = false

    override func viewDidLoad() {
        super.viewDidLoad()
        addSlideMenuButton()
//        if UserDefaults.standard.value(forKey: "userCategory") as! String == "Agent"{
//            isagent = true
//        }else{
//            isagent = false
//        }
        let statusClick = UITapGestureRecognizer(target: self, action: #selector(self.clickedStatus))
        lblStatus.addGestureRecognizer(statusClick)
//        formatter.dateFormat = "MM/dd/yyyy HH:mm"
//        someDateTime = formatter.date(from: "06/01/2019 02:31")!
//        dateFormatter.dateFormat = "dd/MM/yyyy"
//        toDateCalender = dateFormatter.date(from: dateFormatter.string(from: currDate))
//        fromDateCalender = dateFormatter.date(from: dateFormatter.string(from: someDateTime))
//        fromDate.setTitle("From Date : \(getIndianDate(value: fromDateString))", for: .normal)
//        toDate.setTitle("To Date : \(getIndianDate(value: toDateString))", for: .normal)
        apiDhanbarse = "https://test2.goldmedalindia.in/api/getcashbackcountdatacategorywise"
        apiDhanbarseMonth = "https://test2.goldmedalindia.in/api/getcashbackcountdatadivisionwise"
        ViewControllerUtils.sharedInstance.showLoader()
        apiGetDhanData()
    }
    
    //SORT....
    @IBAction func clickedSort(_ sender: UIBarButtonItem) {
        let sb = UIStoryboard(name: "Sorting", bundle: nil)
        let popup = sb.instantiateInitialViewController()! as! SortViewController
        popup.modalPresentationStyle = .overFullScreen
        popup.delegate = self
        popup.showPicker = 1
        popup.pickerDataSource = showState ? ["High to Low Retailer","High to Low Electrician","High to Low CounterBoy","Low to High Retailer","Low to High Electrician","Low to High CounterBoy"] : ["High to Low Wiring Devices","High to Low Wire & Cable","High to Low Mcb&Dbs","Low to High Wiring Devices","Low to High Wire & Cable","Low to High &"]
        self.present(popup, animated: true)
    }
    
    //Tab Click Func...
    @IBAction func clickedState(_ sender: Any) {
        showState = true
        btnState.backgroundColor = UIColor.darkGray
        btnState.setTitleColor(UIColor.white, for: .normal)
        btnBranch.backgroundColor = UIColor.white
        btnBranch.setTitleColor(UIColor.black, for: .normal)
        ViewControllerUtils.sharedInstance.showLoader()
        apiGetDhanData()
    }
    
    @IBAction func clickedMonth(_ sender: Any) {
        showState = false
        btnState.backgroundColor = UIColor.white
        btnState.setTitleColor(UIColor.black, for: .normal)
        btnBranch.backgroundColor = UIColor.darkGray
        btnBranch.setTitleColor(UIColor.white, for: .normal)
        ViewControllerUtils.sharedInstance.showLoader()
        apiGetDhanMonthData()
    }
    
    //Filter Related...
    @objc func clickedStatus(tapGestureRecognizer: UITapGestureRecognizer)
    {
        let sb = UIStoryboard(name: "Sorting", bundle: nil)
        let popup = sb.instantiateInitialViewController()! as! SortViewController
        popup.modalPresentationStyle = .overFullScreen
        popup.delegate = self
        popup.showPicker = 1
        popup.pickerDataSource = ["All","Scan on Hold","Payout"]
        self.present(popup, animated: true)
    }
    
    func sortBy(value: String, position: Int) {
        switch value {
        
        case "All" :
            status = "1"
            lblStatus.text = value
            break
        case "Scan on Hold" :
            status = "2"
            lblStatus.text = value
            break
        case "Payout" :
            status = "3"
            lblStatus.text = value
            break
        default:
            break
        }
        //status = value
        //lblStatus.text = value
        ViewControllerUtils.sharedInstance.showLoader()
        if showState{
            apiGetDhanData()
        }else{
            apiGetDhanMonthData()
        }

    }
    
    func getIndianDate(value: String) -> String{
        var inFormatDate = value.split{$0 == "/"}.map(String.init)
        let temp = "\(inFormatDate[1])/\(inFormatDate[0])/\(inFormatDate[2])"
        return temp
    }
    
    //Date Clicked....
//    @IBAction func clickedFromDate(_ sender: UIButton) {
//        fromclicked = true
//        let sb = UIStoryboard(name: "DatePicker", bundle: nil)
//        let popup = sb.instantiateInitialViewController()  as? DatePickerController
//        popup?.delegate = self
//        popup?.toDate = fromDateCalender
//        popup?.fromDate = fromDateCalender
//        popup?.isFromDate = true
//        popup?.truce = true
//        self.present(popup!, animated: true)
//    }
//
//    @IBAction func clickedToDate(_ sender: UIButton) {
//        fromclicked = false
//        let sb = UIStoryboard(name: "DatePicker", bundle: nil)
//        let popup = sb.instantiateInitialViewController()  as? DatePickerController
//        popup?.delegate = self
//        popup?.toDate = toDateCalender
//        popup?.fromDate = fromDateCalender
//        popup?.isFromDate = false
//        self.present(popup!, animated: true)
//    }
//
//    func updateDate(value: String, date: Date) {
//        if fromclicked{
//            fromDate.setTitle("From Date : \(value)", for: .normal)
//            var usFormatDate = value.split{$0 == "/"}.map(String.init)
//            fromDateString = "\(usFormatDate[1])/\(usFormatDate[0])/\(usFormatDate[2])"
//        }else{
//            toDate.setTitle("To Date : \(value)", for: .normal)
//            var usFormatDate = value.split{$0 == "/"}.map(String.init)
//            toDateString = "\(usFormatDate[1])/\(usFormatDate[0])/\(usFormatDate[2])"
//        }
//        ViewControllerUtils.sharedInstance.showLoader()
//        if showState{
//            apiGetDhanData()
//        }else{
//            apiGetDhanMonthData()
//        }
//    }
    
    //CollectionView Functions......
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if !showState{
            return filteredMonths.count + 2
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
        if !showState{
            if indexPath.section == 0 {
                cell.contentLabel.font = UIFont(name: "Roboto-Medium", size: 16)
                if #available(iOS 11.0, *) {
                    cell.backgroundColor = UIColor.init(named: "Primary")
                } else {
                    cell.backgroundColor = UIColor.gray
                }
                switch indexPath.row{
                case 0:
                    cell.contentLabel.text = "State Name"
                case 1:
                    cell.contentLabel.text = "Wiring Devices"
                case 2:
                    cell.contentLabel.text = "Wiring & Cable"
                case 3:
                    cell.contentLabel.text = "Mcb&Dbs"
                case 4:
                    cell.contentLabel.text = "Total"
                    
                default:
                    break
                }
                //cell.backgroundColor = UIColor.lightGray
            }else if indexPath.section == filteredMonths.count+1{
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
                    cell.contentLabel.text = String(totalRetailer)
                case 2:
                    cell.contentLabel.text = String(totalElectrician)
                case 3:
                    cell.contentLabel.text = String(totalCounterboy)
                case 4:
                    cell.contentLabel.text = String(sumOfTotals)
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
                let tempTotal = Int(filteredMonths[indexPath.section-1].wiringdevices! + filteredMonths[indexPath.section-1].wirecable! + filteredMonths[indexPath.section-1].mcbdbs!)
                switch indexPath.row{
                case 0:
                    cell.contentLabel.text = filteredMonths[indexPath.section-1].sateName
                case 1:
                    let currentYear = Double(filteredMonths[indexPath.section-1].wiringdevices!)
                    let prevYear = Double(totalRetailer)
                    let temp = (currentYear!*100)/prevYear
                    cell.contentLabel.attributedText = calculatePercentage(currentYear: currentYear!, prevYear: prevYear, temp: temp)
                case 2:
                    let currentYear = Double(filteredMonths[indexPath.section-1].wirecable!)
                    let prevYear = Double(totalElectrician)
                    let temp = (currentYear!*100)/prevYear
                    cell.contentLabel.attributedText = calculatePercentage(currentYear: currentYear!, prevYear: prevYear, temp: temp)
                case 3:
                    let currentYear = Double(filteredMonths[indexPath.section-1].mcbdbs!)
                    let prevYear = Double(totalCounterboy)
                    let temp = (currentYear!*100)/prevYear
                    cell.contentLabel.attributedText = calculatePercentage(currentYear: currentYear!, prevYear: prevYear, temp: temp)
                case 4:
                    let totalCB = Double(filteredMonths[indexPath.section-1].wiringdevices!)
                    let totalR = Double(filteredMonths[indexPath.section-1].wirecable!)
                    let totalE = Double(filteredMonths[indexPath.section-1].mcbdbs!)
                    let tempSum = Double(totalCB! + totalR! + totalE!) 
                    let currentYear = (tempSum)
                    let prevYear = Double(sumOfTotals)
                    let temp = (currentYear*100)/prevYear
                    cell.contentLabel.attributedText = calculatePercentage(currentYear: currentYear, prevYear: prevYear, temp: temp)
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
                    cell.contentLabel.text = "State Name"
                case 1:
                    cell.contentLabel.text = "Retailer"
                case 2:
                    cell.contentLabel.text = "Electrician"
                case 3:
                    cell.contentLabel.text = "CounterBoy"
                case 4:
                    cell.contentLabel.text = "Total"
                    
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
                    cell.contentLabel.text = String(totalRetailer)
                case 2:
                    cell.contentLabel.text = String(totalElectrician)
                case 3:
                    cell.contentLabel.text = String(totalCounterboy)
                case 4:
                    cell.contentLabel.text = String(sumOfTotals)
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
                let tempTotal = Double(filteredItems[indexPath.section-1].counterBoy! + filteredItems[indexPath.section-1].electrician! + filteredItems[indexPath.section-1].retailer!)
                switch indexPath.row{
                    
                case 0:
                    cell.contentLabel.text = filteredItems[indexPath.section-1].sateName
                case 1:
                    let currentYear = Double(filteredItems[indexPath.section-1].retailer!)
                    let prevYear = Double(totalRetailer)
                    let temp = (currentYear!*100)/prevYear
                    cell.contentLabel.attributedText = calculatePercentage(currentYear: Double(currentYear!), prevYear: Double(prevYear), temp: temp)
                case 2:
                    let currentYear = Double(filteredItems[indexPath.section-1].electrician!)
                    let prevYear = Double(totalElectrician)
                    let temp = (currentYear!*100)/prevYear
                    cell.contentLabel.attributedText = calculatePercentage(currentYear: Double(currentYear!), prevYear: Double(prevYear), temp: temp)
                case 3:
                    let currentYear = Double(filteredItems[indexPath.section-1].counterBoy!)
                    let prevYear = Double(totalCounterboy)
                    let temp = (currentYear!*100)/prevYear
                    cell.contentLabel.attributedText = calculatePercentage(currentYear: Double(currentYear!), prevYear: Double(prevYear), temp: temp)
                case 4:
                    let totalCB = Double(filteredItems[indexPath.section-1].counterBoy!)
                    let totalR = Double(filteredItems[indexPath.section-1].retailer!)
                    let totalE = Double(filteredItems[indexPath.section-1].electrician!)
                    let tempSum = Double(totalCB! + totalR! + totalE!)
                    let currentYear = Double(tempSum)
                    let prevYear = Double(sumOfTotals)
                    let temp = (currentYear*100)/prevYear
                    cell.contentLabel.attributedText = calculatePercentage(currentYear: Double(currentYear), prevYear: Double(prevYear), temp: temp)
                default:
                    break
                }
                //cell.backgroundColor = UIColor.groupTableViewBackground
            }
            return cell
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if(indexPath.row == 0 && showState && indexPath.section == 0){
            filteredItems = dhanObj
            let sb = UIStoryboard(name: "Search", bundle: nil)
            let popup = sb.instantiateInitialViewController()! as! SearchViewController
            popup.modalPresentationStyle = .overFullScreen
            popup.delegate = self
            //popup.stateItems = filteredItems
            popup.from = "state"
            self.present(popup, animated: true)
        }
//        if showState && indexPath.section > 0 && indexPath.section != (filteredItems.count+1){
//            index = (indexPath.section-1)
//            performSegue(withIdentifier: "segueDhanbarse", sender: self)
//        }
    }
    
    func showSearchValue(value: String) {
        if value == "ALL" {
            filteredItems = self.dhanObj
            self.CollectionView.reloadData()
            self.CollectionView.collectionViewLayout.invalidateLayout()
            return
        }
        filteredItems = self.dhanObj.filter { $0.sateName == value }
        self.CollectionView.reloadData()
        self.CollectionView.collectionViewLayout.invalidateLayout()
        
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if (segue.identifier == "segueDhanbarse") {
//            if let destination = segue.destination as? DhanbarseChildController{
//                destination.showState = false
////                destination.fromDateString = fromDateString
////                destination.toDateString = toDateString
////                destination.dataToRecieve = [filteredItems[index]]
//
//            }else{
//
//            }
//        }
//
//    }
    
    //PieChart Functions...
    func setChart(dataPoints: [String], values: [String]){
        
        var dataEntries: [PieChartDataEntry] = []
        
        pieChart.drawHoleEnabled = true
        pieChart.holeRadiusPercent = 0.5
        pieChart.chartDescription?.text = ""
        pieChart.rotationEnabled = true
        pieChart.highlightPerTapEnabled = true
        pieChart.drawEntryLabelsEnabled = true
        pieChart.legend.enabled = false
        pieChart.animate(yAxisDuration: 1.5, easingOption: ChartEasingOption.easeOutBack)
        
        for i in 0..<values.count {
            let dataEntry = PieChartDataEntry(value: Double(values[i])!, label: (dataPoints[i]))
            dataEntries.append(dataEntry)
        }
        
        //print("DATA ENTRIES ------------------------  ",dataEntries)
        
        let chartDataSet = PieChartDataSet(entries: dataEntries, label: "")
        chartDataSet.drawValuesEnabled = false
        chartDataSet.colors = colorArray
        chartDataSet.valueTextColor = UIColor.black
        
        
        let chartData = PieChartData(dataSet: chartDataSet)
        pieChart.data = chartData
        
    }
    
    //Calculate percentage func...
    func calculatePercentage(currentYear: Double, prevYear: Double, temp: Double) -> NSAttributedString{
        let sale = Utility.formatRupee(amount: Double(currentYear ))
        let tempVar = String(format: "%.2f", temp)
        var formattedPerc = ""
        if (Double(tempVar)!.isInfinite) || (Double(tempVar)!.isNaN){
            formattedPerc = ""
        }else{
            formattedPerc = " (\(String(format: "%.2f", temp)))%"
        }
        let strNumber: NSString = sale + formattedPerc as NSString // you must set your
        let range = (strNumber).range(of: String(tempVar))
        let attribute = NSMutableAttributedString.init(string: strNumber as String)
        if temp > 0{
            attribute.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor(named: "ColorGreen") as Any , range: range)
        }else{
            attribute.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.red as Any , range: range)
        }
        return attribute
    }
    
    
    //API....
    func apiGetDhanData(){
        let json: [String: Any] = ["CIN":UserDefaults.standard.value(forKey: "userCIN") as! String,"Category":UserDefaults.standard.value(forKey: "userCategory") as! String,"ClientSecret":"ClientSecret","Stateid":"27,7,18,38,33,19,20,21,22,23,24,25,26","Categoryid":"8,9,11","StatusType":status]
        let manager =  DataManager.shared
        print("Params Sent : \(json)")
        manager.makeAPICall(url: "https://test2.goldmedalindia.in/api/getcashbackcountdatacategorywise", params: json, method: .POST, success: { (response) in
            let data = response as? Data
            
            do {
                self.dhanData = try JSONDecoder().decode([PaytmCashbackCat].self, from: data!)
                self.dhanObj  = self.dhanData[0].data
                self.filteredItems  = self.dhanData[0].data
                self.totalRetailer = Int(self.filteredItems.reduce(0, { $0 + Double($1.retailer!)! }))
                self.totalElectrician = Int(self.filteredItems.reduce(0, { $0 + Double($1.electrician!)! }))
                self.totalCounterboy = Int(self.filteredItems.reduce(0, { $0 + Double($1.counterBoy!)! }))
                self.sumOfTotals = self.totalElectrician + self.totalCounterboy + self.totalRetailer
                self.totalChart.text = String(self.sumOfTotals)
                self.setChart(dataPoints: ["Retailer - \(self.totalRetailer)","Electrician - \(self.totalElectrician)","CounterBoy - \(self.totalCounterboy)"], values: ["\(self.totalRetailer)","\(self.totalElectrician)","\(self.totalCounterboy)"])
                self.heightConstraint.constant = CGFloat((((self.filteredItems.count+1) * 35) + 10))
                self.CollectionView.reloadData()
                self.CollectionView.collectionViewLayout.invalidateLayout()
                //                self.noDataView.hideView(view: self.noDataView)
                ViewControllerUtils.sharedInstance.removeLoader()
            } catch let errorData {
                print(errorData.localizedDescription)
                ViewControllerUtils.sharedInstance.removeLoader()
                let alert = UIAlertController(title: "Alert", message: "No Data Found", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }) { (Error) in
            print(Error?.localizedDescription as Any)
            ViewControllerUtils.sharedInstance.removeLoader()
            let alert = UIAlertController(title: "Alert", message: "No Data Found", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Okay", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func apiGetDhanMonthData(){
//        var inFormatDate = toDateString.split{$0 == "/"}.map(String.init)
//        var inFormatDateTwo = fromDateString.split{$0 == "/"}.map(String.init)
//        let temp = "\(inFormatDate[2])-\(inFormatDate[0])-\(inFormatDate[1])"
//        let temp2 = "\(inFormatDateTwo[2])-\(inFormatDateTwo[0])-\(inFormatDateTwo[1])"
        let json: [String: Any] = ["CIN":UserDefaults.standard.value(forKey: "userCIN") as! String,"Category":UserDefaults.standard.value(forKey: "userCategory") as! String,"ClientSecret":"ClientSecret","Stateid":"27,7,18,38,33,19,20,21,22,23,24,25,26","divisionid":"1,4,7","StatusType":status]
        let manager =  DataManager.shared
        print("Params Sent : \(json)")
        manager.makeAPICall(url: apiDhanbarseMonth, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            
            do {
                self.dhanMonthData = try JSONDecoder().decode([PaytmCashDiv].self, from: data!)
                self.dhanMonthObj  = self.dhanMonthData[0].data
                self.filteredMonths  = self.dhanMonthData[0].data
                self.totalRetailer = Int(self.filteredMonths.reduce(0, { $0 + Double($1.wiringdevices!)! }))
                self.totalElectrician = Int(self.filteredMonths.reduce(0, { $0 + Double($1.wirecable!)! }))
                self.totalCounterboy = Int(self.filteredMonths.reduce(0, { $0 + Double($1.mcbdbs!)! }))
                self.sumOfTotals = self.totalElectrician + self.totalCounterboy + self.totalRetailer
                    //Int(self.filteredMonths.reduce(0, { $0 + Double($1.wiringdevices! + $1.wirecable! + $1.mcbdbs!)! }))
                self.totalChart.text = String(self.sumOfTotals)
                self.setChart(dataPoints: ["Wiring Devices - \(self.totalRetailer)","Wire & Cable - \(self.totalElectrician)","Mcb&Dbs - \(self.totalCounterboy)"], values: ["\(self.totalRetailer)","\(self.totalElectrician)","\(self.totalCounterboy)"])
                self.heightConstraint.constant = CGFloat((((self.filteredMonths.count+1) * 35) + 10))
                self.CollectionView.reloadData()
                self.CollectionView.collectionViewLayout.invalidateLayout()
                //                self.noDataView.hideView(view: self.noDataView)
                ViewControllerUtils.sharedInstance.removeLoader()
            } catch let errorData {
                print(errorData.localizedDescription)
                ViewControllerUtils.sharedInstance.removeLoader()
                let alert = UIAlertController(title: "Alert", message: "No Data Found", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }) { (Error) in
            print(Error?.localizedDescription as Any)
            ViewControllerUtils.sharedInstance.removeLoader()
            let alert = UIAlertController(title: "Alert", message: "No Data Found", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }

}
