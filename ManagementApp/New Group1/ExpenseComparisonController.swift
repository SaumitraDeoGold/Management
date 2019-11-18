
//  ExpenseComparisonController.swift
//  ManagementApp
//
//  Created by Goldmedal on 28/06/19.
//  Copyright © 2019 Goldmedal. All rights reserved.
//

import UIKit

class ExpenseComparisonController: UIViewController, PopupDateDelegate, UICollectionViewDataSource, UICollectionViewDelegate {
    
    
    //Outlets...
    @IBOutlet weak var CollectionView: UICollectionView!
    @IBOutlet weak var sort: UIImageView!
    @IBOutlet weak var btnFinancialYear: RoundButton!
    @IBOutlet weak var lblFinYear: UILabel!
    
    //Declarations...
    var expenseComparisonUrl = ""
    var expCompare = [ExpenseComparison]()
    var expCompareObj = [ExpenseComparisonObj]()
    var filteredItems = [ExpenseComparisonObj]()
    var cellContentIdentifier = "\(CollectionViewCell.self)"
    var totalSal = 0.0
    var totalExp = 0.0
    var totalSale = 0.0
    var dateTo = "03/31/2020"
    var dateFrom = "04/01/2019"
    let qrtrlyArrayStart = Utility.quarterlyStartDate()
    let qrtrlyArrayEnd = Utility.quarterlyEndDate()
    let monthEnds = Utility.getMonthEndDate()
    let months = Utility.getMonths()
    var partywiseApiUrl = ""
    var partwiseComp = [LedgerwiseExpense]()
    var partwiseCompObj = [LedgerwiseExpenseObj]()
    var total = 0.0
    var showBranchwise = true
    var noOfColumns = Int()
    var customDivLayout = ExpenseLayout()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.noOfColumns = 4
        expenseComparisonUrl = "https://test2.goldmedalindia.in/api/getManagementBranchwiseExpense"
        partywiseApiUrl = "https://test2.goldmedalindia.in/api/getExpenseChildAll"
        ViewControllerUtils.sharedInstance.showLoader()
        apiExpComparison()
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        sort.isUserInteractionEnabled = true
        sort.addGestureRecognizer(tapGestureRecognizer)
    }
    
    //Sort Related...
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        let sb = UIStoryboard(name: "Sorting", bundle: nil)
        let popup = sb.instantiateInitialViewController()! as! SortViewController
        popup.modalPresentationStyle = .overFullScreen
        popup.delegate = self
        popup.showPicker = 1
        popup.pickerDataSource = ["Ledgerwise Comparison","Branchwise Comparison","A-Z","Z-A"]
        self.present(popup, animated: true)
    }
    
    func sortBy(value: String, position: Int) {
        switch position {
        case 2:
            self.filteredItems = self.expCompareObj.sorted{($0.branchnm)!.localizedCaseInsensitiveCompare($1.branchnm!) == .orderedAscending}
            self.CollectionView.reloadData()
            self.CollectionView.collectionViewLayout.invalidateLayout()
        case 3:
            self.filteredItems = self.expCompareObj.sorted{($0.branchnm)!.localizedCaseInsensitiveCompare($1.branchnm!) == .orderedDescending}
            self.CollectionView.reloadData()
            self.CollectionView.collectionViewLayout.invalidateLayout()
        case 0:
            apiGetPranchwiseComp()
        case 1:
            apiExpComparison()
        default:
            break
        }
    }
    
    //Button Functions....
    @IBAction func yearClicked(_ sender: Any) { 
        let sb = UIStoryboard(name: "CustomYearPicker", bundle: nil)
        let popup = sb.instantiateInitialViewController()! as! CustomYearPickerController
        popup.modalPresentationStyle = .overFullScreen
        popup.delegate = self
        popup.showPicker = 3
        self.present(popup, animated: true)
    }
    
    //Picker Functions...
    func updatePositionValue(value: String, position: Int, from: String) {
        ViewControllerUtils.sharedInstance.showLoader()
        switch position {
        case 0:
            dateTo = "03/31/2018"
            dateFrom = "04/01/2017"
        case 1:
            dateTo = "03/31/2019"
            dateFrom = "04/01/2018"
        case 2:
            dateTo = "03/31/2020"
            dateFrom = "04/01/2019"
        default:
            print("Error")
        }
        btnFinancialYear.setTitle(value, for: .normal)
        apiExpComparison()
    }
    
    //CollectionView Functions...
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if(showBranchwise){
            return expCompareObj.count + 2
        }else{
            return partwiseCompObj.count + 2
        }
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return noOfColumns
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = CollectionView.dequeueReusableCell(withReuseIdentifier: cellContentIdentifier,
                                                      for: indexPath) as! CollectionViewCell
        cell.layer.borderWidth = 1
        cell.layer.borderColor = UIColor.white.cgColor
        if(showBranchwise){
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
                    cell.contentLabel.text = "Sale"
                    cell.contentLabel.textColor = UIColor.black
                case 2:
                    cell.contentLabel.text = "Expense"
                case 3:
                    cell.contentLabel.text = "Salary"
                default:
                    break
                }
                cell.backgroundColor = UIColor.lightGray
            }else if indexPath.section == expCompareObj.count + 1{
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
                    cell.contentLabel.text = Utility.formatRupee(amount: Double(totalSale))
                    cell.contentLabel.textColor = UIColor.black
                case 3:
                    cell.contentLabel.text = Utility.formatRupee(amount: Double(totalSal))
                    cell.contentLabel.textColor = UIColor.black
                case 2:
                    cell.contentLabel.text = Utility.formatRupee(amount: Double(totalExp))
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
                    if let otherespenses = filteredItems[indexPath.section - 1].sale
                    {
                        cell.contentLabel.text = Utility.formatRupee(amount: Double(otherespenses )!)
                    }
                case 2:
                    
                    let currentYear = Double(filteredItems[indexPath.section - 1].otherespenses!)
                    let prevYear = Double(filteredItems[indexPath.section - 1].sale!)
                    //let temp = ((currentYear - prevYear)/prevYear)*100
                    let temp = ((Double(self.filteredItems[indexPath.section - 1].otherespenses!)! / (Double(filteredItems[indexPath.section - 1].sale!)!))*100)
                    cell.contentLabel.attributedText = calculatePercentage(currentYear: currentYear!, prevYear: prevYear!, temp: temp)
                    
                case 3:
                    
                    let currentYear = Double(filteredItems[indexPath.section - 1].salary!)
                    let prevYear = Double(filteredItems[indexPath.section - 1].sale!)
                    //let temp = ((currentYear - prevYear)/prevYear)*100
                    let temp = ((Double(self.filteredItems[indexPath.section - 1].salary!)! / (Double(filteredItems[indexPath.section - 1].sale!)!))*100)
                    cell.contentLabel.attributedText = calculatePercentage(currentYear: currentYear!, prevYear: prevYear!, temp: temp)
                default:
                    break
                }
                cell.backgroundColor = UIColor.groupTableViewBackground
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
                    cell.contentLabel.text = "Party Name"
                case 1:
                    cell.contentLabel.text = "Amount"
                    
                default:
                    break
                }
                //cell.backgroundColor = UIColor.lightGray
            }else if indexPath.section == partwiseCompObj.count+1{
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
                    cell.contentLabel.text = Utility.formatRupee(amount: Double(total))
                    cell.contentLabel.textColor = UIColor.black
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
                    cell.contentLabel.text = partwiseCompObj[indexPath.section - 1].name
                case 1:
                    let currentYear = Double(partwiseCompObj[indexPath.section - 1].amount!)!
                    let prevYear = Double(total)
                    //let temp = ((currentYear - prevYear)/prevYear)*100
                    let temp = (currentYear*100)/prevYear
                    cell.contentLabel.attributedText = calculatePercentage(currentYear: currentYear, prevYear: prevYear, temp: temp)
                    //                if let amount = partwiseCompObj[indexPath.section - 1].amount
                    //                {
                    //                    cell.contentLabel.text = Utility.formatRupee(amount: Double(amount )!)
                //                }
                default:
                    break
                }
                //cell.backgroundColor = UIColor.groupTableViewBackground
            }
        }
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? PartywiseComparisonController,
            let index = CollectionView.indexPathsForSelectedItems?.first{
            destination.dataToRecieve = [filteredItems[index.section-1]]
            destination.fromDate = dateFrom
            destination.toDate = dateTo
            //destination.type = index.row == 2 ? "2" : "1"
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if let index = CollectionView.indexPathsForSelectedItems?.first{
            if((index.section) > 0){
                if index.section == self.filteredItems.count + 1{
                    return false
                }else{
                    return true}
            }else{
                return false
            }
        }else{
            return false
        }
    }
    
    //API CALLS..............
    func apiExpComparison(){
        
        let json: [String: Any] = ["ClientSecret":"jgsfhfdk", "fromdate":dateFrom, "todate":dateTo,"CIN":UserDefaults.standard.value(forKey: "userCIN") as! String,"Category":UserDefaults.standard.value(forKey: "userCategory") as! String,]
        
        let manager =  DataManager.shared
        print("Accounts exp comp params \(json)")
        manager.makeAPICall(url: expenseComparisonUrl, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            print("Accounts exp comp result \(data)")
            do {
                self.expCompare = try JSONDecoder().decode([ExpenseComparison].self, from: data!)
                self.expCompareObj = self.expCompare[0].data
                self.filteredItems = self.expCompare[0].data
                self.totalSal = self.expCompareObj.reduce(0, { $0 + Double($1.salary!)! })
                self.totalExp = self.expCompareObj.reduce(0, { $0 + Double($1.otherespenses!)! })
                self.totalSale = self.expCompareObj.reduce(0, { $0 + Double($1.sale!)! })
                self.showBranchwise = true
                self.noOfColumns = 4
                self.customDivLayout.itemAttributes = []
                self.customDivLayout.numberOfColumns = self.noOfColumns
                self.CollectionView.reloadData()
                self.CollectionView.collectionViewLayout.invalidateLayout()
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
    
    //Temp API for Ledgerwise Comparison...
    func apiGetPranchwiseComp(){
        
        let json: [String: Any] = ["CIN":UserDefaults.standard.value(forKey: "userCIN") as! String,"Category":UserDefaults.standard.value(forKey: "userCategory") as! String,"ClientSecret":"ClientSecret","BranchId":"13","fromdate":dateFrom,"todate":dateTo, "Type":"2" ]
        
        let manager =  DataManager.shared
        print("Expense Header Params : \(json)");
        manager.makeAPICall(url: partywiseApiUrl, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            do {
                self.partwiseComp = try JSONDecoder().decode([LedgerwiseExpense].self, from: data!)
                self.partwiseCompObj  = self.partwiseComp[0].data
                self.total = self.partwiseCompObj.reduce(0, { $0 + Double($1.amount!)! })
                self.showBranchwise = false
                self.noOfColumns = 2
                self.customDivLayout.itemAttributes = []
                self.customDivLayout.numberOfColumns = self.noOfColumns
                self.CollectionView.reloadData()
                self.CollectionView.collectionViewLayout.invalidateLayout()
                //self.noDataView.hideView(view: self.noDataView)
                ViewControllerUtils.sharedInstance.removeLoader()
            } catch let errorData {
                print(errorData.localizedDescription)
                ViewControllerUtils.sharedInstance.removeLoader()
                //self.noDataView.showView(view: self.noDataView, from: "NDA")
            }
        }) { (Error) in
            print(Error?.localizedDescription as Any)
            ViewControllerUtils.sharedInstance.removeLoader()
            //self.noDataView.showView(view: self.noDataView, from: "NDA")
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
    
}
