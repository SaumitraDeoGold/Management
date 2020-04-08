//
//  DhanbarseChildController.swift
//  ManagementApp
//
//  Created by Goldmedal on 03/04/20.
//  Copyright © 2020 Goldmedal. All rights reserved.
//

import UIKit
import Charts

class DhanbarseChildController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, PopupDateDelegate  {
    
    //Outlets...
    @IBOutlet weak var fromDate: UIButton!
    @IBOutlet weak var toDate: UIButton!
    @IBOutlet var pieChart: PieChartView!
    @IBOutlet weak var totalChart: UILabel!
    @IBOutlet weak var CollectionView: IntrinsicCollectionViews!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var heightConstStatus: NSLayoutConstraint!
    @IBOutlet weak var heightConstPie: NSLayoutConstraint!
    @IBOutlet weak var btnState: RoundButton!
    @IBOutlet weak var btnBranch: RoundButton!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var noDataView: NoDataView!
    @IBOutlet weak var lblPieHeader: UILabel!
    @IBOutlet weak var sort: UIBarButtonItem!
    
    var apiDhanbarseChild = ""
    var dhanDistrictData = [DistrictwiseDhan]()
    var dhanDistrictObj = [DistrictwiseDhanObj]()
    var filteredDis = [DistrictwiseDhanObj]()
    var apiDistrictDhan = ""
    var dhanData = [DhanbarseChild]()
    var dhanObj = [DhanbarseChildObj]()
    var filteredItems = [DhanbarseChildObj]()
    var dataToRecieve = [DhanbarseObj]()
    var totalApproved = 0
    var totalRejected = 0
    var totalPending = 0
    var showState = true
    var cellContentIdentifier = "\(CollectionViewCell.self)"
    let colorArray = [UIColor.red, UIColor.green, UIColor.yellow, UIColor.orange, UIColor.brown, UIColor.yellow, UIColor.purple, UIColor.yellow, UIColor.magenta,UIColor.darkGray,UIColor.red, UIColor.green, UIColor.blue, UIColor.orange, UIColor.brown, UIColor.cyan, UIColor.purple, UIColor.yellow, UIColor.magenta,UIColor.darkGray]
    var fromDateString = ""
    var toDateString = ""
    var fromDateCalender: Date?
    var toDateCalender: Date?
    let currDate = Date()
    var dateFormatter = DateFormatter()
    let formatter = DateFormatter()
    var someDateTime = Date()
    var fromclicked = false
    var status = "All"
    var totalElectrician = 0
    var totalRetailer = 0
    var totalCounterboy = 0
    var index = 0
    var sumOfTotals = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        lblPieHeader.text = dataToRecieve[0].stateName
        self.noDataView.hideView(view: self.noDataView)
        apiDhanbarseChild = "https://test2.goldmedalindia.in/api/getuserstatewisecnt"
        apiDistrictDhan = "https://test2.goldmedalindia.in/api/getuseraprstatusdistrictwisecnt"
        let statusClick = UITapGestureRecognizer(target: self, action: #selector(self.clickedStatus))
        lblStatus.addGestureRecognizer(statusClick)
        fromDate.setTitle("From Date : \(getIndianDate(value: fromDateString))", for: .normal)
        toDate.setTitle("To Date : \(getIndianDate(value: toDateString))", for: .normal)
        ViewControllerUtils.sharedInstance.showLoader()
        apiGetDhanData()
    }
    
    //SORT....
    
    @IBAction func sort(_ sender: Any) {
        let sb = UIStoryboard(name: "Sorting", bundle: nil)
        let popup = sb.instantiateInitialViewController()! as! SortViewController
        popup.modalPresentationStyle = .overFullScreen
        popup.delegate = self
        popup.showPicker = 1
        popup.pickerDataSource = ["High to Low Retailer","High to Low Electrician","High to Low CounterBoy","Low to High Retailer","Low to High Electrician","Low to High CounterBoy"]
        self.present(popup, animated: true)
    }
     
    
    //Filter Related...
    @objc func clickedStatus(tapGestureRecognizer: UITapGestureRecognizer)
    {
        let sb = UIStoryboard(name: "Sorting", bundle: nil)
        let popup = sb.instantiateInitialViewController()! as! SortViewController
        popup.modalPresentationStyle = .overFullScreen
        popup.delegate = self
        popup.showPicker = 1
        popup.pickerDataSource = ["All","Approved","Rejected","Pending"]
        self.present(popup, animated: true)
    }
    
