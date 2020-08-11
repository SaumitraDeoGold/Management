//
//  YearlyCompareController.swift
//  ManagementApp
//
//  Created by Goldmedal on 13/08/19.
//  Copyright © 2019 Goldmedal. All rights reserved.
//

import UIKit

class YearlyCompareController: BaseViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    //Outlets...
    @IBOutlet weak var btnFinancialYear: RoundButton!
    @IBOutlet weak var lblYearly: RoundButton!
    @IBOutlet weak var lblMonthly: RoundButton!
    @IBOutlet weak var lblQuarterly: RoundButton!
    @IBOutlet weak var noDataView: NoDataView!
    @IBOutlet weak var lblFinYear: UILabel!
    @IBOutlet weak var sort: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    //Declarations...
    var categorywiseComp = [CategorywiseComp]()
    var categorywiseCompObj = [CategorywiseCompObj]()
    var filteredItems = [CategorywiseCompObj]()
    var compareApiUrl = ""
    var cellContentIdentifier = "\(CollectionViewCell.self)"
    //Picker Related...
    var finYear = ""
    var opType = 3
    var opValue = 0
    var currPosition = 0
    var callFrom = 0
    var strCin = ""
    var strTotalAmnt = "-"
    var dateTo = "03/31/2021"
    var dateFrom = "04/01/2020"
    var prevDateTo = "03/31/2020"
    var prevDateFrom = "04/01/2019"
    var yearStart = "2020"
    var yearEnd = "2021"
    let qrtrlyArrayStart = Utility.quarterlyStartDate()
    let qrtrlyArrayEnd = Utility.quarterlyEndDate()
    let monthEnds = Utility.getMonthEndDate()
    let months = Utility.getMonths()
    var dateFormatter = DateFormatter()
    let monthFormatter = DateFormatter()
    let yearFormatter = DateFormatter()
    let currDate = Date()
    var total = ["currWd":0.0,"currLights":0.0,"currPf":0.0,"currWc":0.0,"currMcbDbs":0.0,"prevWd":0.0,"prevLights":0.0,"prevPf":0.0,"prevWc":0.0,"prevMcbDbs":0.0]
    var allMonths = ["JANUARY", "FEBRUARY", "MARCH", "APRIL","MAY","JUNE","JULY","AUGUST","SEPTEMBER","OCTOBER","NOVEMBER","DECEMBER"];
    var quatMonths = ["Q1 (APR - JUN)", "Q2 (JUL - SEP)", "Q3 (OCT - DEC)", "Q4 (JAN - MAR)"];
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addSlideMenuButton()
        self.noDataView.hideView(view: self.noDataView)
        dateFormatter.dateFormat = "MM/dd/yyyy"
        monthFormatter.dateFormat = "MM"
        yearFormatter.dateFormat = "yyyy"
