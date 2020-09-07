//
//  ExecutiveTgtTrkController.swift
//  ManagementApp
//
//  Created by Goldmedal on 24/06/20.
//  Copyright © 2020 Goldmedal. All rights reserved.
//

import UIKit
class ExecutiveTgtTrkController: BaseViewController {
    
    //Outlets...
    @IBOutlet weak var vwHorizontalStrip: UIView!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var vwDateDropDown: UIView!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noDataView: NoDataView!
    @IBOutlet weak var lblExName: UILabel!
    
    //Declarations...
    var viewPager:ViewPagerController!
    var options:ViewPagerOptions!
    var ExId = 1
    var salesExecutiveApi = ""
    var getExecutiveApi = ""
    var strFromDate = ""
    var strToDate = ""
    var finYear = ""
    var quarterFinYear = ""
    var currDate = Date()
    var currQuarter = ""
    var tabs = [
        ViewPagerTab(title: "QUARTER", image: nil),
        ViewPagerTab(title: "YEAR", image: nil),
    ]
    var initTabPosition = 1
    var salesExecutive = [SalexExecutive]()
    var salesExecutiveObj = [SalexExecutiveObj]()
    var salesExecutiveData = [SalesExData]() 
    var commonSearch = [CommonSearch]()
    var commonSearchObj = [CommonSearchObj]()
    var statename = [[String : String]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lblExName.text = "Sanket Raghunath Parab  ▼"
        self.noDataView.hideView(view: self.noDataView)
        addSlideMenuButton()
        finYear = Utility.currFinancialYear()
        quarterFinYear = Utility.currFinancialYear()
        currQuarter = Utility.currQuarter()
        currDate = Date()
        formatYear()
        //formatQuarter()
        let tapDateDropDown = UITapGestureRecognizer(target: self, action: #selector(self.tapDateDropDown))
        vwDateDropDown.addGestureRecognizer(tapDateDropDown)
        let tapExecutiveName = UITapGestureRecognizer(target: self, action: #selector(self.clickedExNames))
        lblExName.addGestureRecognizer(tapExecutiveName)
        self.edgesForExtendedLayout = UIRectEdge.init(rawValue: 0)
        
        options = ViewPagerOptions(viewPagerWithFrame: self.view.bounds)
        options.tabType = ViewPagerTabType.basic
        //  options.tabViewImageSize = CGSize(width: 20, height: 20)
        options.tabViewTextFont = UIFont.systemFont(ofSize: 13)
        options.isEachTabEvenlyDistributed = true
        options.tabViewBackgroundDefaultColor = UIColor.white
        if #available(iOS 11.0, *) {
            options.tabIndicatorViewBackgroundColor = UIColor.init(named: "ColorRed")!
        } else {
            options.tabIndicatorViewBackgroundColor = UIColor.red
        }
        options.fitAllTabsInView = true
        options.tabViewPaddingLeft = 20
        options.tabViewPaddingRight = 20
        options.isTabHighlightAvailable = false
        
        viewPager = ViewPagerController()
        viewPager.options = options
        viewPager.dataSource = self
        viewPager.delegate = self
        
        self.addChildViewController(viewPager)
        self.vwHorizontalStrip.addSubview(viewPager.view)
        viewPager.didMove(toParentViewController: self)
        
        
        // I don't want user interaction
        self.tableView.allowsSelection = false
        // The below line is to eliminate the empty cells
        self.tableView.tableFooterView = UIView()
        
        
        let nib = UINib(nibName: "DivisionStatsSectionHeader", bundle: nil)
        self.tableView.register(nib, forHeaderFooterViewReuseIdentifier: "DivisionStatsSectionHeader")
        salesExecutiveApi = "https://test2.goldmedalindia.in/api/getSalesExecutivetarget"
        getExecutiveApi = "https://test2.goldmedalindia.in/api/GetManagementExecList"
        if (Utility.isConnectedToNetwork()) {
            ViewControllerUtils.sharedInstance.showLoader()
            apiSalesExecutive()
            apiGetExecutives()
        }else{
            self.noDataView.showView(view: self.noDataView, from: "NET")
            //self.tableView.showNoData = true
        }
        
    }
    
    @objc func clickedExNames(sender:UITapGestureRecognizer) {
        let sb = UIStoryboard(name: "Search", bundle: nil)
        let popup = sb.instantiateInitialViewController()! as! SearchViewController
        popup.modalPresentationStyle = .overFullScreen
        popup.delegate = self
        popup.commonSearchObj = commonSearchObj
        popup.tempCommonObj = commonSearchObj
        popup.placeholder = "Search Executive Names..."
        popup.from = "common"
        self.present(popup, animated: true)
    }
    
    func showParty(value: String, cin: String) {
        lblExName.text = "\(value)  ▼"
        ExId = Int(cin)!
        ViewControllerUtils.sharedInstance.showLoader()
        apiSalesExecutive()
    }
        
    @objc func tapDateDropDown(sender:UITapGestureRecognizer) {
        print("clicked")
        
        //        if(initTabPosition == 0){
        //
        //            let sb = UIStoryboard(name: "MonthYearPicker", bundle: nil)
        //                       let popup = sb.instantiateInitialViewController()! as! MonthYearPickerController
        //                       popup.delegate = self
        //                       self.present(popup, animated: true)
        //
        //        }else
        
        if(initTabPosition == 0){
            let sb = UIStoryboard(name: "QuarterYearPicker", bundle: nil)
            let popup = sb.instantiateInitialViewController()! as! QuarterYearPickerController
            popup.delegate = self
            self.present(popup, animated: true)
        }else{
            let sb = UIStoryboard(name: "CustomYearPicker", bundle: nil)
            let popup = sb.instantiateInitialViewController()! as! CustomYearPickerController
            popup.delegate = self
            popup.showPicker = 3
            self.present(popup, animated: true)
        }
    }
    
    func updateDateFromPicker(value: String, date: Date, from: String) {
         
        if(from.elementsEqual("MONTH")){
            currDate = date
            //formatMonth()
        }else{
            //Get First 14 letters of quarter
            currQuarter  = String(value.prefix(14))
            //Get Last 9 letters of quarter
            quarterFinYear = String(value.suffix(9))
            print("val---",currQuarter+"---"+quarterFinYear)
            formatQuarter()
        }
        
        apiSalesExecutive()
    }
    
    
    
    
    func updatePositionValue(value: String, position: Int, from: String) {
        
        if(initTabPosition == 0){}
        else if(initTabPosition == 1){
            finYear = value
            formatYear()
            apiSalesExecutive()
        }
         
    }
    
    // API CALL - - - - - - - - - -
    func apiSalesExecutive(){
        
        self.noDataView.showView(view: self.noDataView, from: "LOADER")
        //self.tableView.showNoData = true
        
        let json: [String: Any] = ["ExId":ExId,"CIN":UserDefaults.standard.value(forKey: "userCIN") as! String,"Category":UserDefaults.standard.value(forKey: "userCategory") as! String,"ClientSecret":"ohdashfl","Hierarchy":"0"
            ,"FromDate":strFromDate,"ToDate":strToDate]
        
        DataManager.shared.makeAPICall(url: salesExecutiveApi, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            print("salesExecutiveApi - - - ",self.salesExecutiveApi,"------",json)
            DispatchQueue.main.async {
                do {
                    self.salesExecutive = try JSONDecoder().decode([SalexExecutive].self, from: data!)
                    self.salesExecutiveObj  = self.salesExecutive[0].data
                    self.salesExecutiveData  = self.salesExecutiveObj[0].saleexesaleandtargetDetails
                    print("salesExecutiveResp - - - ",self.salesExecutiveData)
                    if(self.salesExecutiveData.count > 0){
                        self.noDataView.hideView(view: self.noDataView)
                        self.tableView.reloadData()
                    }else{
                        self.noDataView.showView(view: self.noDataView, from: "NDA")
                        //self.tableView.showNoData = true
                    }
                    ViewControllerUtils.sharedInstance.removeLoader()
                    
                } catch let errorData {
                    self.noDataView.showView(view: self.noDataView, from: "NDA")
                    print("Caught Error ------>\(errorData.localizedDescription)")
                    ViewControllerUtils.sharedInstance.removeLoader()
                }
            }
            
        }) { (Error) in
            print(Error?.localizedDescription ?? "ERROR")
            self.noDataView.showView(view: self.noDataView, from: "NDA")
            ViewControllerUtils.sharedInstance.removeLoader()
            //self.tableView.showNoData = true
            
        }
        
    }
    