    func sortBy(value: String, position: Int) {
        switch value {
        case "Low to High Retailer":
            if showState{
                
            }else{
                self.filteredDis = self.dhanDistrictObj.sorted(by: {Double($0.retailer!) < Double($1.retailer!)})
            }
            self.CollectionView.reloadData()
            self.CollectionView.collectionViewLayout.invalidateLayout()
            return
        case "Low to High Electrician":
            if showState{
                
            }else{
                self.filteredDis = self.dhanDistrictObj.sorted(by: {Double($0.electrician!) < Double($1.electrician!)})
            }
            self.CollectionView.reloadData()
            self.CollectionView.collectionViewLayout.invalidateLayout()
            return
        case "Low to High CounterBoy":
            if showState{
                
            }else{
                self.filteredDis = self.dhanDistrictObj.sorted(by: {Double($0.counterBoy!) < Double($1.counterBoy!)})
            }
            self.CollectionView.reloadData()
            self.CollectionView.collectionViewLayout.invalidateLayout()
            return
        case "High to Low Retailer":
            if showState{
                
            }else{
                self.filteredDis = self.dhanDistrictObj.sorted(by: {Double($0.retailer!) > Double($1.retailer!)})
            }
            self.CollectionView.reloadData()
            self.CollectionView.collectionViewLayout.invalidateLayout()
            return
        case "High to Low Electrician":
            if showState{
                
            }else{
                self.filteredDis = self.dhanDistrictObj.sorted(by: {Double($0.electrician!) > Double($1.electrician!)})
            }
            self.CollectionView.reloadData()
            self.CollectionView.collectionViewLayout.invalidateLayout()
            return
        case "High to Low CounterBoy":
            if showState{
                
            }else{
                self.filteredDis = self.dhanDistrictObj.sorted(by: {Double($0.counterBoy!) > Double($1.counterBoy!)})
            }
            self.CollectionView.reloadData()
            self.CollectionView.collectionViewLayout.invalidateLayout()
            return
        default:
            break
        }
        if !showState{
            status = value
            lblStatus.text = value
            ViewControllerUtils.sharedInstance.showLoader()
            apiGetDhanDisData()
        }
        
    }
    
