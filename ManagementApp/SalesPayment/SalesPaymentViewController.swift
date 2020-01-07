//
//  SalesPaymentViewController.swift
//  ManagementApp
//
//  Created by Goldmedal on 19/03/19.
//  Copyright © 2019 Goldmedal. All rights reserved.
//

import UIKit

class SalesPaymentViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, PopupDateDelegate {
    
    //Outlets
    @IBOutlet weak var vwToday: UIView!
    @IBOutlet weak var vwMonthly: UIView!
    @IBOutlet weak var vwQuarterly: UIView!
    @IBOutlet weak var vwYearly: UIView!
    @IBOutlet weak var lblSaleTdy: UILabel!
    @IBOutlet weak var lblPayment: UILabel!
    @IBOutlet weak var lblSaleMnthly: UILabel!
    @IBOutlet weak var lblPayMnthly: UILabel!
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
    
    //Declarations...
    let apiUrlTodaySale = "https://api.goldmedalindia.in/api/GetTodaySale"
    let apiUrlTodayPayment = "https://api.goldmedalindia.in/api/GetTodayPayment"
    var apiUrlBranchProgress = ""
    var apiUrlStateProgress = ""
    var todaySalesData = [TodaySales]()
    var todaySaleObj = [TodaySaleObj]()
    var todayPayData = [TodayPayment]()
    var todayPaymentObj = [TodayPaymentObj]()
    var branchProgress = [BranchProgress]()
    var branchProObj = [BranchProgressObj]()
    var filteredItems = [BranchProgressObj]()
    var statewise = [Statewise]()
    var statewiseObj = [StatewiseObj]()
    var filteredState = [StatewiseObj]()
    var cellContentIdentifier = "\(CollectionViewCell.self)"
    var totalCurrSale = ["currSale":0.0,"lastSale":0.0,"yearBeforeLast":0.0]
    var counterToday = 0
    var counterMonthly = 0
    var counterQrtrly = 0
    var counterYearly = 0
    var totalSale = ["todaySale":0,"monthlySale":0,"qtrlySale":0,"yearlySale":0]
    var totalPayment = ["todayPayment":0,"monthlyPayment":0,"qtrlyPayment":0,"yearlyPayment":0]
    var refreshControl = UIRefreshControl()
    let monthEnds = Utility.getMonthEndDate()
    var showState = false
    var customDivLayout = BranchProgressLayout()
    var noOfColumns = Int()
    var totalStatewiseSale = ["currSale":0.0,"lastSale":0.0,"yearBeforeLast":0.0]
    