    func apiGetExecutives(){
        let json: [String: Any] = ["CIN":UserDefaults.standard.value(forKey: "userCIN") as! String,"Category":UserDefaults.standard.value(forKey: "userCategory") as! String,"ClientSecret":"ohdashfl"]
        
        DataManager.shared.makeAPICall(url: getExecutiveApi, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            print("getExecutiveApi - - - ",self.getExecutiveApi,"------",json)
            DispatchQueue.main.async {
                do {
                    self.commonSearch = try JSONDecoder().decode([CommonSearch].self, from: data!)
                    self.commonSearchObj  = self.commonSearch[0].data
                    print("COMMON SEARCH ----> \(self.commonSearchObj)")
                } catch let errorData {
                    print("Caught Error ------>\(errorData.localizedDescription)")
                    self.noDataView.showView(view: self.noDataView, from: "NDA")
                    ViewControllerUtils.sharedInstance.removeLoader()
                }
            }
            
        }) { (Error) in
            print(Error?.localizedDescription ?? "ERROR")
            self.noDataView.showView(view: self.noDataView, from: "NDA")
            ViewControllerUtils.sharedInstance.removeLoader()
            //self.tableView.showNoData = true
            
        }
        
    }
    
    
    //Calculate percentage func...
    func calculatePercentage(currentYear: Double, prevYear: Double, temp: Double) -> NSAttributedString{
        var diff = currentYear - prevYear
        if diff < 0 {
            diff = diff * -1
        }
        let sale = Utility.formatRupee(amount: Double(diff ))
        let tempVar = String(format: "%.2f", temp)
        var formattedPerc = ""
        if (Double(tempVar)!.isInfinite) || (Double(tempVar)!.isNaN){
            formattedPerc = ""
        } else{
            formattedPerc = " (\(String(format: "%.2f", temp)))%"
        }
        let strNumber: NSString = sale + formattedPerc as NSString // you must set your
        let range = (strNumber).range(of: String(tempVar))
        let attribute = NSMutableAttributedString.init(string: strNumber as String)
        if temp > 0{
            if currentYear > prevYear {
               attribute.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor(named: "ColorGreen") as Any , range: range)
            }else{
             attribute.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.red as Any , range: range)
            } 
        }else{
            attribute.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.red as Any , range: range)
        }
        return attribute
    }
    
    func formatQuarter(){
        
        let splitFinYear = quarterFinYear.split(separator: "-")
        
        switch (currQuarter) {
        case "Q1 (APR - JUN)":
            strFromDate = "04/01/" + splitFinYear[0]
            strToDate = "06/30/" + splitFinYear[0]
            break
        case "Q2 (JUL - SEP)":
            strFromDate = "07/01/" + splitFinYear[0]
            strToDate = "09/30/" + splitFinYear[0]
            break
        case "Q3 (OCT - DEC)":
            strFromDate = "10/01/" + splitFinYear[0]
            strToDate = "12/31/" + splitFinYear[0]
            break
        case "Q4 (JAN - MAR)":
            strFromDate = "01/01/" + splitFinYear[1]
            strToDate = "03/31/" + splitFinYear[1]
            break
        default:
            break
        }
        
        lblDate.text = currQuarter + " " + quarterFinYear
    }
    
    func formatYear(){
        
        let splitFinYear = finYear.split(separator: "-")
        
        strFromDate = "04/01/" + splitFinYear[0]
        strToDate =  "03/31/" + splitFinYear[1]
        
        lblDate.text = finYear
    }
    
}