//        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(clicked_sort(tapGestureRecognizer:)))
//        //sort.isUserInteractionEnabled = true
//        sort.addGestureRecognizer(tapGestureRecognizer)
        compareApiUrl = "https://api.goldmedalindia.in/api/GetTotalSaleBranchWiseLast"
        ViewControllerUtils.sharedInstance.showLoader()
        apiCompare()
    }
    
    @IBAction func clicked_sort(_ sender: Any) {
        let sb = UIStoryboard(name: "Sorting", bundle: nil)
        let popup = sb.instantiateInitialViewController()! as! SortViewController
        popup.modalPresentationStyle = .overFullScreen
        popup.delegate = self
        popup.showPicker = 1
        popup.pickerDataSource = ["A-Z","Z-A","low to high Current Sale","high to low Current Sale","low to high Previous Sale","high to low Previous Sale"]
        self.present(popup, animated: true)
    }
    
    func sortBy(value: String, position: Int) {
        switch position {
        case 0:
            self.filteredItems = self.filteredItems.sorted{($0.branchnm)!.localizedCaseInsensitiveCompare($1.branchnm!) == .orderedAscending}
        case 1:
            self.filteredItems = self.filteredItems.sorted{($0.branchnm)!.localizedCaseInsensitiveCompare($1.branchnm!) == .orderedDescending}
        case 2:
            self.filteredItems = self.filteredItems.sorted(by: {Double($0.curbranchcontribution!)! < Double($1.curbranchcontribution!)!})
        case 3:
            self.filteredItems = self.filteredItems.sorted(by: {Double($0.curbranchcontribution!)! > Double($1.curbranchcontribution!)!})
        case 4:
            self.filteredItems = self.filteredItems.sorted(by: {Double($0.lastbranchcontribution!)! < Double($1.lastbranchcontribution!)!})
        case 5:
            self.filteredItems = self.filteredItems.sorted(by: {Double($0.lastbranchcontribution!)! > Double($1.lastbranchcontribution!)!})
        default:
            break
        }
        
        self.collectionView.reloadData()
        self.collectionView.collectionViewLayout.invalidateLayout()
    }
    
    //Buttons Clicked...
    @IBAction func yearlyClicked(_ sender: Any) {
        ViewControllerUtils.sharedInstance.showLoader()
        callFrom = 3
        yearStart = "2019"
        yearEnd = "2020"
        let todayDate = Calendar.current.component(.day, from: currDate)
        let currMonth = monthFormatter.string(from: currDate)
        let currYear = yearFormatter.string(from: currDate)
        let tempYear = String(Double(yearStart)! - 1)
        var prevYear = tempYear.split{$0 == "."}.map(String.init)
        dateFrom = months[3]+"01/"+yearStart
        prevDateFrom = months[3]+"01/"+yearStart
        dateTo = "\(currMonth)/\(todayDate)/\(yearStart)"
        prevDateTo = "\(currMonth)/\(todayDate)/\(prevYear[0])"
        apiCompare()
        //highlightedButton(callfrom: 3)
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
            //highlightedButton(callfrom: 3)
            btnFinancialYear.setTitle(value, for: .normal)
            var tempArray = value.components(separatedBy: "-")
            yearStart = tempArray[0]
            yearEnd = tempArray[1]
            let todayDate = Calendar.current.component(.day, from: currDate)
            let currMonth = monthFormatter.string(from: currDate)
            let currYear = yearFormatter.string(from: currDate)
            let tempYear = String(Double(yearStart)! - 1)
            let tempYearNext = String(Double(yearStart)! + 1)
            var prevYear = tempYear.split{$0 == "."}.map(String.init)
            let nextYear = tempYearNext.split{$0 == "."}.map(String.init)
            dateFrom = months[3]+"01/"+yearStart
            prevDateFrom = months[3]+"01/"+prevYear[0]
            if(yearStart == currYear)
            {
                dateTo = "\(currMonth)/\(todayDate)/\(yearStart)"
                prevDateTo = "\(currMonth)/\(todayDate)/\(prevYear[0])"
            }else{
                dateTo = "03/31/\(nextYear[0])"
                prevDateTo = "03/31/\(yearStart)"
            }
        case 1:
            
            //highlightedButton(callfrom: 1)
            let todayDate = Calendar.current.component(.day, from: currDate)
            let currMonth = monthFormatter.string(from: currDate)
            _ = yearFormatter.string(from: currDate)
            let tempYear = String(Double(yearStart)! - 1)
            let prevYear = tempYear.split{$0 == "."}.map(String.init)
            dateFrom = months[position]+"01/"+yearStart
            if position == 0{
                lblFinYear.text = "Monthly Report previous DECEMBER - \(value) "
                prevDateFrom = "12/01/\(prevYear)"
            }else{
                lblFinYear.text = "Monthly Report \(allMonths[position-1]) - \(value) "
                prevDateFrom = months[position-1]+"01/"+yearStart
            }
            
            if(currMonth==months[position]){
                dateTo = "\(currMonth)/\(todayDate)/\(yearStart)"
                if position == 0{
                    prevDateTo = "12/\(todayDate)/\(prevYear)"
                }else{
                    prevDateTo = "\(months[position-1])/\(todayDate)/\(yearStart)"
                }
            }else{
               dateTo = months[position]+monthEnds[position]+yearStart
                if position == 0{
                    prevDateTo = "12/\(monthEnds[position])\(prevYear)"
                }else{
                    prevDateTo = months[position-1]+monthEnds[position]+yearStart
                }
                
            }
        case 2:
            
            //highlightedButton(callfrom: 2)
            if(position==3){
                dateFrom = qrtrlyArrayStart[position] + yearEnd
                dateTo = qrtrlyArrayEnd[position] + yearEnd
                prevDateFrom = qrtrlyArrayStart[position-1] + yearStart
                prevDateTo = qrtrlyArrayEnd[position-1] + yearStart
                lblFinYear.text = "Quarterly Report \(quatMonths[position-1]) - \(value)"
            }else if(position==0){
                dateFrom = qrtrlyArrayStart[position] + yearStart
                dateTo = qrtrlyArrayEnd[position] + yearStart
                prevDateFrom = qrtrlyArrayStart[3] + yearStart
                prevDateTo = qrtrlyArrayEnd[3] + yearStart
                lblFinYear.text = "Quarterly Report \(quatMonths[3]) - \(value)"
            }else {
                dateFrom = qrtrlyArrayStart[position] + yearStart
                dateTo = qrtrlyArrayEnd[position] + yearStart
                prevDateFrom = qrtrlyArrayStart[position-1] + yearStart
                prevDateTo = qrtrlyArrayEnd[position-1] + yearStart
                lblFinYear.text = "Quarterly Report \(quatMonths[position-1]) - \(value)"
            }
            
        default:
            print("Error")
        }
        
        apiCompare()
    }
    
    //Collectionview...
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return filteredItems.count + 2
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 13
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellContentIdentifier,
                                                                for: indexPath) as! CollectionViewCell
        cell.layer.borderWidth = 1
        cell.layer.borderColor = UIColor.white.cgColor
        
        if indexPath.section == 0 {
            cell.contentLabel.font = UIFont(name: "Roboto-Medium", size: 14)
            if #available(iOS 11.0, *) {
                cell.backgroundColor = UIColor.init(named: "Primary")
            } else {
                cell.backgroundColor = UIColor.gray
            }
            switch indexPath.row{
            case 0:
                cell.contentLabel.text = "Branch Name"
            case 1:
                cell.contentLabel.text = "Current W D"
            case 2:
                cell.contentLabel.text = "Previous W D"
            case 3:
                cell.contentLabel.text = "Current Lights"
            case 4:
                cell.contentLabel.text = "Previous Lights"
            case 5:
                cell.contentLabel.text = "Current W&C"
            case 6:
                cell.contentLabel.text = "Previous W&C"
            case 7:
                cell.contentLabel.text = "Current P&F"
            case 8:
                cell.contentLabel.text = "Previous P&F"
            case 9:
                cell.contentLabel.text = "Current Mcb&Dbs"
            case 10:
                cell.contentLabel.text = "Previous Mcb&Dbs"
            case 11:
                cell.contentLabel.text = "Curr. Sale"
            case 12:
                cell.contentLabel.text = "Prev. Sale"
            default:
                break
            }
            
        }else if indexPath.section == filteredItems.count + 1{
            cell.contentLabel.font = UIFont(name: "Roboto-Regular", size: 14)
            if #available(iOS 11.0, *) {
                cell.backgroundColor = UIColor.init(named: "Primary")
            } else {
                cell.backgroundColor = UIColor.gray
            }
            switch indexPath.row{
            case 0:
                cell.contentLabel.text = "SUM"
            case 1:
                let currentYear = Double(total["currWd"]!)
                let prevYear = Double(total["prevWd"]!)
                let temp = ((currentYear - prevYear)/prevYear)*100
                cell.contentLabel.attributedText = calculatePercentage(currentYear: currentYear, prevYear: prevYear, temp: temp)
                //cell.contentLabel.text = Utility.formatRupee(amount: (total["currWd"]! ))
            case 2:
                cell.contentLabel.text = Utility.formatRupee(amount: (total["prevWd"]! ))
            case 3:
                let currentYear = Double(total["currLights"]!)
                let prevYear = Double(total["prevLights"]!)
                let temp = ((currentYear - prevYear)/prevYear)*100
                cell.contentLabel.attributedText = calculatePercentage(currentYear: currentYear, prevYear: prevYear, temp: temp)
            case 4:
                cell.contentLabel.text = Utility.formatRupee(amount: (total["prevLights"]! ))
            case 5:
                let currentYear = Double(total["currWc"]!)
                let prevYear = Double(total["prevWc"]!)
                let temp = ((currentYear - prevYear)/prevYear)*100
                cell.contentLabel.attributedText = calculatePercentage(currentYear: currentYear, prevYear: prevYear, temp: temp)
            case 6:
                cell.contentLabel.text = Utility.formatRupee(amount: (total["prevWc"]! ))
            case 7:
                let currentYear = Double(total["currPf"]!)
                let prevYear = Double(total["prevPf"]!)
                let temp = ((currentYear - prevYear)/prevYear)*100
                cell.contentLabel.attributedText = calculatePercentage(currentYear: currentYear, prevYear: prevYear, temp: temp)
            case 8:
                cell.contentLabel.text = Utility.formatRupee(amount: (total["prevPf"]! ))
            case 9:
                let currentYear = Double(total["currMcbDbs"]!)
                let prevYear = Double(total["prevMcbDbs"]!)
                let temp = ((currentYear - prevYear)/prevYear)*100
                cell.contentLabel.attributedText = calculatePercentage(currentYear: currentYear, prevYear: prevYear, temp: temp) 
            case 10:
                cell.contentLabel.text = Utility.formatRupee(amount: (total["prevMcbDbs"]! ))
            case 11:
                if let curtotalsale = filteredItems[0].curtotalsale
                {
                    cell.contentLabel.text = Utility.formatRupee(amount: Double(curtotalsale )!)
                }
            case 12:
                if let lasttotalsale = filteredItems[0].lasttotalsale
                {
                    cell.contentLabel.text = Utility.formatRupee(amount: Double(lasttotalsale )!)
                }
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
                let currentYear = Double(filteredItems[indexPath.section - 1].curwiringdevices!)!
                let prevYear = Double(filteredItems[indexPath.section - 1].lastwiringdevices!)!
                let temp = ((currentYear - prevYear)/prevYear)*100
                cell.contentLabel.attributedText = calculatePercentage(currentYear: currentYear, prevYear: prevYear, temp: temp)
            case 2:
                if let lastwiringdevices = filteredItems[indexPath.section - 1].lastwiringdevices
                {
                    cell.contentLabel.text = Utility.formatRupee(amount: Double(lastwiringdevices )!)
                }
            case 3:
                let currentYear = Double(filteredItems[indexPath.section - 1].curlights!)!
                let prevYear = Double(filteredItems[indexPath.section - 1].lastlights!)!
                let temp = ((currentYear - prevYear)/prevYear)*100
                cell.contentLabel.attributedText = calculatePercentage(currentYear: currentYear, prevYear: prevYear, temp: temp)
            case 4:
                if let lastlights = filteredItems[indexPath.section - 1].lastlights
                {
                    cell.contentLabel.text = Utility.formatRupee(amount: Double(lastlights )!)
                }
            case 5:
                let currentYear = Double(filteredItems[indexPath.section - 1].curwireandcable!)!
                let prevYear = Double(filteredItems[indexPath.section - 1].lastwireandcable!)!
                let temp = ((currentYear - prevYear)/prevYear)*100
                cell.contentLabel.attributedText = calculatePercentage(currentYear: currentYear, prevYear: prevYear, temp: temp)
            case 6:
                if let lastwireandcable = filteredItems[indexPath.section - 1].lastwireandcable
                {
                    cell.contentLabel.text = Utility.formatRupee(amount: Double(lastwireandcable )!)
                }
            case 7:
                let currentYear = Double(filteredItems[indexPath.section - 1].curpipesandfittings!)!
                let prevYear = Double(filteredItems[indexPath.section - 1].lastpipesandfittings!)!
                let temp = ((currentYear - prevYear)/prevYear)*100
                cell.contentLabel.attributedText = calculatePercentage(currentYear: currentYear, prevYear: prevYear, temp: temp)
            case 8:
                if let lastpipesandfittings = filteredItems[indexPath.section - 1].lastpipesandfittings
                {
                    cell.contentLabel.text = Utility.formatRupee(amount: Double(lastpipesandfittings )!)
                }    
            case 9:
                let currentYear = Double(filteredItems[indexPath.section - 1].curmcbanddbs!)!
                let prevYear = Double(filteredItems[indexPath.section - 1].lastmcbanddbs!)!
                let temp = ((currentYear - prevYear)/prevYear)*100
                cell.contentLabel.attributedText = calculatePercentage(currentYear: currentYear, prevYear: prevYear, temp: temp)
            case 10:
                if let lastmcbanddbs = filteredItems[indexPath.section - 1].lastmcbanddbs
                {
                    cell.contentLabel.text = Utility.formatRupee(amount: Double(lastmcbanddbs )!)
                }
            case 11:
                let currentYear = Double(filteredItems[indexPath.section - 1].curbranchcontribution!)!
                let prevYear = Double(filteredItems[indexPath.section - 1].lastbranchcontribution!)!
                let temp = ((currentYear - prevYear)/prevYear)*100
                cell.contentLabel.attributedText = calculatePercentage(currentYear: currentYear, prevYear: prevYear, temp: temp)
            case 12:
                if let lastbranchcontribution = filteredItems[indexPath.section - 1].lastbranchcontribution
                {
                    cell.contentLabel.text = Utility.formatRupee(amount: Double(lastbranchcontribution )!)
                }
            default:
                break
            }
            
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == self.collectionView {
            if(indexPath.row == 0 && indexPath.section == 0){
                let sb = UIStoryboard(name: "Search", bundle: nil)
                let popup = sb.instantiateInitialViewController()! as! SearchViewController
                popup.modalPresentationStyle = .overFullScreen
                popup.delegate = self
                popup.from = "branch"
                self.present(popup, animated: true)
            }
        }
    }
    
    func showSearchValue(value: String) {
        if value == "ALL" {
            filteredItems = self.categorywiseCompObj
            self.collectionView.reloadData()
            self.collectionView.collectionViewLayout.invalidateLayout()
            return
        }
        filteredItems = self.categorywiseCompObj.filter { $0.branchnm == value }
        self.collectionView.reloadData()
        self.collectionView.collectionViewLayout.invalidateLayout()
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
    
    //APIFUNC...
    func apiCompare(){
        let json: [String: Any] = ["CurFromDate":dateFrom,"CurToDate":dateTo,"ClientSecret":"ClientSecret","CIN":UserDefaults.standard.value(forKey: "userCIN") as! String,"Category":UserDefaults.standard.value(forKey: "userCategory") as! String,"LastFromDate":prevDateFrom,"LastToDate":prevDateTo]
        let manager =  DataManager.shared
        print("Params Sent : \(json)")
        manager.makeAPICall(url: compareApiUrl, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            
            do {
                //self.dashDivObj.removeAll()
                self.categorywiseComp = try JSONDecoder().decode([CategorywiseComp].self, from: data!)
                self.categorywiseCompObj  = self.categorywiseComp[0].data
                self.filteredItems = self.categorywiseComp[0].data
                //Total of All Items...
                self.total["currWd"] = self.filteredItems.reduce(0, { $0 + Double($1.curwiringdevices!)! })
                self.total["currLights"] = self.filteredItems.reduce(0, { $0 + Double($1.curlights!)! })
                self.total["currWc"] = self.filteredItems.reduce(0, { $0 + Double($1.curwireandcable!)! })
                self.total["currPf"] = self.filteredItems.reduce(0, { $0 + Double($1.curpipesandfittings!)! })
                self.total["currMcbDbs"] = self.filteredItems.reduce(0, { $0 + Double($1.curmcbanddbs!)! })
                self.total["prevWd"] = self.filteredItems.reduce(0, { $0 + Double($1.lastwiringdevices!)! })
                self.total["prevLights"] = self.filteredItems.reduce(0, { $0 + Double($1.lastlights!)! })
                self.total["prevWc"] = self.filteredItems.reduce(0, { $0 + Double($1.lastwireandcable!)! })
                self.total["prevPf"] = self.filteredItems.reduce(0, { $0 + Double($1.lastpipesandfittings!)! })
                self.total["prevMcbDbs"] = self.filteredItems.reduce(0, { $0 + Double($1.lastmcbanddbs!)! })
                //self.totalAmount = self.dashBranchObj.reduce(0, { $0 + Double($1.amount!)! })
                self.collectionView.reloadData()
                self.collectionView.collectionViewLayout.invalidateLayout()
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