    func getIndianDate(value: String) -> String{
        var inFormatDate = value.split{$0 == "/"}.map(String.init)
        let temp = "\(inFormatDate[1])/\(inFormatDate[0])/\(inFormatDate[2])"
        return temp
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
    
    @IBAction func clickedDist(_ sender: Any) {
        showState = false
        btnState.backgroundColor = UIColor.white
        btnState.setTitleColor(UIColor.black, for: .normal)
        btnBranch.backgroundColor = UIColor.darkGray
        btnBranch.setTitleColor(UIColor.white, for: .normal)
        ViewControllerUtils.sharedInstance.showLoader()
        apiGetDhanDisData()
    }
    
    //Date Clicked....
    @IBAction func clickedFromDate(_ sender: UIButton) {
        fromclicked = true
        let sb = UIStoryboard(name: "DatePicker", bundle: nil)
        let popup = sb.instantiateInitialViewController()  as? DatePickerController
        popup?.delegate = self
        popup?.toDate = fromDateCalender
        popup?.fromDate = fromDateCalender
        popup?.isFromDate = true
        popup?.truce = true
        self.present(popup!, animated: true)
    }
    
    @IBAction func clickedToDate(_ sender: UIButton) {
        fromclicked = false
        let sb = UIStoryboard(name: "DatePicker", bundle: nil)
        let popup = sb.instantiateInitialViewController()  as? DatePickerController
        popup?.delegate = self
        popup?.toDate = toDateCalender
        popup?.fromDate = fromDateCalender
        popup?.isFromDate = false
        self.present(popup!, animated: true)
    }
    
    func updateDate(value: String, date: Date) {
        if fromclicked{
            fromDate.setTitle("From Date : \(value)", for: .normal)
            var usFormatDate = value.split{$0 == "/"}.map(String.init)
            fromDateString = "\(usFormatDate[1])/\(usFormatDate[0])/\(usFormatDate[2])"
        }else{
            toDate.setTitle("To Date : \(value)", for: .normal)
            var usFormatDate = value.split{$0 == "/"}.map(String.init)
            toDateString = "\(usFormatDate[1])/\(usFormatDate[0])/\(usFormatDate[2])"
        }
        ViewControllerUtils.sharedInstance.showLoader()
        if showState{
           apiGetDhanData()
        }else{
            apiGetDhanDisData()
        }
        
    }
    
    //CollectionView Functions......
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if !showState{
            return filteredDis.count + 2
        }else{
            return 5
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
                    cell.contentLabel.text = "District Name"
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
            }else if indexPath.section == filteredDis.count+1{
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
                switch indexPath.row{
                case 0:
                    cell.contentLabel.text = filteredDis[indexPath.section-1].district
                case 1:
                    let currentYear = Int(filteredDis[indexPath.section-1].retailer!)
                    let prevYear = Int(totalRetailer)
                    let temp = (currentYear*100)/prevYear
                    cell.contentLabel.attributedText = calculatePercentage(currentYear: currentYear, prevYear: prevYear, temp: temp)
                case 2:
                    let currentYear = Int(filteredDis[indexPath.section-1].electrician!)
                    let prevYear = Int(totalElectrician)
                    let temp = (currentYear*100)/prevYear
                    cell.contentLabel.attributedText = calculatePercentage(currentYear: currentYear, prevYear: prevYear, temp: temp)
                case 3:
                    let currentYear = Int(filteredDis[indexPath.section-1].counterBoy!)
                    let prevYear = Int(totalCounterboy)
                    let temp = (currentYear*100)/prevYear
                    cell.contentLabel.attributedText = calculatePercentage(currentYear: currentYear, prevYear: prevYear, temp: temp)
                case 4:
                    let tempSum = Int(filteredDis[indexPath.section-1].counterBoy! + filteredDis[indexPath.section-1].electrician! + filteredDis[indexPath.section-1].retailer!)
                    let currentYear = Int(tempSum)
                    let prevYear = Int(sumOfTotals)
                    let temp = (currentYear*100)/prevYear
                    cell.contentLabel.attributedText = calculatePercentage(currentYear: currentYear, prevYear: prevYear, temp: temp)
                default:
                    break
                }
            }
            return cell
        }else if filteredItems.count > 0{
            if indexPath.section == 0 {
                cell.contentLabel.font = UIFont(name: "Roboto-Medium", size: 16)
                if #available(iOS 11.0, *) {
                    cell.backgroundColor = UIColor.init(named: "Primary")
                } else {
                    cell.backgroundColor = UIColor.gray
                }
                switch indexPath.row{
                case 0:
                    cell.contentLabel.text = "Status"
                case 1:
                    cell.contentLabel.text = "Approved"
                case 2:
                    cell.contentLabel.text = "Pending"
                case 3:
                    cell.contentLabel.text = "Rejected"
                case 4:
                    cell.contentLabel.text = "Total"
                    
                default:
                    break
                }
                //cell.backgroundColor = UIColor.lightGray
            }else if indexPath.section == 4{
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
                    cell.contentLabel.text = String(totalApproved)
                case 2:
                    cell.contentLabel.text = String(totalPending)
                case 3:
                    cell.contentLabel.text = String(totalRejected)
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
                switch indexPath.row{
                case 0:
                    if indexPath.section == 1{
                        cell.contentLabel.text = "Electrician"
                    }else if indexPath.section == 2{
                        cell.contentLabel.text = "Retailer"
                    }else if indexPath.section == 3{
                        cell.contentLabel.text = "CounterBoy"
                    }
                    
                case 1:
                    if indexPath.section == 1{
                        let currentYear = Int(filteredItems[0].aprElectrician!)
                        let prevYear = Int(totalApproved)
                        let temp = (currentYear*100)/prevYear
                        cell.contentLabel.attributedText = calculatePercentage(currentYear: currentYear, prevYear: prevYear, temp: temp)
                    }else if indexPath.section == 2{
                        let currentYear = Int(filteredItems[0].aprRetailer!)
                        let prevYear = Int(totalApproved)
                        let temp = (currentYear*100)/prevYear
                        cell.contentLabel.attributedText = calculatePercentage(currentYear: currentYear, prevYear: prevYear, temp: temp)
                    }else if indexPath.section == 3{
                        let currentYear = Int(filteredItems[0].aprCounterBoy!)
                        let prevYear = Int(totalApproved)
                        let temp = (currentYear*100)/prevYear
                        cell.contentLabel.attributedText = calculatePercentage(currentYear: currentYear, prevYear: prevYear, temp: temp)
                    }
                    
                case 2:
                    if indexPath.section == 1{
                        let currentYear = Int(filteredItems[0].penElectrician!)
                        let prevYear = Int(totalPending)
                        let temp = (currentYear*100)/prevYear
                        cell.contentLabel.attributedText = calculatePercentage(currentYear: currentYear, prevYear: prevYear, temp: temp)
                    }else if indexPath.section == 2{
                        let currentYear = Int(filteredItems[0].penRetailer!)
                        let prevYear = Int(totalPending)
                        let temp = (currentYear*100)/prevYear
                        cell.contentLabel.attributedText = calculatePercentage(currentYear: currentYear, prevYear: prevYear, temp: temp)
                    }else if indexPath.section == 3{
                        let currentYear = Int(filteredItems[0].penCounterBoy!)
                        let prevYear = Int(totalPending)
                        let temp = (currentYear*100)/prevYear
                        cell.contentLabel.attributedText = calculatePercentage(currentYear: currentYear, prevYear: prevYear, temp: temp)
                    }
                case 3:
                    if indexPath.section == 1{
                        let currentYear = Int(filteredItems[0].rejElectrician!)
                        let prevYear = Int(totalRejected)
                        let temp = (currentYear*100)/prevYear
                        cell.contentLabel.attributedText = calculatePercentage(currentYear: currentYear, prevYear: prevYear, temp: temp)
                    }else if indexPath.section == 2{
                        let currentYear = Int(filteredItems[0].rejRetailer!)
                        let prevYear = Int(totalRejected)
                        let temp = (currentYear*100)/prevYear
                        cell.contentLabel.attributedText = calculatePercentage(currentYear: currentYear, prevYear: prevYear, temp: temp)
                    }else if indexPath.section == 3{
                        let currentYear = Int(filteredItems[0].rejCounterBoy!)
                        let prevYear = Int(totalRejected)
                        let temp = (currentYear*100)/prevYear
                        cell.contentLabel.attributedText = calculatePercentage(currentYear: currentYear, prevYear: prevYear, temp: temp)
                    }
                case 4:
                    if indexPath.section == 1{
                        let tempSum = Int(filteredItems[0].aprElectrician! + filteredItems[0].penElectrician! + filteredItems[0].rejElectrician!)
                        let currentYear = Int(tempSum)
                        let prevYear = Int(sumOfTotals)
                        let temp = (currentYear*100)/prevYear
                        cell.contentLabel.attributedText = calculatePercentage(currentYear: currentYear, prevYear: prevYear, temp: temp)
                    }else if indexPath.section == 2{
                        let tempSum = Int(filteredItems[0].aprRetailer! + filteredItems[0].penRetailer! + filteredItems[0].rejRetailer!)
                        let currentYear = Int(tempSum)
                        let prevYear = Int(sumOfTotals)
                        let temp = (currentYear*100)/prevYear
                        cell.contentLabel.attributedText = calculatePercentage(currentYear: currentYear, prevYear: prevYear, temp: temp)
                    }else if indexPath.section == 3{
                        let tempSum = Int(filteredItems[0].aprCounterBoy! + filteredItems[0].penCounterBoy! + filteredItems[0].rejCounterBoy!)
                        let currentYear = Int(tempSum)
                        let prevYear = Int(sumOfTotals)
                        let temp = (currentYear*100)/prevYear
                        cell.contentLabel.attributedText = calculatePercentage(currentYear: currentYear, prevYear: prevYear, temp: temp)
                    }
                default:
                    break
                }
                //cell.backgroundColor = UIColor.groupTableViewBackground
            }
            return cell
         }else{
            return cell
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if(indexPath.row == 0 && !showState && indexPath.section == 0){
            filteredDis = dhanDistrictObj
            let sb = UIStoryboard(name: "Search", bundle: nil)
            let popup = sb.instantiateInitialViewController()! as! SearchViewController
            popup.modalPresentationStyle = .overFullScreen
            popup.delegate = self
            popup.distItems = filteredDis
            popup.from = "dist"
            self.present(popup, animated: true)
        }
        if !showState && indexPath.section > 0 && indexPath.section != (filteredDis.count+1){
            index = (indexPath.section-1)
            performSegue(withIdentifier: "segueDistrict", sender: self)
        }
    }
    
    func showSearchValue(value: String) {
        if value == "ALL" {
            filteredDis = self.dhanDistrictObj
            self.CollectionView.reloadData()
            self.CollectionView.collectionViewLayout.invalidateLayout()
            return
        }
        filteredDis = self.dhanDistrictObj.filter { $0.district == value }
        self.CollectionView.reloadData()
        self.CollectionView.collectionViewLayout.invalidateLayout()
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "segueDistrict") {
            if let destination = segue.destination as? DhanDisChildController{
                destination.showDist = !showState
                destination.fromDateString = fromDateString
                destination.toDateString = toDateString
                destination.dataToRecieve = [filteredDis[index]]
                destination.statename = dataToRecieve[0].stateName!
                
            }else{
                
            }
        }
        
    }
    
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
    func calculatePercentage(currentYear: Int, prevYear: Int, temp: Int) -> NSAttributedString{
        let sale = String(currentYear)//Utility.formatRupee(amount: Double(currentYear ))
        let tempVar = String(format: "%.2f", Double(temp))
        var formattedPerc = ""
        if (Double(tempVar)!.isNaN){
            formattedPerc = ""
        }else{
            formattedPerc = " (\(String(format: "%.2f", Double(temp))))%"
        }
        let strNumber: NSString = sale + formattedPerc as NSString // you must set your
        let range = (strNumber).range(of: String(tempVar))
        let attribute = NSMutableAttributedString.init(string: strNumber as String)
        if Double(temp) > 0.0{
            attribute.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor(named: "ColorGreen") as Any , range: range)
        }else{
            attribute.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.red as Any , range: range)
        }
        return attribute
    }
    
    //API....
    func apiGetDhanData(){
        let json: [String: Any] = ["CIN":UserDefaults.standard.value(forKey: "userCIN") as! String,"Cat":UserDefaults.standard.value(forKey: "userCategory") as! String,"ClientSecret":"ClientSecret","Fromdate":fromDateString,"Todate":toDateString,"Stateid":dataToRecieve[0].stateId ?? 1]
        let manager =  DataManager.shared
        print("Params Sent : \(json)")
        manager.makeAPICall(url: apiDhanbarseChild, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            
            do {
                self.dhanData = try JSONDecoder().decode([DhanbarseChild].self, from: data!)
                self.dhanObj  = self.dhanData[0].data
                self.filteredItems  = self.dhanData[0].data
                self.totalApproved = (self.filteredItems[0].aprCounterBoy!) + (self.filteredItems[0].aprRetailer!) + (self.filteredItems[0].aprElectrician!)
                self.totalRejected = (self.filteredItems[0].rejRetailer!) + (self.filteredItems[0].rejCounterBoy!) + (self.filteredItems[0].rejElectrician!)
                self.totalPending = (self.filteredItems[0].penRetailer!) + (self.filteredItems[0].penCounterBoy!) + (self.filteredItems[0].penElectrician!)
                self.sumOfTotals = (self.totalRejected) + (self.totalApproved) + (self.totalPending)
                self.totalChart.text = String(self.sumOfTotals)
                self.setChart(dataPoints: ["Rejected - \(self.totalRejected)","Approved - \(self.totalApproved)","Pending - \(self.totalPending)"], values: ["\(self.totalRejected)","\(self.totalApproved)","\(self.totalPending)"])
                self.heightConstraint.constant = CGFloat((((self.filteredItems.count+1) * 35) + 10))
                self.CollectionView.reloadData()
                self.CollectionView.collectionViewLayout.invalidateLayout()
                self.noDataView.hideView(view: self.noDataView)
                ViewControllerUtils.sharedInstance.removeLoader()
            } catch let errorData {
                print(errorData.localizedDescription)
                self.noDataView.showView(view: self.noDataView, from: "NDA")
                ViewControllerUtils.sharedInstance.removeLoader()
                let alert = UIAlertController(title: "Alert", message: "No Data Found", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }) { (Error) in
            print(Error?.localizedDescription as Any)
            self.noDataView.showView(view: self.noDataView, from: "NDA")
            ViewControllerUtils.sharedInstance.removeLoader()
            let alert = UIAlertController(title: "Alert", message: "No Data Found", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func apiGetDhanDisData(){
        let json: [String: Any] = ["CIN":UserDefaults.standard.value(forKey: "userCIN") as! String,"Cat":UserDefaults.standard.value(forKey: "userCategory") as! String,"ClientSecret":"ClientSecret","Fromdate":fromDateString,"Todate":toDateString,"ApproveStatus":status,"Stateid":dataToRecieve[0].stateId ?? 1]
        let manager =  DataManager.shared
        print("Params Sent : \(json)")
        manager.makeAPICall(url: apiDistrictDhan, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            
            do {
                self.dhanDistrictData = try JSONDecoder().decode([DistrictwiseDhan].self, from: data!)
                self.dhanDistrictObj  = self.dhanDistrictData[0].data
                self.filteredDis  = self.dhanDistrictData[0].data
                self.totalRetailer = Int(self.filteredDis.reduce(0, { $0 + Double($1.retailer!) }))
                self.totalElectrician = Int(self.filteredDis.reduce(0, { $0 + Double($1.electrician!) }))
                self.totalCounterboy = Int(self.filteredDis.reduce(0, { $0 + Double($1.counterBoy!) }))
                self.sumOfTotals = Int(self.filteredDis.reduce(0, { $0 + Double($1.retailer! + $1.electrician! + $1.counterBoy!) }))
                self.totalChart.text = String(self.sumOfTotals)
                self.setChart(dataPoints: ["Retailer - \(self.totalRetailer)","Electrician - \(self.totalElectrician)","CounterBoy - \(self.totalCounterboy)"], values: ["\(self.totalRetailer)","\(self.totalElectrician)","\(self.totalCounterboy)"])
                self.heightConstraint.constant = CGFloat((((self.filteredItems.count+1) * 35) + 10))
                self.CollectionView.reloadData()
                self.CollectionView.collectionViewLayout.invalidateLayout()
                self.noDataView.hideView(view: self.noDataView)
                ViewControllerUtils.sharedInstance.removeLoader()
            } catch let errorData {
                print(errorData.localizedDescription)
                self.noDataView.showView(view: self.noDataView, from: "NDA")
                ViewControllerUtils.sharedInstance.removeLoader()
            }
        }) { (Error) in
            print(Error?.localizedDescription as Any)
            self.noDataView.showView(view: self.noDataView, from: "NDA")
            ViewControllerUtils.sharedInstance.removeLoader()
        }
    }
 

}