    override func viewDidLoad() {
        apiUrlBranchProgress = "https://api.goldmedalindia.in/api/GetBranchwiseSalesCompare"
        apiUrlStateProgress = "https://test2.goldmedalindia.in/api/GetStatewiseSalesCompare"
        super.viewDidLoad()
        ViewControllerUtils.sharedInstance.showLoader()
        addRefreshControl()
        apiGetTodaySale()
        apiGetTodayPayment()
        self.noOfColumns = 4
        apiGetCompareProgress()
        let todayClick = UITapGestureRecognizer(target: self, action: #selector(self.clickedToday))
        vwToday.addGestureRecognizer(todayClick)
        let yearClick = UITapGestureRecognizer(target: self, action: #selector(self.clickedYearly))
        vwYearly.addGestureRecognizer(yearClick)
        let monthClick = UITapGestureRecognizer(target: self, action: #selector(self.clickedMonthly))
        vwMonthly.addGestureRecognizer(monthClick)
        let qrtrClick = UITapGestureRecognizer(target: self, action: #selector(self.clickedQrtrly))
        vwQuarterly.addGestureRecognizer(qrtrClick)
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        sort.isUserInteractionEnabled = true
        sort.addGestureRecognizer(tapGestureRecognizer)
        //yearDate()
    }
    
    //Sort Related...
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        let sb = UIStoryboard(name: "Sorting", bundle: nil)
        let popup = sb.instantiateInitialViewController()! as! SortViewController
        popup.modalPresentationStyle = .overFullScreen
        popup.delegate = self
        popup.showPicker = 1
        popup.pickerDataSource = ["A-Z","Z-A","low to high Current Sale","high to low Current Sale"]
        self.present(popup, animated: true)
    }
    
    func sortBy(value: String, position: Int) {
        if showState {
            switch position {
            case 0:
                self.filteredState = self.statewiseObj.sorted{($0.statenm).localizedCaseInsensitiveCompare($1.statenm) == .orderedAscending}
            case 1:
                self.filteredState = self.statewiseObj.sorted{($0.statenm).localizedCaseInsensitiveCompare($1.statenm) == .orderedDescending}
            case 2:
                self.filteredState = self.statewiseObj.sorted(by: {Double($0.currentyearsale)! < Double($1.currentyearsale)!})
            case 3:
                self.filteredState = self.statewiseObj.sorted(by: {Double($0.currentyearsale)! > Double($1.currentyearsale)!})
            default:
                break
            }
        } else {
            switch position {
            case 0:
                self.filteredItems = self.branchProObj.sorted{($0.branchnm).localizedCaseInsensitiveCompare($1.branchnm) == .orderedAscending}
            case 1:
                self.filteredItems = self.branchProObj.sorted{($0.branchnm).localizedCaseInsensitiveCompare($1.branchnm) == .orderedDescending}
            case 2:
                self.filteredItems = self.branchProObj.sorted(by: {Double($0.currentyearsale)! < Double($1.currentyearsale)!})
            case 3:
                self.filteredItems = self.branchProObj.sorted(by: {Double($0.currentyearsale)! > Double($1.currentyearsale)!})
            default:
                break
            }
        }
        self.CollectionView.reloadData()
        self.CollectionView.collectionViewLayout.invalidateLayout()
    }
    
    //Button Functions...
    @objc func clickedToday(sender: UITapGestureRecognizer) {
        let now = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        let todayDate = dateFormatter.string(from: now)
        _ = UIStoryboard(name: "Main", bundle: nil)
        
        //For whole month...
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "MM"
        let yearlyFormatter = DateFormatter()
        yearlyFormatter.dateFormat = "yyyy"
        _ = dayFormatter.string(from: now)
        let currMonth = dayFormatter.string(from: now)
        let currYear = yearlyFormatter.string(from: now)
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "DivNBranch") as! DivNBranchwiseController
        vc.fromdate = todayDate
        vc.todate = todayDate
        vc.dailyfromdate = "\(currMonth)/01/\(currYear)"
        vc.dailytodate = "\(currMonth)/\(monthEnds[Int(currMonth)!-1])\(currYear)"
        vc.format = "today"
        present(vc, animated: true, completion: nil)
    }
    
    @objc func clickedQrtrly(sender: UITapGestureRecognizer) {
//        let now = Date()
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "MM"
//        let yearFormatter = DateFormatter()
//        yearFormatter.dateFormat = "yyyy"
//        _ = dateFormatter.string(from: now)
        let (fromdate, todate) = quarterlyDate()
        _ = UIStoryboard(name: "Main", bundle: nil)
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "DivNBranch") as! DivNBranchwiseController
        vc.fromdate = fromdate//"01/01/\(currYear)"
        vc.todate = todate//"03/31/\(currYear)"
        vc.format = "quarterly"
        present(vc, animated: true, completion: nil)
    }
    
    @objc func clickedMonthly(sender: UITapGestureRecognizer) {
        let now = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM"
        let yearFormatter = DateFormatter()
        yearFormatter.dateFormat = "yyyy"
        let currMonth = dateFormatter.string(from: now)
        let currYear = yearFormatter.string(from: now)
        
        _ = UIStoryboard(name: "Main", bundle: nil)
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "DivNBranch") as! DivNBranchwiseController
        vc.fromdate = "\(currMonth)/01/\(currYear)"
        vc.todate = "\(currMonth)/\(monthEnds[Int(currMonth)!-1])\(currYear)"
        vc.format = "monthly"
        present(vc, animated: true, completion: nil)
    }
    
