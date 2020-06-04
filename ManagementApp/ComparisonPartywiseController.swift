//
//  ComparisonPartywiseController.swift
//  ManagementApp
//
//  Created by Goldmedal on 31/05/19.
//  Copyright © 2019 Goldmedal. All rights reserved.
//

import UIKit

class ComparisonPartywiseController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, PopupDateDelegate {
    
    //Outlets...
    @IBOutlet weak var CollectionView: UICollectionView!
    @IBOutlet weak var noDataView: NoDataView!
    @IBOutlet weak var backButton: UIImageView!
    @IBOutlet weak var sort: UIImageView!
    
    //Declarations...
    var comparisonData = [PartywiseComparison]()
    var comparisonDataObj = [PartywiseComparisonObj]()
    var filterCompObj = [PartywiseComparisonObj]()
    
    var statewiseChild = [StatewiseChild]()
    var statewiseObj = [StatewiseChildObj]()
    var filterStateObj = [StatewiseChildObj]()
    
    var distWiseCompare = [DistWiseCompare]()
    var distWiseCompareObj = [DistWiseCompareObj]()
    var filterDistObj = [DistWiseCompareObj]()
    
    var cellContentIdentifier = "\(CollectionViewCell.self)"
    var apiPartyWiseComparison = ""
    var apiStateWiseComparison = ""
    var apiDistWiseComparison = ""
    var dataToReceive = [BranchProgressObj]()
    var dataForStateApi = [StatewiseObj]()
    var totalCurrSale = ["currSale":0.0,"lastSale":0.0,"yearBeforeLast":0.0]
    var showState = false
    var showDist = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        apiPartyWiseComparison = "https://api.goldmedalindia.in/api/GetBranchwiseSalesCompareChild"
        apiStateWiseComparison = "https://api.goldmedalindia.in/api/getStatewiseSaleComparechild"
        apiDistWiseComparison = "https://api.goldmedalindia.in/api/GetDistrictwiseSalesCompare"
        self.noDataView.showView(view: self.noDataView, from: "LOADER")
        if showState && !showDist{
            apiGetStateComparison()
        }else if !showState && showDist{
            apiGetDistComp()
        }else{
            apiGetComparison()
        }
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(backClicked(tapGestureRecognizer:)))
        backButton.isUserInteractionEnabled = true
        backButton.addGestureRecognizer(tapGestureRecognizer)
        //Sort
        let tapSortRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapSortRecognizer:)))
        sort.isUserInteractionEnabled = true
        sort.addGestureRecognizer(tapSortRecognizer)
