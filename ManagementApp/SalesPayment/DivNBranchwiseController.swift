//
//  DivNBranchwiseController.swift
//  ManagementApp
//
//  Created by Goldmedal on 12/06/19.
//  Copyright © 2019 Goldmedal. All rights reserved.
//

import UIKit
import Charts

class DivNBranchwiseController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, PopupDateDelegate {
    
    //Outlets...
    @IBOutlet weak var collectionView: IntrinsicCollectionViewDiv!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var btnDivision: RoundButton!
    @IBOutlet weak var btnBranch: RoundButton!
    @IBOutlet weak var noDataView: NoDataView!
    @IBOutlet weak var btnFromDate: UIButton!
    @IBOutlet weak var btnToDate: UIButton!
    @IBOutlet weak var scrollVw: UIScrollView!
    @IBOutlet var catPieChart: PieChartView!
    @IBOutlet weak var pieHeightConstraint: NSLayoutConstraint!
    
    //Declarations...
    var cellContentIdentifier = "\(CollectionViewCell.self)"
    var format = ""
    var fromdate = ""
    var todate = ""
    var divApiUrl = ""
    var branchApiUrl = ""
    var dashDivSale = [DashDivSale]()
    var dashDivObj = [DivSaleObj]()
    var dashBranchSale = [DashBranch]()
    var dashBranchObj = [DashBranchObj]()
    var totalAmount = 0.0
    var showDiv = true
    var refreshControl = UIRefreshControl()
    var fromDate: Date?
    var toDate: Date?
    var strFromDate = ""
    var strToDate = ""
    var dateFormatter = DateFormatter()
    let tabNames = [ "Wiring Devices", "Lights", "Wire & Cables",  "Pipes & Fitting","Mcb & Dbs"]
    let colorArray = [UIColor.red, UIColor.green, UIColor.blue, UIColor.orange, UIColor.brown, UIColor.yellow, UIColor.purple, UIColor.yellow, UIColor.magenta,UIColor.darkGray,UIColor.red, UIColor.green, UIColor.blue, UIColor.orange, UIColor.brown, UIColor.cyan, UIColor.purple, UIColor.yellow, UIColor.magenta,UIColor.darkGray]
    let colorCellArray = [UIColor.init(named: "ColorRed"), UIColor.init(named: "ColorGreen"), UIColor.blue, UIColor.orange, UIColor.brown, UIColor.init(named: "ColorYellow")]
    var colors: [UIColor] = []
    var catWiseValue = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setDate()
        self.noDataView.showView(view: self.noDataView, from: "LOADER")
        addRefreshControl()
        divApiUrl = "https://test2.goldmedalindia.in/api/GetTodaySaleDivisionwise"
        branchApiUrl = "https://test2.goldmedalindia.in/api/GetTodaySaleBranchwise"
        apiDivisionwiseSale()
        //scrollVw.contentSize = CGSize(width: 375, height: 2000)
    }
    
    //Pull to Refresh...
    func addRefreshControl(){
        refreshControl.tintColor = UIColor(named: "DashboardHeader")
        refreshControl.backgroundColor = UIColor.white
        refreshControl.addTarget(self, action: #selector(refreshContents), for: .valueChanged)
        if #available(iOS 10.0, *){
            collectionView.refreshControl = refreshControl
        }else{
            collectionView.addSubview(refreshControl)
        }
        //self.collectionView.alwaysBounceVertical = true
    }
    
    @objc func refreshContents(){
        if(showDiv)
        {
            apiDivisionwiseSale()
        }else{
            apiBranchwiseSale()
        }
    }
    
    //Button Functions...
    @IBAction func backBtnClick(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func clickedDiv(_ sender: Any) {
        self.pieHeightConstraint.constant = CGFloat(220)
        showDiv = true
        btnDivision.backgroundColor = UIColor.darkGray
        btnDivision.setTitleColor(UIColor.white, for: .normal)
        btnBranch.backgroundColor = UIColor.white
        btnBranch.setTitleColor(UIColor.black, for: .normal)
        self.noDataView.showView(view: self.noDataView, from: "LOADER")
        apiDivisionwiseSale()
    }
    
    @IBAction func clickedBranch(_ sender: Any) {
        self.pieHeightConstraint.constant = CGFloat(0)
        showDiv = false
        btnDivision.backgroundColor = UIColor.white
        btnDivision.setTitleColor(UIColor.black, for: .normal)
        btnBranch.backgroundColor = UIColor.darkGray
        btnBranch.setTitleColor(UIColor.white, for: .normal)
        self.noDataView.showView(view: self.noDataView, from: "LOADER")
        apiBranchwiseSale()
    }
    
    @IBAction func clicked(_ sender: Any) {
    }
    
    @IBAction func clicked_from_date_div(_ sender: UIButton) {
        sender.isSelected = true
        let sb = UIStoryboard(name: "DatePicker", bundle: nil)
        let popup = sb.instantiateInitialViewController()  as? DatePickerController
        popup?.fromDate = fromDate
        popup?.toDate = toDate
        popup?.isFromDate = true
        popup?.delegate = self
        self.present(popup!, animated: true)
    }
    
    
    @IBAction func clicked_to_date_div(_ sender: UIButton) {
        sender.isSelected = true
        let sb = UIStoryboard(name: "DatePicker", bundle: nil)
        let popup = sb.instantiateInitialViewController()  as? DatePickerController
        popup?.delegate = self
        popup?.toDate = toDate
        popup?.fromDate = fromDate
        popup?.isFromDate = false
        self.present(popup!, animated: true)
    }
    
    //Date Functions...
    func setDate(){
        let currDate = Date()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        strToDate = dateFormatter.string(from: currDate)
        switch format {
        case "today":
            fromDate = dateFormatter.date(from: strFromDate)
            toDate = dateFormatter.date(from: strToDate)
            btnFromDate.setTitle(strToDate, for: .normal)
            btnToDate.setTitle(strToDate, for: .normal)
            //strFromDate = Utility.formattedDateFromString(dateString: strFromDate, withFormat: "MM/dd/yyyy")!
            strFromDate = Utility.formattedDateFromString(dateString: strToDate, withFormat: "MM/dd/yyyy")!
            strToDate = Utility.formattedDateFromString(dateString: strToDate, withFormat: "MM/dd/yyyy")!
            break
        case "monthly":
            var todayDate = Calendar.current.component(.day, from: currDate)
            todayDate = Int(todayDate) - 1
            strFromDate = dateFormatter.string(from: Calendar.current.date(byAdding: .day, value: -todayDate, to: currDate)!)
            fromDate = dateFormatter.date(from: strFromDate)
            toDate = dateFormatter.date(from: strToDate)
            btnFromDate.setTitle(strFromDate, for: .normal)
            btnToDate.setTitle(strToDate, for: .normal)
            //strFromDate = Utility.formattedDateFromString(dateString: strFromDate, withFormat: "MM/dd/yyyy")!
            strFromDate = Utility.formattedDateFromString(dateString: strFromDate, withFormat: "MM/dd/yyyy")!
            strToDate = Utility.formattedDateFromString(dateString: strToDate, withFormat: "MM/dd/yyyy")!
            break
        case "quarterly":
            strFromDate = Utility.formattedDateFromString(dateString: "07/01/2019", withFormat: "MM/dd/yyyy")!
            strToDate = dateFormatter.string(from: currDate)
            btnFromDate.setTitle("01/07/2019", for: .normal)
            btnToDate.setTitle(strToDate, for: .normal)
            break
        case "yearly":
            let dateformatter = DateFormatter()
            dateformatter.dateFormat = "yyyy"
            let currYear = dateformatter.string(from: currDate) 
            strFromDate = Utility.formattedDateFromString(dateString: "04/01/" + currYear, withFormat: "MM/dd/yyyy")!
            strToDate = Utility.formattedDateFromString(dateString: strToDate, withFormat: "dd/MM/yyyy")!
            fromDate = dateFormatter.date(from: strFromDate)
            toDate = dateFormatter.date(from: strToDate)
            btnFromDate.setTitle(strFromDate, for: .normal)
            btnToDate.setTitle(strToDate, for: .normal)
            break
        default:
            break
        }
    }
    
    func updateDate(value: String, date: Date) {
        if btnFromDate.isSelected {
            btnFromDate.setTitle(value, for: .normal)
            btnFromDate.isSelected = false
            fromDate = date
            strFromDate = Utility.formattedDateFromString(dateString: value, withFormat: "MM/dd/yyyy")!
            fromdate = strFromDate
        }
        else
        {
            btnToDate.setTitle(value, for: .normal)
            btnToDate.isSelected = false
            toDate = date
            strToDate = Utility.formattedDateFromString(dateString: value, withFormat: "MM/dd/yyyy")!
            todate = strToDate
        }
        
        if showDiv{
            apiDivisionwiseSale()
        }else{
            apiBranchwiseSale()
        }
    }
    
    //PieChart Functions...
    func setChart(dataPoints: [String], values: [String]){
        
        var dataEntries: [PieChartDataEntry] = []
        
        catPieChart.drawHoleEnabled = true
        catPieChart.holeRadiusPercent = 0.5
        catPieChart.chartDescription?.text = ""
        catPieChart.rotationEnabled = false
        catPieChart.highlightPerTapEnabled = false
        catPieChart.legend.enabled = false
        catPieChart.animate(yAxisDuration: 1.5, easingOption: ChartEasingOption.easeOutBack)
        
        for i in 0..<values.count {
            let dataEntry = PieChartDataEntry(value: Double(values[i])!, label: "")
            dataEntries.append(dataEntry)
        }
        
        print("DATA ENTRIES ------------------------  ",dataEntries)
        
        let chartDataSet = PieChartDataSet(entries: dataEntries, label: "")
        chartDataSet.drawValuesEnabled = false
        chartDataSet.colors = colorArray
        
        let chartData = PieChartData(dataSet: chartDataSet)
        catPieChart.data = chartData
        
    }
    
    //CollectionView Functions...
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if(showDiv){
            return dashDivObj.count + 2
        }else{
            return dashBranchObj.count + 2
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellContentIdentifier,
                                                      for: indexPath) as! CollectionViewCell
        cell.layer.borderWidth = 1
        cell.layer.borderColor = UIColor.white.cgColor
        if(showDiv)
        {
            if indexPath.section == 0 {
                cell.contentLabel.font = UIFont(name: "Roboto-Medium", size: 16)
                if #available(iOS 11.0, *) {
                    cell.backgroundColor = UIColor.init(named: "Primary")
                } else {
                    cell.backgroundColor = UIColor.gray
                }
                switch indexPath.row{
                case 0:
                    cell.contentLabel.text = "Division Name"
                case 1:
                    cell.contentLabel.text = "Amount"
                case 2:
                    cell.contentLabel.text = "Contri %"
                default:
                    break
                }
                
            }else if indexPath.section == self.dashDivObj.count + 1 {
                cell.contentLabel.font = UIFont(name: "Roboto-Medium", size: 16)
                cell.contentLabel.textColor = UIColor.black
                if #available(iOS 11.0, *) {
                    cell.backgroundColor = UIColor.init(named: "Primary")
                } else {
                    cell.backgroundColor = UIColor.gray
                }
                switch indexPath.row{
                case 0:
                    cell.contentLabel.text = "SUM"
                case 1:
                    cell.contentLabel.text = Utility.formatRupee(amount: Double(totalAmount ))
                case 2:
                    cell.contentLabel.text = "100%"
                    
                default:
                    break
                }
            }  else {
                cell.contentLabel.font = UIFont(name: "Roboto-Regular", size: 14)
                if #available(iOS 11.0, *) {
                    cell.backgroundColor = UIColor.init(named: "primaryLight")
                } else {
                    cell.backgroundColor = UIColor.lightGray
                }
                switch indexPath.row{
                case 0:
                    cell.contentLabel.textColor = self.colorCellArray[indexPath.section-1]
                    cell.contentLabel.text = self.dashDivObj[indexPath.section-1].divisionnm
                case 1:
                    cell.contentLabel.textColor = UIColor.black
                    if let amount = self.dashDivObj[indexPath.section-1].amount
                    {
                        cell.contentLabel.text = Utility.formatRupee(amount: Double(amount )!)
                    }
                case 2:
                    cell.contentLabel.textColor = UIColor.black
                    let percentage = ((Double(self.dashDivObj[indexPath.section - 1].amount!)! / totalAmount)*100)
                    cell.contentLabel.text = "\(String(format: "%.2f", percentage))%"
                    
                default:
                    break
                }
                
            }
            
        } else {
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
                    cell.contentLabel.text = "Amount"
                case 2:
                    cell.contentLabel.text = "Contri %"
                default:
                    break
                }
                
            }else if indexPath.section == self.dashBranchObj.count + 1 {
                cell.contentLabel.font = UIFont(name: "Roboto-Medium", size: 16)
                if #available(iOS 11.0, *) {
                    cell.backgroundColor = UIColor.init(named: "Primary")
                } else {
                    cell.backgroundColor = UIColor.gray
                }
                switch indexPath.row{
                case 0:
                    cell.contentLabel.text = "SUM"
                case 1:
                    cell.contentLabel.text = Utility.formatRupee(amount: Double(totalAmount ))
                case 2:
                    cell.contentLabel.text = "100%"
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
                    cell.contentLabel.text =  self.dashBranchObj[indexPath.section-1].branchnm
                case 1:
                    if let amount = self.dashBranchObj[indexPath.section-1].amount
                    {
                        cell.contentLabel.text = Utility.formatRupee(amount: Double(amount )!)
                    }
                case 2:
                    let percentage = ((Double(self.dashBranchObj[indexPath.section - 1].amount!)! / totalAmount)*100)
                    cell.contentLabel.text = "\(String(format: "%.2f", percentage))%"
                    
                default:
                    break
                }
                cell.contentLabel.textColor = UIColor.black
                
            }
        }
        
        return cell
        
    }
    
    //API Function...
    func apiDivisionwiseSale(){
        let json: [String: Any] = ["ClientSecret":"jgsfhfdk", "fromdate":fromdate, "todate":todate,"CIN":UserDefaults.standard.value(forKey: "userCIN") as! String,"Category":UserDefaults.standard.value(forKey: "userCategory") as! String]
        let manager =  DataManager.shared
            print("Dashboard Sale Detail Params Div Wise \(json)")
        manager.makeAPICall(url: divApiUrl, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            print("Dashboard Sale Detail Result Div Wise \(data)")
            do {
                //self.dashBranchObj.removeAll()
                self.dashDivSale = try JSONDecoder().decode([DashDivSale].self, from: data!)
                self.dashDivObj  = self.dashDivSale[0].data 
                //                self.filteredItems = self.stockData[0].data
                //Total of All Items...
                self.totalAmount = self.dashDivObj.reduce(0, { $0 + Double($1.amount!)! })
                self.collectionView.reloadData()
                self.collectionView.collectionViewLayout.invalidateLayout()
                self.noDataView.hideView(view: self.noDataView)
                ViewControllerUtils.sharedInstance.removeLoader()
                self.refreshControl.endRefreshing()
                self.heightConstraint.constant = CGFloat((((self.dashDivObj.count+1) * 35) + 10))
                self.catWiseValue.removeAll()
                    for i in self.dashDivObj {
                        self.catWiseValue.append(i.amount ?? "0")
                    }
                
            } catch let errorData {
                print(errorData.localizedDescription)
                self.noDataView.hideView(view: self.noDataView)
                self.refreshControl.endRefreshing()
            }
            
            if(self.catWiseValue.count > 0){
                self.setChart(dataPoints: [""], values: self.catWiseValue)
            }else{
//                self.showView(view: self.noDataView, from: "NDA")
//                self.tblCatSales.showNoDataPie = true
            }
            
        }) { (Error) in
            print(Error?.localizedDescription as Any)
            self.noDataView.hideView(view: self.noDataView)
            self.refreshControl.endRefreshing()
        }
    }
    
    func apiBranchwiseSale(){
        let json: [String: Any] = ["ClientSecret":"jgsfhfdk", "fromdate":fromdate, "todate":todate,"CIN":UserDefaults.standard.value(forKey: "userCIN") as! String,"Category":UserDefaults.standard.value(forKey: "userCategory") as! String]
        let manager =  DataManager.shared
        print("Dashboard Sale Detail Result Branch Wise \(json)")
        manager.makeAPICall(url: branchApiUrl, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            print("Dashboard Sale Detail Result Branch Wise \(data)")
            do {
                //self.dashDivObj.removeAll()
                self.dashBranchSale = try JSONDecoder().decode([DashBranch].self, from: data!)
                self.dashBranchObj  = self.dashBranchSale[0].data
                //self.filteredItems = self.stockData[0].data
                //Total of All Items...
                self.totalAmount = self.dashBranchObj.reduce(0, { $0 + Double($1.amount!)! })
                self.collectionView.reloadData()
                self.collectionView.collectionViewLayout.invalidateLayout()
                self.noDataView.hideView(view: self.noDataView)
                self.refreshControl.endRefreshing()
                self.heightConstraint.constant = CGFloat((((self.dashBranchObj.count+1) * 35) + 10))
            } catch let errorData {
                print(errorData.localizedDescription)
                self.noDataView.hideView(view: self.noDataView)
                self.refreshControl.endRefreshing()
            }
        }) { (Error) in
            print(Error?.localizedDescription as Any)
            self.noDataView.hideView(view: self.noDataView)
            self.refreshControl.endRefreshing()
        }
    }
}


class IntrinsicCollectionViewDiv: UICollectionView {
    var showNoData = false
    override var contentSize:CGSize {
        didSet {
            self.invalidateIntrinsicContentSize()
        }
    }
    
    override var intrinsicContentSize: CGSize {
        self.layoutIfNeeded()
        return CGSize(width: UIViewNoIntrinsicMetric, height: (showNoData) ? 300 : contentSize.height)
    }
    
}