    @objc func clickedYearly(sender: UITapGestureRecognizer) {
        let (fromdate, todate) = yearDate()
        print(".....................>Fromdate : \(fromdate) ToDate : \(todate)")
        _ = UIStoryboard(name: "Main", bundle: nil)
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "DivNBranch") as! DivNBranchwiseController
        vc.fromdate = fromdate//"04/01/" + String(prevYear)
        vc.todate = todate//"03/31/" + String(currYear)
        vc.format = "yearly"
        present(vc, animated: true, completion: nil)
    }
    
    func quarterlyDate() -> (String, String){
        let now = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy"
        let yearFormatter = DateFormatter()
        yearFormatter.dateFormat = "yyyy"
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "MM"
        let currYear = dateFormatter.string(from: now)
        let currMonth = dayFormatter.string(from: now)
        //let nextYear = Int(currYear)! + 1
        //let prevYear = Int(currYear)! - 1
        var fromdate = ""
        var todate = ""
        if currMonth == "01" || currMonth == "02" || currMonth == "03"{
            fromdate = "01/01/" + String(currYear)
            todate = "03/31/" + String(currYear)
        }else if currMonth == "04" || currMonth == "05" || currMonth == "06"{
            fromdate = "04/01/" + String(currYear)
            todate = "06/30/" + String(currYear)
        }else if currMonth == "07" || currMonth == "08" || currMonth == "09"{
            fromdate = "07/01/" + String(currYear)
            todate = "09/30/" + String(currYear)
        }else if currMonth == "10" || currMonth == "11" || currMonth == "12"{
            fromdate = "10/01/" + String(currYear)
            todate = "12/31/" + String(currYear)
        }
        return (fromdate, todate)
    }
    
    func yearDate() -> (String, String){
        let now = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy"
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "MM"
        let currYear = dateFormatter.string(from: now)
        let currMonth = dayFormatter.string(from: now)
        let nextYear = Int(currYear)! + 1
        let prevYear = Int(currYear)! - 1
        var fromdate = ""
        var todate = ""
        print("-------------->CurrYear : \(currYear) currMonth : \(currMonth) nextYear : \(nextYear)  prevYear : \(prevYear)")
        if currMonth == "01" || currMonth == "02" || currMonth == "03"{
             fromdate = "04/01/" + String(prevYear)
             todate = "03/31/" + String(currYear)
            print("-------------->Fromdate : \(fromdate) ToDate : \(todate)")
        }else{
             fromdate = "04/01/" + currYear
             todate = "03/31/" + String(nextYear)
            print("-------------->Fromdate : \(fromdate) ToDate : \(todate)")
        }
        
        return (fromdate, todate)
    }
    
    @IBAction func clickedState(_ sender: Any) {
        showState = true
        btnState.backgroundColor = UIColor.init(named: "primaryDark")
        btnBranch.backgroundColor = UIColor.white
        ViewControllerUtils.sharedInstance.showLoader()
        apiGetStatewiseComp()
    }
    
    @IBAction func clickedBranch(_ sender: Any) {
        showState = false
        btnState.backgroundColor = UIColor.white
        btnBranch.backgroundColor = UIColor.init(named: "primaryDark")
        ViewControllerUtils.sharedInstance.showLoader()
        apiGetCompareProgress()
    }
    
    //Pull to Refresh...
    func addRefreshControl(){
        refreshControl.tintColor = UIColor(named: "DashboardHeader")
        refreshControl.backgroundColor = UIColor.white
        refreshControl.addTarget(self, action: #selector(refreshContents), for: .valueChanged)
        if #available(iOS 10.0, *){
            scrollView.refreshControl = refreshControl
        }else{
            scrollView.addSubview(refreshControl)
        }
    }
    
    @objc func refreshContents(){
        counterToday = 0
        counterMonthly = 0
        counterQrtrly = 0
        counterYearly = 0
        apiGetTodaySale()
        apiGetTodayPayment()
    }
    
    //Animate Labels....[Counting Labels]
    @objc func handleUpdate(){
        self.lblSaleTdy.text = "\(counterToday)"
        self.lblPayment.text = "\(counterToday)"
        self.lblSaleMnthly.text = "\(counterMonthly)"
        self.lblPayMnthly.text =  "\(counterMonthly)"
        self.lblSaleQtrly.text = "\(counterQrtrly)"
        self.lblPayQtrly.text = "\(counterQrtrly)"
        self.lblSaleYrly.text = "\(counterYearly)"
        self.lblPayYrly.text = "\(counterYearly)"
        counterToday += 9111111
        counterMonthly += 9999999
        counterQrtrly += 19999111
        counterYearly += 199999991
        if counterToday > totalSale["todaySale"]! {
            self.lblSaleTdy.text = Utility.formatRupee(amount: Double(totalSale["todaySale"]!))
            self.lblPayment.text = Utility.formatRupee(amount: Double(totalPayment["todayPayment"]!))
        }
        if counterMonthly > totalSale["monthlySale"]! {
            self.lblSaleMnthly.text = Utility.formatRupee(amount: Double(totalSale["monthlySale"]!))
            self.lblPayMnthly.text = Utility.formatRupee(amount: Double(totalPayment["monthlyPayment"]!))
        }
        if counterQrtrly > totalSale["qtrlySale"]! {
            self.lblSaleQtrly.text = Utility.formatRupee(amount: Double(totalSale["qtrlySale"]!))
            self.lblPayQtrly.text = Utility.formatRupee(amount: Double(totalPayment["qtrlyPayment"]!))
        }
        if counterYearly > totalSale["yearlySale"]! {
            self.lblSaleYrly.text = Utility.formatRupee(amount: Double(totalSale["yearlySale"]!))
            self.lblPayYrly.text = Utility.formatRupee(amount: Double(totalPayment["yearlyPayment"]!))
        }
    }
    
    //Show Branches Func...
    func updateBranch(value: String, position: Int) {
        if position == 0 {
            filteredItems = self.branchProObj
            self.CollectionView.reloadData()
            self.CollectionView.collectionViewLayout.invalidateLayout()
            return
        }
        filteredItems = self.branchProObj.filter { $0.branchnm == value }
        self.CollectionView.reloadData()
        self.CollectionView.collectionViewLayout.invalidateLayout()
    }
    
    //CollectionView Functions......
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if(showState){
            return filteredState.count + 2
        }else{
            return filteredItems.count + 2
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return noOfColumns
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = CollectionView.dequeueReusableCell(withReuseIdentifier: cellContentIdentifier,
                                                      for: indexPath) as! CollectionViewCell
        cell.layer.borderWidth = 3
        cell.layer.borderColor = UIColor.white.cgColor
        cell.layer.masksToBounds = false
        cell.layer.shadowOffset = CGSize(width: 0, height: 0)
        cell.layer.shadowRadius = 2
        cell.layer.shadowOpacity = 1
        cell.layer.shadowColor = UIColor.black.cgColor
        if(indexPath.section % 2 != 0){
            cell.backgroundColor = UIColor.white
        }else{
            cell.backgroundColor = UIColor.init(named: "Primary")
            cell.layer.borderColor = UIColor.init(named: "Primary")!.cgColor
        }
        if (showState){
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
                    cell.contentLabel.text = "CY Sale 19-20"
                    cell.contentLabel.textColor = UIColor.black
                case 2:
                    cell.contentLabel.text = "LY Sale 18-19"
                case 3:
                    cell.contentLabel.text = "2017-2018"
                case 4:
                    cell.contentLabel.text = "DW"
                default:
                    break
                }
                //cell.backgroundColor = UIColor.lightGray
            }else if indexPath.section == filteredState.count + 1{
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
                    let currentYear = Double(totalStatewiseSale["currSale"]! )
                    let prevYear = Double(totalStatewiseSale["lastSale"]! )
                    let temp = ((currentYear - prevYear)/prevYear)*100
                    cell.contentLabel.attributedText = calculatePercentage(currentYear: currentYear, prevYear: prevYear, temp: temp)
                case 2:
                    let currentYear = Double(totalStatewiseSale["lastSale"]! )
                    let prevYear = Double(totalStatewiseSale["yearBeforeLast"]! )
                    let temp = ((currentYear - prevYear)/prevYear)*100
                    cell.contentLabel.attributedText = calculatePercentage(currentYear: currentYear, prevYear: prevYear, temp: temp)
                case 3:
                    cell.contentLabel.text = Utility.formatRupee(amount: Double(totalStatewiseSale["yearBeforeLast"]! ))
                case 4:
                    cell.contentLabel.text = "DW"
                default:
                    break
                }
            } else {
                cell.contentLabel.font = UIFont(name: "Roboto-Regular", size: 14)
                switch indexPath.row{
                case 0:
                    cell.contentLabel.text = filteredState[indexPath.section - 1].statenm
                case 1:
                    let currentYear = Double(filteredState[indexPath.section - 1].currentyearsale)
                    let prevYear = Double(filteredState[indexPath.section - 1].previousyearsale)
                    let temp = ((currentYear! - prevYear!)/prevYear!)*100
                    if let currentyearsale = Double(filteredState[indexPath.section - 1].currentyearsale)
                    {
                        cell.contentLabel.text = Utility.formatRupee(amount: Double(currentyearsale ))
                        let sale = Utility.formatRupee(amount: Double(currentyearsale ))
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
                        cell.contentLabel.attributedText = attribute
                    }
                case 2:
                    let currentYear = (filteredState[indexPath.section - 1].previousyearsale)
                    let prevYear = (filteredState[indexPath.section - 1].previoutwoyearsale)
                    let temp = ((Double(currentYear)! - Double(prevYear)!)/Double(prevYear)!)*100
                    if let previousyearsale = Double(filteredState[indexPath.section - 1].previousyearsale)
                    {
                        let sale = Utility.formatRupee(amount: Double(previousyearsale ))
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
                        cell.contentLabel.attributedText = attribute
                    }
                case 3:
                    if let previoustwoyearsale = Double(filteredState[indexPath.section - 1].previoutwoyearsale)
                    {
                        cell.contentLabel.text = Utility.formatRupee(amount: Double(previoustwoyearsale ))
                    }
                case 4:
                    let attributedString = NSAttributedString(string: NSLocalizedString("DistrictWise", comment: ""), attributes:[
                        NSAttributedString.Key.foregroundColor : UIColor(named: "ColorBlue"),
                        NSAttributedString.Key.underlineStyle:1.0
                        ])
                    cell.contentLabel.attributedText = attributedString
                default:
                    break
                }
                //cell.backgroundColor = UIColor.groupTableViewBackground
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
                    cell.contentLabel.text = "CY Sale 19-20"
                    cell.contentLabel.textColor = UIColor.black
                case 2:
                    cell.contentLabel.text = "LY Sale 18-19"
                case 3:
                    cell.contentLabel.text = "2017-2018"
                default:
                    break
                }
                //cell.backgroundColor = UIColor.lightGray
            }else if indexPath.section == filteredItems.count + 1{
                cell.contentLabel.font = UIFont(name: "Roboto-Medium", size: 16)
                if #available(iOS 11.0, *) {
                    cell.backgroundColor = UIColor.init(named: "Primary")
                } else {
                    cell.backgroundColor = UIColor.gray
                }
                cell.layer.borderColor = UIColor.init(named: "Primary")!.cgColor
                switch indexPath.row{
                case 0:
                    cell.contentLabel.text = "SUM"
                case 1:
                    let currentYear = Double(totalCurrSale["currSale"]! )
                    let prevYear = Double(totalCurrSale["lastSale"]! )
                    let temp = ((currentYear - prevYear)/prevYear)*100
                    cell.contentLabel.attributedText = calculatePercentage(currentYear: currentYear, prevYear: prevYear, temp: temp)
                case 2:
                    let currentYear = Double(totalCurrSale["lastSale"]! )
                    let prevYear = Double(totalCurrSale["yearBeforeLast"]! )
                    let temp = ((currentYear - prevYear)/prevYear)*100
                    cell.contentLabel.attributedText = calculatePercentage(currentYear: currentYear, prevYear: prevYear, temp: temp)
                case 3:
                    cell.contentLabel.text = Utility.formatRupee(amount: Double(totalCurrSale["yearBeforeLast"]! ))
                default:
                    break
                }
            } else {
                cell.contentLabel.font = UIFont(name: "Roboto-Regular", size: 14)
                switch indexPath.row{
                case 0:
                    cell.contentLabel.text = filteredItems[indexPath.section - 1].branchnm
                case 1:
                    let currentYear = Double(filteredItems[indexPath.section - 1].currentyearsale)
                    let prevYear = Double(filteredItems[indexPath.section - 1].previousyearsale)
                    let temp = ((currentYear! - prevYear!)/prevYear!)*100
                    if let currentyearsale = Double(filteredItems[indexPath.section - 1].currentyearsale)
                    {
                        //cell.contentLabel.text = Utility.formatRupee(amount: Double(currentyearsale ))
                        let sale = Utility.formatRupee(amount: Double(currentyearsale ))
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
                        cell.contentLabel.attributedText = attribute
                    }
                case 2:
                    let currentYear = Double(filteredItems[indexPath.section - 1].previousyearsale)
                    let prevYear = Double(filteredItems[indexPath.section - 1].previoustwoyearsale)
                    let temp = ((currentYear! - prevYear!)/prevYear!)*100
                    if let previousyearsale = Double(filteredItems[indexPath.section - 1].previousyearsale)
                    {
                        let sale = Utility.formatRupee(amount: Double(previousyearsale ))
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
                        cell.contentLabel.attributedText = attribute
                    }
                case 3:
                    if let previoustwoyearsale = Double(filteredItems[indexPath.section - 1].previoustwoyearsale)
                    {
                        cell.contentLabel.text = Utility.formatRupee(amount: Double(previoustwoyearsale ))
                    }
                default:
                    break
                }
                //cell.backgroundColor = UIColor.groupTableViewBackground
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if(indexPath.section == 0){
            let sb = UIStoryboard(name: "BranchPicker", bundle: nil)
            let popup = sb.instantiateInitialViewController()! as! BranchPickerController
            popup.modalPresentationStyle = .overFullScreen
            popup.delegate = self
            popup.showPicker = 1
            self.present(popup, animated: true)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? ComparisonPartywiseController,
            let index = CollectionView.indexPathsForSelectedItems?.first{  
            if index.section > 0{
                destination.showState = showState
                if showState{
                    if(index.row == 4){
                        destination.showState = false
                        destination.showDist = true
                    }
                    destination.dataForStateApi = [filteredState[index.section-1]]
                }else{
                    destination.dataToReceive = [filteredItems[index.section-1]]
                }
            }
            else{
                return
            }
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if let index = CollectionView.indexPathsForSelectedItems?.first{
            if((index.section) > 0){
                if showState{
                    if index.section == self.filteredState.count + 1{
                        return false
                    }else{
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
    
    //API CALLS..............
    func apiGetTodaySale(){
        
        let json: [String: Any] = ["ClientSecret":"ClientSecret"]
        
        let manager =  DataManager.shared
        print("Get Today Sale Params \(json)")
        manager.makeAPICall(url: apiUrlTodaySale, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            
            do {
                self.todaySalesData = try JSONDecoder().decode([TodaySales].self, from: data!)
                self.todaySaleObj = self.todaySalesData[0].data
                print("Get Today Sale Data \(self.todaySalesData[0].data)")
                self.totalSale["todaySale"] = Int(self.todaySaleObj[0].today)!
                self.totalSale["monthlySale"] = Int(self.todaySaleObj[0].monthly)!
                self.totalSale["qtrlySale"] = Int(self.todaySaleObj[0].quarterly)!
                self.totalSale["yearlySale"] = Int(self.todaySaleObj[0].yearly)!
                //CADisplayLink...
                let displayLink = CADisplayLink(target: self, selector: #selector(self.handleUpdate))
                displayLink.add(to: .main, forMode: .defaultRunLoopMode)
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
    
    func apiGetTodayPayment(){
        
        let json: [String: Any] = ["ClientSecret":"ClientSecret"]
        
        let manager =  DataManager.shared
        print("Get Today Payment Params \(json)")
        manager.makeAPICall(url: apiUrlTodayPayment, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            
            do {
                self.todayPayData = try JSONDecoder().decode([TodayPayment].self, from: data!)
                self.todayPaymentObj = self.todayPayData[0].data
                print("Get Today Pay Data \(self.todayPayData[0].data)")
                self.totalPayment["todayPayment"] = Int(self.todayPaymentObj[0].today)!
                self.totalPayment["monthlyPayment"] = Int(self.todayPaymentObj[0].monthly)!
                self.totalPayment["qtrlyPayment"] = Int(self.todayPaymentObj[0].quarterly)!
                self.totalPayment["yearlyPayment"] = Int(self.todayPaymentObj[0].yearly)!
                self.refreshControl.endRefreshing()
            } catch let errorData {
                print(errorData.localizedDescription)
            }
        }) { (Error) in
            print(Error?.localizedDescription as Any)
        }
        
    }
    
    func apiGetCompareProgress(){
        
        let json: [String: Any] = ["CIN":UserDefaults.standard.value(forKey: "userCIN") as! String,"Category":UserDefaults.standard.value(forKey: "userCategory") as! String,"ClientSecret":"ohdashfl"]
        
        let manager =  DataManager.shared
        print("Branchwise Dash Params \(json)")
        manager.makeAPICall(url: apiUrlBranchProgress, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            do {
                print("Branchwise Dash R \(data)")
                self.branchProgress = try JSONDecoder().decode([BranchProgress].self, from: data!)
                self.branchProObj = self.branchProgress[0].data
                self.filteredItems = self.branchProgress[0].data
                self.totalCurrSale["currSale"] = self.filteredItems.reduce(0, { $0 + Double($1.currentyearsale)! })
                self.totalCurrSale["lastSale"] = self.filteredItems.reduce(0, { $0 + Double($1.previousyearsale)! })
                self.totalCurrSale["yearBeforeLast"] = self.filteredItems.reduce(0, { $0 + Double($1.previoustwoyearsale)! })
                ViewControllerUtils.sharedInstance.removeLoader()
            } catch let errorData {
                print(errorData.localizedDescription)
                ViewControllerUtils.sharedInstance.removeLoader()
            }
            self.noOfColumns = 4
            self.customDivLayout.itemAttributes = []
            self.customDivLayout.numberOfColumns = self.noOfColumns
            self.CollectionView.reloadData()
            self.CollectionView.collectionViewLayout.invalidateLayout() 
            self.CollectionView.delegate = self
            self.CollectionView.dataSource = self
            if(self.CollectionView != nil)
            {
                self.CollectionView.reloadData()
                self.customDivLayout.invalidateLayout()
            }
            self.heightConstraint.constant = CGFloat((((self.branchProObj.count+1) * 35) + 10))
        }) { (Error) in
            print(Error?.localizedDescription as Any)
            ViewControllerUtils.sharedInstance.removeLoader()
        }
        
    }
    
    func apiGetStatewiseComp(){ 
        
        let json: [String: Any] = ["CIN":UserDefaults.standard.value(forKey: "userCIN") as! String,"Category":UserDefaults.standard.value(forKey: "userCategory") as! String,"ClientSecret":"ClientSecret"]
        
        let manager =  DataManager.shared
        print("Statewise Dash Params \(json)")
        manager.makeAPICall(url: apiUrlStateProgress, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            do {
                self.statewise = try JSONDecoder().decode([Statewise].self, from: data!)
                print("Branchwise Dash Result \(self.statewise[0].data)")
                self.statewiseObj = self.statewise[0].data
                self.filteredState = self.statewise[0].data
                self.totalStatewiseSale["currSale"] = self.filteredState.reduce(0, { $0 + Double($1.currentyearsale)! })
                self.totalStatewiseSale["lastSale"] = self.filteredState.reduce(0, { $0 + Double($1.previousyearsale)! })
                self.totalStatewiseSale["yearBeforeLast"] = self.filteredState.reduce(0, { $0 + Double($1.previoutwoyearsale)! })
                ViewControllerUtils.sharedInstance.removeLoader()
            } catch let errorData {
                print(errorData.localizedDescription)
                ViewControllerUtils.sharedInstance.removeLoader()
            }
            
            self.noOfColumns = 5
            self.customDivLayout.itemAttributes = [];
            self.customDivLayout.numberOfColumns = self.noOfColumns
            self.CollectionView.reloadData()
            self.CollectionView.collectionViewLayout.invalidateLayout()
            self.CollectionView.delegate = self
            self.CollectionView.dataSource = self
            if(self.CollectionView != nil)
            {
                self.CollectionView.reloadData()
                self.customDivLayout.invalidateLayout()
            }
            self.heightConstraint.constant = CGFloat((((self.statewiseObj.count+1) * 35) + 10))
        }) { (Error) in
            print(Error?.localizedDescription as Any)
            ViewControllerUtils.sharedInstance.removeLoader()
        }
        
    }
    
}



class IntrinsicCollectionViews: UICollectionView {
    var showNoData = false
    override var contentSize:CGSize {
        didSet {
            self.invalidateIntrinsicContentSize()
        }
    }
    
    override var intrinsicContentSize: CGSize {
        self.layoutIfNeeded()
        return CGSize(width: UIViewNoIntrinsicMetric, height: (showNoData) ? 300 : contentSize.height+60)
    }
    
}