extension ExecutiveTgtTrkController: ViewPagerControllerDataSource {
    
    func numberOfPages() -> Int {
        return tabs.count
    }
    
    func viewControllerAtPosition(position:Int) -> UIViewController {
        let vc = UIViewController()
        
        initTabPosition = position
        
        return vc
    }
    
    func tabsForPages() -> [ViewPagerTab] {
        return tabs
    }
    
    func startViewPagerAtIndex() -> Int {
        return 1
    }
}

extension ExecutiveTgtTrkController: ViewPagerControllerDelegate {
    
    func willMoveToControllerAtIndex(index:Int) {
        print("Moving to page \(index)")
    }
    
    func didMoveToControllerAtIndex(index: Int) {
        
        initTabPosition = index
        print("Moved to page \(index)")
        
        if(index == 0){
            formatQuarter()
        }else{
            formatYear()
        }
        apiSalesExecutive()
        
    }
}

extension ExecutiveTgtTrkController : UITableViewDataSource{
    
    
    // We have only one section
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return salesExecutiveData.count + 1
    }
    
    // Cell creation
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SalesExecutiveCell", for: indexPath) as! SalesExecutiveCell
        if salesExecutiveData.count > 0 {
            if indexPath.row == salesExecutiveData.count{
                    cell.lblDivisionName.text =  "TOTAL"
                     
                    if let Target = salesExecutiveObj[0].totalTarget {
                        cell.lblTarget.text = Utility.formatRupee(amount: Double(Target)!)
                        //targetTotal = Double(Target)!
                    }
                    
                    if let Sales = salesExecutiveObj[0].totalSale {
                        cell.lblSales.text = Utility.formatRupee(amount: Double(Sales)!)
                        //salesTotal = Double(Sales)!
                    }
                    
                    if let Deal = salesExecutiveObj[0].totaldealerTarget {
                        cell.lblDealer.text = Utility.formatRupee(amount: Double(Deal)!)
                        //salesTotal = Double(Sales)!
                    }
                    
                    let currentYear = Double(salesExecutiveObj[0].totalSale!)!
                    let prevYear = Double(salesExecutiveObj[0].totalTarget!)!
                    //let temp = ((currentYear - prevYear)/prevYear)*100
                    let temp = (currentYear*100)/prevYear
                    cell.lblOverallChgPercent.attributedText = calculatePercentage(currentYear: currentYear, prevYear: prevYear, temp: temp)
                    
                    let currentYear1 = Double(salesExecutiveObj[0].totaldealerTarget!)!
                    let prevYear1 = Double(salesExecutiveObj[0].totalTarget!)!
                    //let temp = ((currentYear - prevYear)/prevYear)*100
                    let temp1 = (currentYear1*100)/prevYear1
                    cell.lblDealPercent.attributedText = calculatePercentage(currentYear: currentYear1, prevYear: prevYear1, temp: temp1)
                    
                    return cell
                }
                
                cell.lblDivisionName.text = salesExecutiveData[indexPath.row].division?.capitalized ?? "-"
                 
                if let Target = salesExecutiveData[indexPath.row].target {
                    cell.lblTarget.text = Utility.formatRupee(amount: Double(Target)!)
                    //targetTotal = Double(Target)!
                }
                
                if let Sales = salesExecutiveData[indexPath.row].sales {
                    cell.lblSales.text = Utility.formatRupee(amount: Double(Sales)!)
                    //salesTotal = Double(Sales)!
                }
                
                if let Deal = salesExecutiveData[indexPath.row].dealertarget {
                    cell.lblDealer.text = Utility.formatRupee(amount: Double(Deal)!)
                    //salesTotal = Double(Sales)!
                }
                
                let currentYear = Double(salesExecutiveData[indexPath.row].sales!)!
                let prevYear = Double(salesExecutiveData[indexPath.row].target!)!
                //let temp = ((currentYear - prevYear)/prevYear)*100
                let temp = (currentYear*100)/prevYear
                cell.lblOverallChgPercent.attributedText = calculatePercentage(currentYear: currentYear, prevYear: prevYear, temp: temp)
                
                let currentYear1 = Double(salesExecutiveData[indexPath.row].dealertarget!)!
                let prevYear1 = Double(salesExecutiveData[indexPath.row].target!)!
                //let temp = ((currentYear - prevYear)/prevYear)*100
                let temp1 = (currentYear1*100)/prevYear1
                cell.lblDealPercent.attributedText = calculatePercentage(currentYear: currentYear1, prevYear: prevYear1, temp: temp1)
                  
                return cell
            }
            return cell
        }
        
    
    
    
}

