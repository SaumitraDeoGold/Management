//
//  CategoryWiseCompareController.swift
//  ManagementApp
//
//  Created by Goldmedal on 12/11/19.
//  Copyright © 2019 Goldmedal. All rights reserved.
//

import UIKit

class CategoryWiseCompareController: BaseViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    //Outlets...
    @IBOutlet weak var lblPartyName: UIButton!
    @IBOutlet weak var txtAmount: UITextField!
    @IBOutlet weak var noDataView: NoDataView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var btnFinancialYear: RoundButton!
    
    //Declarations...
    var categorywiseComp = [Categorywise]()
    var categorywiseCompObj = [CategorywiseObj]()
    var filteredItems = [CategorywiseObj]()
    var cellContentIdentifier = "\(CollectionViewCell.self)"
    var categoryApiUrl = ""
    var dateTo = ""
    var dateFrom = "04/01/2019"
    var prevDateTo = ""
    var prevDateFrom = "04/01/2018"
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
    var divCode = "1"
    
    var total = ["currYS":0.0,"prevYs":0.0]
    var allMonths = ["JANUARY", "FEBRUARY", "MARCH", "APRIL","MAY","JUNE","JULY","AUGUST","SEPTEMBER","OCTOBER","NOVEMBER","DECEMBER"];
    var quatMonths = ["Q1 (APR - JUN)", "Q2 (JUL - SEP)", "Q3 (OCT - DEC)", "Q4 (JAN - MAR)"];
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addSlideMenuButton()
        self.noDataView.hideView(view: self.noDataView)
        dateFormatter.dateFormat = "MM/dd/yyyy"
        monthFormatter.dateFormat = "MM"
        yearFormatter.dateFormat = "yyyy"
        setDate()
        categoryApiUrl = "https://api.goldmedalindia.in/api/GetCategoryWiseSalesCompare"
        ViewControllerUtils.sharedInstance.showLoader()
        apiCompare()
        self.lblPartyName.setTitle("  WIRING DEVICES", for: .normal)
    }
    
    //Button...
    @IBAction func searchParty(_ sender: Any) {
        let sb = UIStoryboard(name: "PartyStoryboard", bundle: nil)
        let popup = sb.instantiateInitialViewController()! as! PartySearchController
        popup.modalPresentationStyle = .overFullScreen
        popup.delegate = self
        popup.fromPage = "Division"
        self.present(popup, animated: true)
    }
    
    @IBAction func yearlyClicked(_ sender: Any) {
        //Copied yearlyClicked Code for UI temporary
        //lblFinYear.text = "Financial Year"
        let sb = UIStoryboard(name: "CustomYearPicker", bundle: nil)
        let popup = sb.instantiateInitialViewController()! as! CustomYearPickerController
        popup.modalPresentationStyle = .overFullScreen
        popup.delegate = self
        popup.showPicker = 3
        self.present(popup, animated: true)
//        callFrom = 0
//        opType = 3
//        opValue = 0
    }
    
    //SetDate...
    func setDate(){
        //btnFinancialYear.setTitle("2018-2019", for: .normal)
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
    }
    
    
    //Popup Func...
    func showParty(value: String,cin: String) {
        lblPartyName.setTitle("  \(value)", for: .normal)
        divCode = cin
        ViewControllerUtils.sharedInstance.showLoader()
        apiCompare()
    }
    
    func updatePositionValue(value: String, position: Int, from: String) {
        ViewControllerUtils.sharedInstance.showLoader()
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
        apiCompare()
    }
    
    //APIFUNC...
    func apiCompare(){
        let json: [String: Any] = ["CurFromDate":dateFrom,"CurToDate":dateTo,"ClientSecret":"ClientSecret","CIN":UserDefaults.standard.value(forKey: "userCIN") as! String,"Category":UserDefaults.standard.value(forKey: "userCategory") as! String,"LastFromDate":prevDateFrom,"LastToDate":prevDateTo,"divisionid":self.divCode]
        let manager =  DataManager.shared
        print("Params Sent : \(json)")
        manager.makeAPICall(url: categoryApiUrl, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            
            do {
                //self.dashDivObj.removeAll()
                self.categorywiseComp = try JSONDecoder().decode([Categorywise].self, from: data!)
                self.categorywiseCompObj  = self.categorywiseComp[0].data
                self.filteredItems = self.categorywiseComp[0].data
                //Total of All Items...
                self.total["currYS"] = self.filteredItems.reduce(0, { $0 + Double($1.currentyearsaleamt!)! })
                self.total["prevYs"] = self.filteredItems.reduce(0, { $0 + Double($1.lastyearssaleamt!)! })
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
    
    //Collectionview...
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return filteredItems.count + 2
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
//        let newViewController = storyboard!.instantiateViewController(withIdentifier: "CategoryWiseChild") as! CategoryCompChildViewController
//        newViewController.catCode = String(filteredItems[indexPath.section-1].slno!)
        //self.present(newViewController, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //If item other than BranchName clicked then open next page...
        if let destination = segue.destination as? CategoryCompChildViewController,
            let index = collectionView.indexPathsForSelectedItems?.first{
            if index.section > 0{
                destination.dataToRecieve = filteredItems
                destination.catCode = String(filteredItems[index.section-1].slno!)
                destination.dateTo = dateTo
                destination.dateFrom = dateFrom
                destination.prevDateTo = prevDateTo
                destination.prevDateFrom = prevDateFrom
                destination.catName = filteredItems[index.section-1].categorynm!
                destination.divCode = divCode
            }
            else{
                return
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellContentIdentifier,
                                                      for: indexPath) as! CollectionViewCell
        cell.layer.borderWidth = 1
        cell.layer.borderColor = UIColor.white.cgColor
        if filteredItems.count > 0{
            if indexPath.section == 0 {
                cell.contentLabel.font = UIFont(name: "Roboto-Medium", size: 14)
                if #available(iOS 11.0, *) {
                    cell.backgroundColor = UIColor.init(named: "Primary")
                } else {
                    cell.backgroundColor = UIColor.gray
                }
                switch indexPath.row{
                case 0:
                    cell.contentLabel.text = "Category"
                case 1:
                    cell.contentLabel.text = "Current Year Sale"
                case 2:
                    cell.contentLabel.text = "Previous Year Sale"
                default:
                    break
                }
                
            } else if indexPath.section == filteredItems.count + 1{
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
                    let currentYear = Double(total["currYS"]!)
                    let prevYear = Double(total["prevYs"]!)
                    let temp = ((currentYear - prevYear)/prevYear)*100
                    cell.contentLabel.attributedText = calculatePercentage(currentYear: currentYear, prevYear: prevYear, temp: temp)
                //cell.contentLabel.text = Utility.formatRupee(amount: (total["currWd"]! ))
                case 2:
                    cell.contentLabel.text = Utility.formatRupee(amount: (total["prevYs"]! ))
                    
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
                    cell.contentLabel.text = filteredItems[indexPath.section - 1].categorynm
                case 1:
                    let currentYear = Double(filteredItems[indexPath.section - 1].currentyearsaleamt!)!
                    let prevYear = Double(filteredItems[indexPath.section - 1].lastyearssaleamt!)!
                    let temp = ((currentYear - prevYear)/prevYear)*100
                    cell.contentLabel.attributedText = calculatePercentage(currentYear: currentYear, prevYear: prevYear, temp: temp)
                case 2:
                    if let lastwiringdevices = filteredItems[indexPath.section - 1].lastyearssaleamt
                    {
                        cell.contentLabel.text = Utility.formatRupee(amount: Double(lastwiringdevices )!)
                    }
                    
                default:
                    break
                }
                
            }
        }
        return cell
    }
    
}