//        navigationController?.interactivePopGestureRecognizer?.delegate = nil
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        //navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    
    @objc func backClicked(tapGestureRecognizer: UITapGestureRecognizer)
    {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func imageTapped(tapSortRecognizer: UITapGestureRecognizer)
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
        if showState && !showDist {
            switch position {
            case 0:
                self.filterStateObj = self.statewiseObj.sorted{($0.name)!.localizedCaseInsensitiveCompare($1.name!) == .orderedAscending}
            case 1:
                self.filterStateObj = self.statewiseObj.sorted{($0.name)!.localizedCaseInsensitiveCompare($1.name!) == .orderedDescending}
            case 2:
                self.filterStateObj = self.statewiseObj.sorted(by: {Double($0.currentyearsale!)! < Double($1.currentyearsale!)!})
            case 3:
                self.filterStateObj = self.statewiseObj.sorted(by: {Double($0.currentyearsale!)! > Double($1.currentyearsale!)!})
            default:
                break
            }
        }else if !showState && showDist{
            switch position {
            case 0:
                self.filterDistObj = self.distWiseCompareObj.sorted{($0.distnm)!.localizedCaseInsensitiveCompare($1.distnm!) == .orderedAscending}
            case 1:
                self.filterDistObj = self.distWiseCompareObj.sorted{($0.distnm)!.localizedCaseInsensitiveCompare($1.distnm!) == .orderedDescending}
            case 2:
                self.filterDistObj = self.distWiseCompareObj.sorted(by: {Double($0.currentyearsale!)! < Double($1.currentyearsale!)!})
            case 3:
                self.filterDistObj = self.distWiseCompareObj.sorted(by: {Double($0.currentyearsale!)! > Double($1.currentyearsale!)!})
            default:
                break
            }
        }else{
            switch position {
            case 0:
                self.filterCompObj = self.comparisonDataObj.sorted{($0.name)!.localizedCaseInsensitiveCompare($1.name!) == .orderedAscending}
            case 1:
                self.filterCompObj = self.comparisonDataObj.sorted{($0.name)!.localizedCaseInsensitiveCompare($1.name!) == .orderedDescending}
            case 2:
                self.filterCompObj = self.comparisonDataObj.sorted(by: {Double($0.currentyearsale!)! < Double($1.currentyearsale!)!})
            case 3:
                self.filterCompObj = self.comparisonDataObj.sorted(by: {Double($0.currentyearsale!)! > Double($1.currentyearsale!)!})
            default:
                break
            }
        }
        self.CollectionView.reloadData()
        self.CollectionView.collectionViewLayout.invalidateLayout()
    }
    
    //COLLECTIONVIEW RELATED...
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if showState && !showDist{
            return filterStateObj.count + 2
        }else if !showState && showDist{
            return filterDistObj.count + 2
        }else{
            return filterCompObj.count + 2
        }
        
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = CollectionView.dequeueReusableCell(withReuseIdentifier: cellContentIdentifier,
                                                      for: indexPath) as! CollectionViewCell
        cell.layer.borderWidth = 1
        cell.layer.borderColor = UIColor.white.cgColor
        if showState && !showDist {
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
                    cell.contentLabel.text = "CY Sale 20-21"
                    cell.contentLabel.textColor = UIColor.black
                case 2:
                    cell.contentLabel.text = "LY Sale 19-20"
                case 3:
                    cell.contentLabel.text = "2018-2019"
                    cell.contentLabel.textColor = UIColor.black
                default:
                    break
                }
                //cell.backgroundColor = UIColor.lightGray
            }else if indexPath.section == filterStateObj.count + 1{
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
                    cell.contentLabel.text = Utility.formatRupee(amount: Double(totalCurrSale["currSale"]! ))
                    cell.contentLabel.textColor = UIColor.black
                case 2:
                    cell.contentLabel.text = Utility.formatRupee(amount: Double(totalCurrSale["lastSale"]! ))
                case 3:
                    cell.contentLabel.text = Utility.formatRupee(amount: Double(totalCurrSale["yearBeforeLast"]! ))
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
                    if filterStateObj[indexPath.section - 1].partystatus != "Active"{
                        cell.contentLabel.textColor = UIColor(named: "ColorRed")
                    }else{
                        cell.contentLabel.textColor = UIColor.black
                    }
                    cell.contentLabel.text = filterStateObj[indexPath.section - 1].name
                case 1:
                    cell.contentLabel.textColor = UIColor.black
                    let currentYear = Double(filterStateObj[indexPath.section - 1].currentyearsale!)!
                    let prevYear = Double(filterStateObj[indexPath.section - 1].previousyearsale!)!
                    let temp = ((currentYear - prevYear)/prevYear)*100
                    if let currentyearsale = Double(filterStateObj[indexPath.section - 1].currentyearsale!)
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
                    cell.contentLabel.textColor = UIColor.black
                    let currentYear = Double(filterStateObj[indexPath.section - 1].previousyearsale!)
                    let prevYear = Double(filterStateObj[indexPath.section - 1].previoustwoyearsale!)
                    let temp = ((currentYear! - prevYear!)/prevYear!)*100
                    if let previousyearsale = Double(filterStateObj[indexPath.section - 1].previousyearsale!)
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
                    if let previoustwoyearsale = Double(filterStateObj[indexPath.section - 1].previoustwoyearsale!)
                    {
                        cell.contentLabel.text = Utility.formatRupee(amount: Double(previoustwoyearsale ))
                        cell.contentLabel.textColor = UIColor.black
                    }
                default:
                    break
                }
                //cell.backgroundColor = UIColor.groupTableViewBackground
            }
            
        }
        else if !showState && showDist{
            
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
                    cell.contentLabel.text = "CY Sale 20-21"
                    cell.contentLabel.textColor = UIColor.black
                case 2:
                    cell.contentLabel.text = "LY Sale 19-20"
                case 3:
                    cell.contentLabel.text = "2018-2019"
                    cell.contentLabel.textColor = UIColor.black
                default:
                    break
                }
                //cell.backgroundColor = UIColor.lightGray
            }else if indexPath.section == filterDistObj.count + 1{
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
                    cell.contentLabel.text = Utility.formatRupee(amount: Double(totalCurrSale["currSale"]! ))
                    cell.contentLabel.textColor = UIColor.black
                case 2:
                    cell.contentLabel.text = Utility.formatRupee(amount: Double(totalCurrSale["lastSale"]! ))
                case 3:
                    cell.contentLabel.text = Utility.formatRupee(amount: Double(totalCurrSale["yearBeforeLast"]! ))
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
                    cell.contentLabel.text = filterDistObj[indexPath.section - 1].distnm
                case 1:
                    cell.contentLabel.textColor = UIColor.black
                    let currentYear = Double(filterDistObj[indexPath.section - 1].currentyearsale!)!
                    let prevYear = Double(filterDistObj[indexPath.section - 1].previousyearsale!)!
                    let temp = ((currentYear - prevYear)/prevYear)*100
                    if let currentyearsale = Double(filterDistObj[indexPath.section - 1].currentyearsale!)
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
                    cell.contentLabel.textColor = UIColor.black
                    let currentYear = Double(filterDistObj[indexPath.section - 1].previousyearsale!)
                    let prevYear = Double(filterDistObj[indexPath.section - 1].previoutwoyearsale!)
                    let temp = ((currentYear! - prevYear!)/prevYear!)*100
                    if let previousyearsale = Double(filterDistObj[indexPath.section - 1].previousyearsale!)
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
                    if let previoustwoyearsale = Double(filterDistObj[indexPath.section - 1].previoutwoyearsale!)
                    {
                        cell.contentLabel.text = Utility.formatRupee(amount: Double(previoustwoyearsale ))
                        cell.contentLabel.textColor = UIColor.black
                    }
                default:
                    break
                }
                //cell.backgroundColor = UIColor.groupTableViewBackground
            }
            
        }
        else{
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
                    cell.contentLabel.text = "CY Sale 20-21"
                    cell.contentLabel.textColor = UIColor.black
                case 2:
                    cell.contentLabel.text = "LY Sale 19-20"
                case 3:
                    cell.contentLabel.text = "2018-2019"
                    cell.contentLabel.textColor = UIColor.black
                default:
                    break
                }
                //cell.backgroundColor = UIColor.lightGray
            }else if indexPath.section == filterCompObj.count + 1{
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
                    cell.contentLabel.text = Utility.formatRupee(amount: Double(totalCurrSale["currSale"]! ))
                    cell.contentLabel.textColor = UIColor.black
                case 2:
                    cell.contentLabel.text = Utility.formatRupee(amount: Double(totalCurrSale["lastSale"]! ))
                case 3:
                    cell.contentLabel.text = Utility.formatRupee(amount: Double(totalCurrSale["yearBeforeLast"]! ))
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
                    if filterCompObj[indexPath.section - 1].partystatus != "Active"{
                        cell.contentLabel.textColor = UIColor(named: "ColorRed")
                    }else{
                        cell.contentLabel.textColor = UIColor.black
                    }
                    cell.contentLabel.text = filterCompObj[indexPath.section - 1].name
                case 1:
                    cell.contentLabel.textColor = UIColor.black
                    let currentYear = Double(filterCompObj[indexPath.section - 1].currentyearsale!)!
                    let prevYear = Double(filterCompObj[indexPath.section - 1].previousyearsale!)!
                    let temp = ((currentYear - prevYear)/prevYear)*100
                    if let currentyearsale = Double(filterCompObj[indexPath.section - 1].currentyearsale!)
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
                    cell.contentLabel.textColor = UIColor.black
                    let currentYear = Double(filterCompObj[indexPath.section - 1].previousyearsale!)
                    let prevYear = Double(filterCompObj[indexPath.section - 1].previoustwoyearsale!)
                    let temp = ((currentYear! - prevYear!)/prevYear!)*100
                    if let previousyearsale = Double(filterCompObj[indexPath.section - 1].previousyearsale!)
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
                    if let previoustwoyearsale = Double(filterCompObj[indexPath.section - 1].previoustwoyearsale!)
                    {
                        cell.contentLabel.text = Utility.formatRupee(amount: Double(previoustwoyearsale ))
                        cell.contentLabel.textColor = UIColor.black
                    }
                default:
                    break
                }
                //cell.backgroundColor = UIColor.groupTableViewBackground
            }}
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if showDist{
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let newViewController = storyBoard.instantiateViewController(withIdentifier: "PartyDistWise") as! DistWiseChildController
            newViewController.dataToReceive = [filterDistObj[indexPath.section-1]]
            self.present(newViewController, animated: true, completion: nil)
        }else{
            if showState{
                if indexPath.section == filterStateObj.count + 1 {
                    return
                }
            }else{
                if indexPath.section == filterCompObj.count + 1 {
                    return
                }
            }
            if indexPath.section > 0 {
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                if showState{
                    appDelegate.sendCin = filterStateObj[indexPath.section-1].cin!
                }else{
                    appDelegate.sendCin = filterCompObj[indexPath.section-1].cin!
                }
            }
        }
    }
    
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if showDist {
            return false
        }
        if let index = CollectionView.indexPathsForSelectedItems?.first{
            if((index.section) > 0){
                return true
            }else{
                return false
            }
        }else{
            return false
        }
    }
    
    
    //API FUNCTION...
    func apiGetComparison(){
        
        let json: [String: Any] = ["CIN":UserDefaults.standard.value(forKey: "userCIN") as! String,"Category":UserDefaults.standard.value(forKey: "userCategory") as! String,"ClientSecret":"ohdashfl","branchid":dataToReceive[0].branchid]
        
        let manager =  DataManager.shared
        
        manager.makeAPICall(url: apiPartyWiseComparison, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            do {
                print("Params : \(json)")
                self.comparisonData = try JSONDecoder().decode([PartywiseComparison].self, from: data!)
                self.comparisonDataObj = self.comparisonData[0].data
                self.filterCompObj = self.comparisonData[0].data
                self.totalCurrSale["currSale"] = self.comparisonDataObj.reduce(0, { $0 + Double($1.currentyearsale!)! })
                self.totalCurrSale["lastSale"] = self.comparisonDataObj.reduce(0, { $0 + Double($1.previousyearsale!)! })
                self.totalCurrSale["yearBeforeLast"] = self.comparisonDataObj.reduce(0, { $0 + Double($1.previoustwoyearsale!)! })
                self.CollectionView.reloadData()
                self.CollectionView.collectionViewLayout.invalidateLayout()
                self.noDataView.hideView(view: self.noDataView)
            } catch let errorData {
                print(errorData.localizedDescription)
                self.noDataView.hideView(view: self.noDataView)
            }
        }) { (Error) in
            print(Error?.localizedDescription as Any)
            self.noDataView.hideView(view: self.noDataView)
        }
        
    }
    
    func apiGetStateComparison(){
        
        let json: [String: Any] = ["CIN":"sa@sa.com","Category":"Management","ClientSecret":"ohdashfl","stateid":dataForStateApi[0].stateid]
        
        let manager =  DataManager.shared
        
        manager.makeAPICall(url: apiStateWiseComparison, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            do {
                self.statewiseChild = try JSONDecoder().decode([StatewiseChild].self, from: data!)
                self.statewiseObj = self.statewiseChild[0].data
                self.filterStateObj = self.statewiseChild[0].data
                self.totalCurrSale["currSale"] = self.statewiseObj.reduce(0, { $0 + Double($1.currentyearsale!)! })
                self.totalCurrSale["lastSale"] = self.statewiseObj.reduce(0, { $0 + Double($1.previousyearsale!)! })
                self.totalCurrSale["yearBeforeLast"] = self.statewiseObj.reduce(0, { $0 + Double($1.previoustwoyearsale!)! })
                self.CollectionView.reloadData()
                self.CollectionView.collectionViewLayout.invalidateLayout()
                self.noDataView.hideView(view: self.noDataView)
            } catch let errorData {
                print(errorData.localizedDescription)
                self.noDataView.hideView(view: self.noDataView)
            }
        }) { (Error) in
            print(Error?.localizedDescription as Any)
            self.noDataView.hideView(view: self.noDataView)
        }
        
    }
    
    func apiGetDistComp(){
        
        let json: [String: Any] = ["CIN":"sa@sa.com","Category":"Management","ClientSecret":"ohdashfl","stateid":dataForStateApi[0].stateid]
        
        let manager =  DataManager.shared
        
        manager.makeAPICall(url: apiDistWiseComparison, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            do {
                self.distWiseCompare = try JSONDecoder().decode([DistWiseCompare].self, from: data!)
                self.distWiseCompareObj = self.distWiseCompare[0].data
                self.filterDistObj = self.distWiseCompare[0].data
                self.totalCurrSale["currSale"] = self.distWiseCompareObj.reduce(0, { $0 + Double($1.currentyearsale!)! })
                self.totalCurrSale["lastSale"] = self.distWiseCompareObj.reduce(0, { $0 + Double($1.previousyearsale!)! })
                self.totalCurrSale["yearBeforeLast"] = self.distWiseCompareObj.reduce(0, { $0 + Double($1.previoutwoyearsale!)! })
                self.CollectionView.reloadData()
                self.CollectionView.collectionViewLayout.invalidateLayout()
                self.noDataView.hideView(view: self.noDataView)
            } catch let errorData {
                print(errorData.localizedDescription)
                self.noDataView.hideView(view: self.noDataView)
            }
        }) { (Error) in
            print(Error?.localizedDescription as Any)
            self.noDataView.hideView(view: self.noDataView)
        }
        
    }
    
}
