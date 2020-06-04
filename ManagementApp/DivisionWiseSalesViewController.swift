//
//  DivisionWiseSalesViewController.swift
//  G-Management
//  Created by Goldmedal on 15/02/19.
//  Copyright © 2019 Goldmedal. All rights reserved.
//

import UIKit

class DivisionWiseSalesViewController: BaseViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    //Outlet...
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btnFinancialYear: RoundButton!
    @IBOutlet weak var btnPayment: RoundButton!
    @IBOutlet weak var btnSales: RoundButton!
    @IBOutlet weak var branchwiseCollectionView: UICollectionView!
    @IBOutlet weak var lblYearly: RoundButton!
    @IBOutlet weak var lblMonthly: RoundButton!
    @IBOutlet weak var lblQuarterly: RoundButton!
    @IBOutlet weak var noDataView: NoDataView!
    @IBOutlet weak var lblFinYear: UILabel!
    
    let reuseIdentifier = "CollectionViewCell";
    var branchWiseSalesApiUrl = "https://api.goldmedalindia.in/api/GetTotalSaleBranchWise"
    var branchWisePaymentApiUrl = "https://api.goldmedalindia.in/api/GetTotalPaymentBranchWise"
    var branchWiseSalesData = [BranchWiseSales]()
    var branchData = [BranchSale]()
    var filteredItems = [BranchSale]()
    var branchWisePaymentData = [BranchWisePayment]()
    var branchPayData = [BranchPay]()
    var filteredPayment = [BranchPay]()
    var totalSales = ["wiringdevices":0.0,"lights":0.0,"wireandcable":0.0,"pipesandfittings":0.0,"mcbanddbs":0.0,"branchcontribution":0.0,"branchcontributionpercentage":0.0]
    var totalPayment = ["payment":0.0,"contri":0.0]
    var cellContentIdentifier = "\(CollectionViewCell.self)"
    var showSales = true
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var cellContentIdentifierTable = "\(DivisionwiseTabelCell.self)"
    
    //Picker Related...
    var finYear = ""
    var opType = 3
    var opValue = 0
    var currPosition = 0
    var callFrom = 0
    var strCin = ""
    var strTotalAmnt = "-"
    var dateTo = "03/30/2021"
    var dateFrom = "04/01/2020"
    var yearStart = "2020"
    var yearEnd = "2021"
    let qrtrlyArrayStart = Utility.quarterlyStartDate()
    let qrtrlyArrayEnd = Utility.quarterlyEndDate()
    let monthEnds = Utility.getMonthEndDate()
    let months = Utility.getMonths()
    var customDivLayout = BranchWiseCollectionLayout()
    var noOfColumns = Int()
    var isagent = false
    
    override func viewDidLoad() {
        addSlideMenuButton()
        super.viewDidLoad()
        if UserDefaults.standard.value(forKey: "userCategory") as! String == "Agent"{
            isagent = true
            noOfColumns = 2
            //tableView.isHidden = true
        }else{
            noOfColumns = 8
            //tableView.isHidden = true
        }
        self.noDataView.hideView(view: self.noDataView)
        ViewControllerUtils.sharedInstance.showLoader()
        apiBranchWiseSales()
    }
    
    //Tableview Functions...
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 340
//    }
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return branchData.count
//    }
//
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "DivisionwiseTabelCell", for: indexPath) as! DivisionwiseTabelCell
//
//        let currentYear = Double(self.branchData[indexPath.row].wiringdevices!)!
//        let prevYear = Double(self.branchData[indexPath.row].branchcontribution!)
//        let temp = (currentYear*100)/prevYear!
//        cell.lblWDName.attributedText = calculatePercentage(currentYear: currentYear, prevYear: prevYear!, temp: temp)
//
//        let wd = Double(self.branchData[indexPath.row].lights!)!
//        let wdSum = Double(self.branchData[indexPath.row].branchcontribution!)
//        let wdTemp = (wd*100)/wdSum!
//        cell.lblLname.attributedText = calculatePercentage(currentYear: wd, prevYear: wdSum!, temp: wdTemp)
//
//        let wc = Double(self.branchData[indexPath.row].wireandcable!)!
//        let wcSum = Double(self.branchData[indexPath.row].branchcontribution!)
//        let wcTemp = (wc*100)/wcSum!
//        cell.lblWCName.attributedText = calculatePercentage(currentYear: wc, prevYear: wcSum!, temp: wcTemp)
//
//        let pf = Double(self.branchData[indexPath.row].pipesandfittings!)!
//        let pfSum = Double(self.branchData[indexPath.row].branchcontribution!)
//        let pfTemp = (pf*100)/pfSum!
//        cell.lblPFName.attributedText = calculatePercentage(currentYear: pf, prevYear: pfSum!, temp: pfTemp)
//
//        let md = Double(self.branchData[indexPath.row].mcbanddbs!)!
//        let mdSum = Double(self.branchData[indexPath.row].branchcontribution!)
//        let mdTemp = (md*100)/mdSum!
//        cell.lblMDName.attributedText = calculatePercentage(currentYear: md, prevYear: mdSum!, temp: mdTemp)
//        if let brC = self.branchData[indexPath.row].branchcontribution {
//            cell.lblBRCName.text = Utility.formatRupee(amount: Double(brC)!)
//        }
//        cell.selectionStyle = UITableViewCell.SelectionStyle.none
//        return cell
//    }
//
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        performSegue(withIdentifier: "byAgent", sender: self)
//    }
    
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
    
    //Sort Related...
    @IBAction func clicked_sort(_ sender: Any) {
        let sb = UIStoryboard(name: "Sorting", bundle: nil)
        let popup = sb.instantiateInitialViewController()! as! SortViewController
        popup.modalPresentationStyle = .overFullScreen
        popup.delegate = self
        popup.showPicker = 1
        popup.pickerDataSource = showSales ?  ["A-Z","Z-A","low to high Branch Contribution","high to low Branch Contribution"] : ["A-Z","Z-A","low to high Payment","high to low Payment"]
        self.present(popup, animated: true)
    }
    
    func sortBy(value: String, position: Int) {
        if showSales{
            switch position {
            case 0:
                self.filteredItems = self.branchData.sorted{($0.branchnm)!.localizedCaseInsensitiveCompare($1.branchnm!) == .orderedAscending}
            case 1:
                self.filteredItems = self.branchData.sorted{($0.branchnm)!.localizedCaseInsensitiveCompare($1.branchnm!) == .orderedDescending}
            case 2:
                self.filteredItems = self.branchData.sorted(by: {Double($0.branchcontribution!)! < Double($1.branchcontribution!)!})
            case 3:
                self.filteredItems = self.branchData.sorted(by: {Double($0.branchcontribution!)! > Double($1.branchcontribution!)!})
            default:
                break
            }
        }else{
            switch position {
            case 0:
                self.filteredPayment = self.branchPayData.sorted{($0.branchnm)!.localizedCaseInsensitiveCompare($1.branchnm!) == .orderedAscending}
            case 1:
                self.filteredPayment = self.branchPayData.sorted{($0.branchnm)!.localizedCaseInsensitiveCompare($1.branchnm!) == .orderedDescending}
            case 2:
                self.filteredPayment = self.branchPayData.sorted(by: {Double($0.payment!)! < Double($1.payment!)!})
            case 3:
                self.filteredPayment = self.branchPayData.sorted(by: {Double($0.payment!)! > Double($1.payment!)!})
            default:
                break
            }
        }
        self.branchwiseCollectionView.reloadData()
        self.branchwiseCollectionView.collectionViewLayout.invalidateLayout()
    }
    
    func apiBranchWiseSales(){
        
        let json: [String: Any] = ["CIN":UserDefaults.standard.value(forKey: "userCIN") as! String,"Category":UserDefaults.standard.value(forKey: "userCategory") as! String,"FromDate":dateFrom,"ToDate":dateTo,"ClientSecret":"ClientSecret"]
        
        let manager =  DataManager.shared
        print("DIVWiseSale Params \(json)")
        manager.makeAPICall(url: branchWiseSalesApiUrl, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            //print("DIVWiseSale Result \(data)")
            do {
                self.branchWiseSalesData = try JSONDecoder().decode([BranchWiseSales].self, from: data!)
                self.branchData  = self.branchWiseSalesData[0].data!
                self.filteredItems = self.branchWiseSalesData[0].data!
                self.totalSales["wiringdevices"] = self.branchData.reduce(0, { $0 + Double($1.wiringdevices!)! })
                self.totalSales["lights"] = self.branchData.reduce(0, { $0 + Double($1.lights!)! })
                self.totalSales["wireandcable"] = self.branchData.reduce(0, { $0 + Double($1.wireandcable!)! })
                self.totalSales["pipesandfittings"] = self.branchData.reduce(0, { $0 + Double($1.pipesandfittings!)! })
                self.totalSales["mcbanddbs"] = self.branchData.reduce(0, { $0 + Double($1.mcbanddbs!)! })
                self.totalSales["branchcontribution"] = self.branchData.reduce(0, { $0 + Double($1.branchcontribution!)! })
                self.totalSales["branchcontributionpercentage"] = self.branchData.reduce(0, { $0 + Double($1.branchcontributionpercentage!)! })
                ViewControllerUtils.sharedInstance.removeLoader()
                self.noDataView.hideView(view: self.noDataView)
            } catch let errorData {
                print(errorData.localizedDescription)
                self.noDataView.showView(view: self.noDataView, from: "NDA")
                ViewControllerUtils.sharedInstance.removeLoader()
                return
            }
            if self.isagent{
                self.noOfColumns = 2
            }else{
                self.noOfColumns = 8
            }
            
            
            self.customDivLayout.itemAttributes = [];
            self.customDivLayout.numberOfColumns = self.noOfColumns
            self.branchwiseCollectionView.collectionViewLayout = self.customDivLayout
            self.branchwiseCollectionView.delegate = self
            self.branchwiseCollectionView.dataSource = self
            
            if(self.branchwiseCollectionView != nil)
            {
                self.branchwiseCollectionView.reloadData()
                self.customDivLayout.invalidateLayout()
            }
            if(self.filteredItems.count>0){
                if(self.branchwiseCollectionView != nil)
                {
                    self.branchwiseCollectionView.reloadData()
                    self.customDivLayout.invalidateLayout()
                }
                self.noDataView.hideView(view: self.noDataView)
            }else{
                self.noDataView.showView(view: self.noDataView, from: "NDA")
            }
        }) { (Error) in
            print(Error?.localizedDescription as Any)
            ViewControllerUtils.sharedInstance.removeLoader()
            self.noDataView.showView(view: self.noDataView, from: "NDA")
            ViewControllerUtils.sharedInstance.removeLoader()
        }
        
    }
    
    func apiBranchWisePayment(){
        
        let json: [String: Any] = ["CIN":UserDefaults.standard.value(forKey: "userCIN") as! String,"Category":UserDefaults.standard.value(forKey: "userCategory") as! String,"FromDate":dateFrom,"ToDate":dateTo,"ClientSecret":"ClientSecret"]
        let manager =  DataManager.shared
        print("DIVWisePayment Params \(json)")
        manager.makeAPICall(url: branchWisePaymentApiUrl, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            do {
                //print("DIVWisePayment Response \(data)")
                self.branchWisePaymentData = try JSONDecoder().decode([BranchWisePayment].self, from: data!)
                self.branchPayData  = self.branchWisePaymentData[0].data!
                self.filteredPayment = self.branchWisePaymentData[0].data!
                self.totalPayment["payment"] = self.branchPayData.reduce(0, { $0 + Double($1.payment!)! })
                self.totalPayment["contri"] = self.branchPayData.reduce(0, { $0 + Double($1.contribution!)! })
                ViewControllerUtils.sharedInstance.removeLoader()
            } catch let errorData {
                print(errorData.localizedDescription)
                self.noDataView.showView(view: self.noDataView, from: "NDA")
                ViewControllerUtils.sharedInstance.removeLoader()
                return
            }
            if self.isagent{
                self.noOfColumns = 2
            }else{
                self.noOfColumns = 3
            }
            self.customDivLayout.itemAttributes = [];
            self.customDivLayout.numberOfColumns = self.noOfColumns
            self.branchwiseCollectionView.collectionViewLayout = self.customDivLayout
            self.branchwiseCollectionView.delegate = self
            self.branchwiseCollectionView.dataSource = self
            
            if(self.branchwiseCollectionView != nil)
            {
                self.branchwiseCollectionView.reloadData()
                self.customDivLayout.invalidateLayout()
            }
            self.branchwiseCollectionView?.scrollToItem(at: IndexPath(row: 0, section: 0),
                                                        at: .top,
                                                        animated: true)
        }) { (Error) in
            print(Error?.localizedDescription as Any)
            self.noDataView.showView(view: self.noDataView, from: "NDA")
            ViewControllerUtils.sharedInstance.removeLoader()
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    @IBAction func yearlyClicked(_ sender: Any) {
        lblFinYear.text = "Financial Year"
        ViewControllerUtils.sharedInstance.showLoader()
        callFrom = 3
        dateFrom = months[3]+"01/"+yearStart
        dateTo = months[2]+monthEnds[3]+yearEnd
        apiBranchWiseSales()
        highlightedButton(callfrom: 3)
    }
    
    @IBAction func monthlyClicked(_ sender: Any) {
        let sb = UIStoryboard(name: "CustomYearPicker", bundle: nil)
        let popup = sb.instantiateInitialViewController()! as! CustomYearPickerController
        popup.modalPresentationStyle = .overFullScreen
        popup.delegate = self
        popup.showPicker = 1
        self.present(popup, animated: true)
        callFrom = 1
        opType = 1
    }
    
    @IBAction func quarterlyClicked(_ sender: Any) {
        let sb = UIStoryboard(name: "CustomYearPicker", bundle: nil)
        let popup = sb.instantiateInitialViewController()! as! CustomYearPickerController
        popup.modalPresentationStyle = .overFullScreen
        popup.delegate = self
        popup.showPicker = 2
        self.present(popup, animated: true)
        callFrom = 2
        opType = 2
    }
    
    @IBAction func yearClicked(_ sender: Any) {
        //Copied yearlyClicked Code for UI temporary
        lblFinYear.text = "Financial Year"
        let sb = UIStoryboard(name: "CustomYearPicker", bundle: nil)
        let popup = sb.instantiateInitialViewController()! as! CustomYearPickerController
        popup.modalPresentationStyle = .overFullScreen
        popup.delegate = self
        popup.showPicker = 3
        self.present(popup, animated: true)
        callFrom = 0
        opType = 3
        opValue = 0
    }
    
    @IBAction func clickedSales(_ sender: Any) {
        if isagent{
            //tableView.isHidden = true
            branchwiseCollectionView.isHidden = false
        }
        showSales = true
        btnSales.backgroundColor = UIColor.darkGray
        btnSales.setTitleColor(UIColor.white, for: .normal)
        btnPayment.backgroundColor = UIColor.white
        btnPayment.setTitleColor(UIColor.black, for: .normal)
        ViewControllerUtils.sharedInstance.showLoader()
        self.customDivLayout.itemAttributes = [];
        apiBranchWiseSales()
    }
    
    @IBAction func clickedPayment(_ sender: Any) {
        if isagent{
            //tableView.isHidden = true
            branchwiseCollectionView.isHidden = false
        }
        showSales = false
        btnSales.backgroundColor = UIColor.white
        btnSales.setTitleColor(UIColor.black, for: .normal)
        btnPayment.backgroundColor = UIColor.darkGray
        btnPayment.setTitleColor(UIColor.white, for: .normal)
        ViewControllerUtils.sharedInstance.showLoader()
        self.customDivLayout.itemAttributes = [];
        apiBranchWisePayment()
    }
    
    func highlightedButton(callfrom: Int){
        self.lblYearly.backgroundColor = (callfrom == 3) ? UIColor(hexString: "#b30000") : UIColor(named: "ColorRed")
        self.lblYearly.shadowOpacity = (callfrom == 3) ? 0 : 1
        self.lblMonthly.backgroundColor = (callfrom == 1) ? UIColor(hexString: "#b30000") : UIColor(named: "ColorRed")
        self.lblMonthly.shadowOpacity = (callfrom == 1) ? 0 : 1
        self.lblQuarterly.backgroundColor = (callfrom == 2) ? UIColor(hexString: "#b30000") : UIColor(named: "ColorRed")
        self.lblQuarterly.shadowOpacity = (callfrom == 2) ? 0 : 1
    }
    
    func updatePositionValue(value: String, position: Int, from: String) {
        ViewControllerUtils.sharedInstance.showLoader()
        switch callFrom {
        case 0:
            lblFinYear.text = "Financial Year"
            highlightedButton(callfrom: 3)
            btnFinancialYear.setTitle(value, for: .normal)
            var tempArray = value.components(separatedBy: "-")
            yearStart = tempArray[0]
            yearEnd = tempArray[1]
            dateFrom = months[3]+"01/"+yearStart
            dateTo = months[2]+monthEnds[3]+yearEnd
            if showSales{
                apiBranchWiseSales()
            }else{
                apiBranchWisePayment()
            }
        case 1:
            lblFinYear.text = "Monthly Report - " + value
            highlightedButton(callfrom: 1)
            dateFrom = months[position]+"01/"+yearStart
            dateTo = months[position]+monthEnds[position]+yearStart
            if showSales{
                apiBranchWiseSales()
            }
            else{
                apiBranchWisePayment()
            }
        case 2:
            lblFinYear.text = "Quarterly Report - " + value
            highlightedButton(callfrom: 2)
            if(position==3){
                dateFrom = qrtrlyArrayStart[position] + yearEnd
                dateTo = qrtrlyArrayEnd[position] + yearEnd
            }else{
                dateFrom = qrtrlyArrayStart[position] + yearStart
                dateTo = qrtrlyArrayEnd[position] + yearStart
            }
            if showSales{
                apiBranchWiseSales()
            }
            else{
                apiBranchWisePayment()
            }
        default:
            print("Error")
        }
        
        
    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if(showSales){
            if isagent{
                return 6
            }else{
                return filteredItems.count + 2
            }
            
        }else{
            return filteredPayment.count + 2
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return noOfColumns
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = branchwiseCollectionView.dequeueReusableCell(withReuseIdentifier: cellContentIdentifier,
                                                                for: indexPath) as! CollectionViewCell
        cell.layer.borderWidth = 1
        cell.layer.borderColor = UIColor.white.cgColor
        if showSales{
            if isagent && filteredItems.count > 0{
                if #available(iOS 11.0, *) {
                    cell.backgroundColor = UIColor.init(named: "primaryLight")
                } else {
                    cell.backgroundColor = UIColor.gray
                }
                if indexPath.row == 0{
                    cell.contentLabel.font = UIFont(name: "Roboto-Medium", size: 16)
                    switch indexPath.section{
                    case 0:
                        cell.contentLabel.text = "W D"
                    case 1:
                        cell.contentLabel.text = "Lights"
                    case 2:
                        cell.contentLabel.text = "W&C"
                    case 3:
                        cell.contentLabel.text = "P&F"
                    case 4:
                        cell.contentLabel.text = "Mcb&Dbs"
                    case 5:
                        cell.contentLabel.text = "Branch Contri"
                    default:
                        break
                    }
                }else{
                    cell.contentLabel.font = UIFont(name: "Roboto-Medium", size: 16)
                    switch indexPath.section{
                   case 0:
                        if let Sales = filteredItems[0].wiringdevices
                        {
                            cell.contentLabel.text = Utility.formatRupee(amount: Double(Sales )!)
                        }
                    case 1:
                        if let totalSales = filteredItems[0].lights
                        {
                            cell.contentLabel.text = Utility.formatRupee(amount: Double(totalSales )!)
                        }
                    case 2:
                        if let wireandcable = filteredItems[0].wireandcable
                        {
                            cell.contentLabel.text = Utility.formatRupee(amount: Double(wireandcable )!)
                        }
                    case 3:
                        if let pipes = filteredItems[0].pipesandfittings
                        {
                            cell.contentLabel.text = Utility.formatRupee(amount: Double(pipes )!)
                        }
                    case 4:
                        if let mcbanddbs = filteredItems[0].mcbanddbs
                        {
                            cell.contentLabel.text = Utility.formatRupee(amount: Double(mcbanddbs )!)
                        }
                    case 5:
                        if let branchcontribution = filteredItems[0].branchcontribution
                        {
                            cell.contentLabel.text = Utility.formatRupee(amount: Double(branchcontribution )!)
                        }
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
                        cell.contentLabel.text = "Branch Name"
                    case 1:
                        cell.contentLabel.text = "W D"
                    case 2:
                        cell.contentLabel.text = "Lights"
                    case 3:
                        cell.contentLabel.text = "W&C"
                    case 4:
                        cell.contentLabel.text = "P&F"
                    case 5:
                        cell.contentLabel.text = "Mcb&Dbs"
                    case 6:
                        cell.contentLabel.text = "Branch Contri"
                    case 7:
                        cell.contentLabel.text = "Contri %"
                    default:
                        break
                    }
                    
                } else if indexPath.section == filteredItems.count + 1 {
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
                        cell.contentLabel.text = Utility.formatRupee(amount: (totalSales["wiringdevices"]! ))
                    case 2:
                        cell.contentLabel.text = Utility.formatRupee(amount: (totalSales["lights"]! ))
                    case 3:
                        cell.contentLabel.text = Utility.formatRupee(amount: (totalSales["wireandcable"]! ))
                    case 4:
                        cell.contentLabel.text = Utility.formatRupee(amount: (totalSales["pipesandfittings"]! ))
                    case 5:
                        cell.contentLabel.text = Utility.formatRupee(amount: (totalSales["mcbanddbs"]! ))
                    case 6:
                        cell.contentLabel.text = Utility.formatRupee(amount: (totalSales["branchcontribution"]! ))
                    case 7:
                        cell.contentLabel.text = "\(Int(totalSales["branchcontributionpercentage"]!))%"
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
                        cell.contentLabel.text = filteredItems[indexPath.section - 1].branchnm
                    case 1:
                        if let Sales = filteredItems[indexPath.section - 1].wiringdevices
                        {
                            cell.contentLabel.text = Utility.formatRupee(amount: Double(Sales )!)
                        }
                    case 2:
                        if let totalSales = filteredItems[indexPath.section - 1].lights
                        {
                            cell.contentLabel.text = Utility.formatRupee(amount: Double(totalSales )!)
                        }
                    case 3:
                        if let wireandcable = filteredItems[indexPath.section - 1].wireandcable
                        {
                            cell.contentLabel.text = Utility.formatRupee(amount: Double(wireandcable )!)
                        }
                    case 4:
                        if let pipes = filteredItems[indexPath.section - 1].pipesandfittings
                        {
                            cell.contentLabel.text = Utility.formatRupee(amount: Double(pipes )!)
                        }
                    case 5:
                        if let mcbanddbs = filteredItems[indexPath.section - 1].mcbanddbs
                        {
                            cell.contentLabel.text = Utility.formatRupee(amount: Double(mcbanddbs )!)
                        }
                    case 6:
                        if let branchcontribution = filteredItems[indexPath.section - 1].branchcontribution
                        {
                            cell.contentLabel.text = Utility.formatRupee(amount: Double(branchcontribution )!)
                        }
                    case 7:
                        cell.contentLabel.text = filteredItems[indexPath.section - 1].branchcontributionpercentage! + "%"
                        
                    default:
                        break
                    }
                    
                }
                return cell}
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
                    cell.contentLabel.text = "Payment"
                case 2:
                    cell.contentLabel.text = "Contri %"
                default:
                    break
                }
                
            }else if indexPath.section == filteredPayment.count + 1 {
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
                    cell.contentLabel.text = Utility.formatRupee(amount: (totalPayment["payment"]! ))
                case 2:
                    cell.contentLabel.text = "\(Int(totalPayment["contri"]!))%"
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
                    cell.contentLabel.text = filteredPayment[indexPath.section - 1].branchnm
                case 1:
                    if let Sales = filteredPayment[indexPath.section - 1].payment
                    {
                        cell.contentLabel.text = Utility.formatRupee(amount: Double(Sales )!)
                    }
                case 2:
                    cell.contentLabel.text = filteredPayment[indexPath.section - 1].contribution! + "%"
                default:
                    break
                }
                
            }
            return cell
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if(indexPath.section == 0){
            let sb = UIStoryboard(name: "Search", bundle: nil)
            let popup = sb.instantiateInitialViewController()! as! SearchViewController
            popup.modalPresentationStyle = .overFullScreen
            popup.delegate = self
            popup.from = "branch"
            self.present(popup, animated: true)
        }
    }
    
    //Show Branches Func...
    func showSearchValue(value: String) {
        if showSales{
            if value == "ALL" {
                filteredItems = self.branchData
                self.branchwiseCollectionView.reloadData()
                self.branchwiseCollectionView.collectionViewLayout.invalidateLayout()
                return
            }
            filteredItems = self.branchData.filter { $0.branchnm == value }
        }else{
            if value == "ALL" {
                filteredPayment = self.branchPayData
                self.branchwiseCollectionView.reloadData()
                self.branchwiseCollectionView.collectionViewLayout.invalidateLayout()
                return
            }
            filteredPayment = self.branchPayData.filter { $0.branchnm == value }
        }
        self.branchwiseCollectionView.reloadData()
        self.branchwiseCollectionView.collectionViewLayout.invalidateLayout()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "byAgent") {
            if let destination = segue.destination as? DivisionWiseDetailsCollectionViewController{
                destination.dataToRecieve = [filteredItems[0]]
                destination.dateTo = dateTo
                destination.dateFrom = dateFrom
                destination.fromSales = "yes"
            }
        }else{
            if let destination = segue.destination as? DivisionWiseDetailsCollectionViewController,
                let index = branchwiseCollectionView.indexPathsForSelectedItems?.first{
                if index.section > 0{
                    if showSales{
                        destination.dataToRecieve = [filteredItems[index.section-1]]
                        destination.dateTo = dateTo
                        destination.dateFrom = dateFrom
                        destination.fromSales = "yes"
                    }else{
                        destination.dataFromPay = [filteredPayment[index.section-1]]
                        destination.dateTo = dateTo
                        destination.dateFrom = dateFrom
                        destination.fromSales = "no"
                    }
                }
                else{
                    return
                }
            }
        }
        
    }
    
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        //Block Segue if branchname is clicked...
        if let index = branchwiseCollectionView.indexPathsForSelectedItems?.first{
            if((index.section) > 0){
                if showSales{
                    if index.section == self.filteredItems.count + 1{
                        return false
                    } else {
                        return true
                    }
                }else{
                    if index.section == self.filteredPayment.count + 1{
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
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
}