extension ExecutiveTgtTrkController : UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 105
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let strDivision = "Division"
//        let strTarget = "Target"
//        let strSales = "Sales"
//        let strOverallChg = "Overall Chg"
//        let strOverallChgPercent = "Overall Chg %"
        
        // Dequeue with the reuse identifier
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "DivisionStatsSectionHeader") as! DivisionStatsSectionHeader
        //            self.tableView.dequeueReusableHeaderFooterView(withIdentifier: "DivisionStatsSectionHeader") as! DivisionStatsSectionHeader
//        header.lblDivisionName.text = strDivision
//
//        header.lblTarget.text = strTarget
//        header.lblSales.text = strSales
//        header.lblOverallChg.text = strOverallChg
//        header.lblOverallChgPercent.text = strOverallChgPercent
        
        return header
    }
    
    // Give a height to our table view cell
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 105
    }
}

extension Date {
    
    public func formatDate(format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
        
    }
    
    public func getDateInFormat(format: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return self
        
    }
    
    
    public var endDateOfMonth: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd"
        
        var components = Calendar.current.dateComponents([.year, .month], from: self)
        components.month = (components.month ?? 0) + 1
        components.hour = (components.hour ?? 0) - 1
        
        let endOfMonth = Calendar.current.date(from: components)!
        return dateFormatter.string(from: endOfMonth)
        
    }
    
    
}
