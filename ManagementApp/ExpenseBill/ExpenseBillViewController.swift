//
//  ExpenseBillViewController.swift
//  ManagementApp
//
//  Created by Goldmedal on 13/03/20.
//  Copyright © 2020 Goldmedal. All rights reserved.
//

import UIKit

class ExpenseBillViewController: BaseViewController, UICollectionViewDataSource, UICollectionViewDelegate  {
    
    //Outlets...
    @IBOutlet weak var CollectionView: UICollectionView!
    @IBOutlet weak var noDataView: NoDataView!
    @IBOutlet weak var sort: UIBarButtonItem!
    
    //Declarations...
    var cellContentIdentifier = "\(CollectionViewCell.self)"
    var expensebillApiUrl = ""
    var expenseBill = [ExpenseBill]()
    var expenseBillData = [ExpenseBillData]()
    var expenseBillObj = [ExpenseBillObj]()
    var filteredItems = [ExpenseBillObj]()
    var total = 0.0
    var (dateFrom,dateTo) = Utility.yearDate()
    var checkedArray = [String]()
    var disputeArray = [String]()
    var index = 0
    var count = 20
    var isMore = true
    var supplierName = ""
    var ledgerName = ""
    var branchName = ""
    var popupSelected = 0
    var sortCalled = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addSlideMenuButton()
        self.noDataView.hideView(view: self.noDataView)
        //UserDefaults.standard.removeObject(forKey: "Checked")
        //UserDefaults.standard.removeObject(forKey: "Disputed")
        if UserDefaults.standard.object(forKey: "Checked") != nil{
            checkedArray = UserDefaults.standard.object(forKey: "Checked") as! [String]
        }
        if UserDefaults.standard.object(forKey: "Disputed") != nil{
            disputeArray = UserDefaults.standard.object(forKey: "Disputed") as! [String]
        }
        print("Checked Array \(checkedArray)")
        print("Disp Array \(disputeArray)")
        expensebillApiUrl = "https://test2.goldmedalindia.in/api/getallExpenseChildAllSubChild"
        ViewControllerUtils.sharedInstance.showLoader()
        apiGetExpBill()
        
    }
    
    //SORT....
    @IBAction func clickedSort(_ sender: UIBarButtonItem) {
        let sb = UIStoryboard(name: "Sorting", bundle: nil)
        let popup = sb.instantiateInitialViewController()! as! SortViewController
        popup.modalPresentationStyle = .overFullScreen
        popup.delegate = self
        popup.showPicker = 1
        popup.pickerDataSource = ["View All","Checked","Disputed","Amount High to Low"]
        self.present(popup, animated: true)
    }
    
    func sortBy(value: String, position: Int) {
        switch position {
        case 1:
            filteredItems.removeAll()
            for index in 0...(expenseBillObj.count-1) {
                if checkedArray.contains(String(expenseBillObj[index].slno!)) == true{
                    filteredItems.append(expenseBillObj[index])
                }
            }
            sortCalled = true
            self.CollectionView.reloadData()
            self.CollectionView.collectionViewLayout.invalidateLayout()
        case 2:
            filteredItems.removeAll()
            for index in 0...(expenseBillObj.count-1) {
                if disputeArray.contains(String(expenseBillObj[index].slno!)) == true{
                    filteredItems.append(expenseBillObj[index])
                }
            }
            sortCalled = true
            self.CollectionView.reloadData()
            self.CollectionView.collectionViewLayout.invalidateLayout()
        case 0:
            branchName = ""
            supplierName = ""
            ledgerName = ""
            ViewControllerUtils.sharedInstance.showLoader()
            filteredItems.removeAll()
            apiGetExpBill()
        case 3:
            self.filteredItems = self.expenseBillObj.sorted(by: {Double($0.amount!)! > Double($1.amount!)!})
            self.CollectionView.reloadData()
            self.CollectionView.collectionViewLayout.invalidateLayout()
        default:
            break
        }
    }
    
    //Collection View......
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        //if filteredItems.count == 1{
        return self.filteredItems.count + 1
        //        }else{
        //            return self.filteredItems.count
        //        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 12
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = CollectionView.dequeueReusableCell(withReuseIdentifier: cellContentIdentifier,
                                                      for: indexPath) as! CollectionViewCell
        cell.layer.borderWidth = 1
        cell.layer.borderColor = UIColor.white.cgColor
        
        if indexPath.section == 0 {
            cell.contentLabel.font = UIFont(name: "Roboto-Medium", size: 16)
            if #available(iOS 11.0, *) {
                cell.backgroundColor = UIColor.init(named: "Primary")
            } else {
                cell.backgroundColor = UIColor.gray
            }
            switch indexPath.row{
            case 0:
                cell.contentLabel.attributedText = setNormalText(value: "Check")
            case 1:
                cell.contentLabel.attributedText = setNormalText(value: "Dispute")
            case 4:
                cell.contentLabel.attributedText = setNormalText(value: "Branch Name")
            case 2:
                cell.contentLabel.attributedText = setNormalText(value: "Supplier Name")
            case 6:
                cell.contentLabel.attributedText = setNormalText(value: "Ledger Name")
            case 3:
                cell.contentLabel.attributedText = setNormalText(value: "Date")
            case 5:
                cell.contentLabel.attributedText = setNormalText(value: "Amount")
            case 7:
                cell.contentLabel.attributedText = setNormalText(value: "Narration")
            case 8:
                cell.contentLabel.attributedText = setNormalText(value: "Payment Mode")
            case 9:
                cell.contentLabel.attributedText = setNormalText(value: "Type")
            case 10:
                cell.contentLabel.attributedText = setNormalText(value: "Invoice No.")
            case 11:
                cell.contentLabel.attributedText = setNormalText(value: "Details")
                
            default:
                break
            }
            //cell.backgroundColor = UIColor.lightGray
        }
            //        else if indexPath.section == filteredItems.count+1{
            //            cell.contentLabel.font = UIFont(name: "Roboto-Medium", size: 16)
            //            if #available(iOS 11.0, *) {
            //                cell.backgroundColor = UIColor.init(named: "Primary")
            //            } else {
            //                cell.backgroundColor = UIColor.gray
            //            }
            //            switch indexPath.row{
            //            case 0:
            //                cell.contentLabel.attributedText = setNormalText(value: "Check")
            //            case 1:
            //                cell.contentLabel.attributedText = setNormalText(value: "Dispute")
            //            case 2:
            //                cell.contentLabel.attributedText = setNormalText(value: "Branch Name")
            //            case 3:
            //                cell.contentLabel.attributedText = setNormalText(value: "Supplier Name")
            //            case 4:
            //                cell.contentLabel.attributedText = setNormalText(value: "Ledger Name")
            //            case 5:
            //                cell.contentLabel.attributedText = setNormalText(value: "Date")
            //            case 6:
            //                cell.contentLabel.attributedText = setNormalText(value: Utility.formatRupee(amount: Double(total)))
            //            case 7:
            //                cell.contentLabel.attributedText = setNormalText(value: "Narration")
            //            case 8:
            //                cell.contentLabel.attributedText = setNormalText(value: "Payment Mode")
            //            case 9:
            //                cell.contentLabel.attributedText = setNormalText(value: "Type")
            //            case 10:
            //                cell.contentLabel.attributedText = setNormalText(value: "Invoice No.")
            //            case 11:
            //                cell.contentLabel.attributedText = setNormalText(value: "Details")
            //            default:
            //                break
            //            }
            //        }
        else {
            cell.contentLabel.font = UIFont(name: "Roboto-Regular", size: 14)
            if #available(iOS 11.0, *) {
                cell.backgroundColor = UIColor.init(named: "primaryLight")
            } else {
                cell.backgroundColor = UIColor.lightGray
            }
            switch indexPath.row{
            case 0:
                if checkedArray.contains(String(filteredItems[indexPath.section-1].slno!)){
                    cell.backgroundColor = UIColor.init(named: "ColorOlive")
                    cell.contentLabel.attributedText = setNormalText(value: "Checked")
                }else{
                    cell.contentLabel.attributedText = setCheckText(value: "Check")
                } 
            case 1:
                if disputeArray.contains(String(filteredItems[indexPath.section-1].slno!)){
                    cell.backgroundColor = UIColor.init(named: "ColorRed")
                    cell.contentLabel.textColor = UIColor.black
                    cell.contentLabel.attributedText = setNormalText(value: "Disputed")
                }else{
                    cell.contentLabel.attributedText = setDisputeText(value: "Dispute")
                }
            case 4:
                cell.contentLabel.attributedText = setNormalText(value: filteredItems[indexPath.section-1].branch!)
            case 2:
                cell.contentLabel.attributedText = setNormalText(value: filteredItems[indexPath.section-1].supplierName!)
            case 6:
                cell.contentLabel.attributedText = setNormalText(value: filteredItems[indexPath.section-1].ledgerName!)
            case 3:
                var splitDate = self.filteredItems[indexPath.section-1].date!.split{$0 == " "}.map(String.init)
                var indianFormatDate = splitDate[0].split{$0 == "/"}.map(String.init)
                cell.contentLabel.attributedText = setNormalText(value: "\(indianFormatDate[1])/\(indianFormatDate[0])/\(indianFormatDate[2])")
            case 5:
                let currentYear = Double(filteredItems[indexPath.section - 1].amount!)!
                let prevYear = Double(total)
                let temp = (currentYear*100)/prevYear
                cell.contentLabel.attributedText = calculatePercentage(currentYear: currentYear, prevYear: prevYear, temp: temp)
            case 7:
                cell.contentLabel.attributedText = setNormalText(value: filteredItems[indexPath.section-1].narration!)
            case 8:
                cell.contentLabel.attributedText = setNormalText(value: filteredItems[indexPath.section-1].paymentmode!)
            case 9:
                cell.contentLabel.attributedText = setNormalText(value: filteredItems[indexPath.section-1].type!)
            case 10:
                cell.contentLabel.attributedText = setNormalText(value: filteredItems[indexPath.section-1].voucherNo!)
            case 11:
                let attributedString = NSAttributedString(string: NSLocalizedString("View Invoice", comment: ""), attributes:[
                    NSAttributedString.Key.foregroundColor : UIColor(named: "ColorBlue") as Any,
                    NSAttributedString.Key.underlineStyle:1.0
                    ])
                cell.contentLabel.attributedText = attributedString
            default:
                break
            }
            //cell.backgroundColor = UIColor.groupTableViewBackground
        }
        return cell
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        //print("Index \(indexPath.section) and isMore \((isMore)) count \(index)")
        if !sortCalled{
            if indexPath.section == (filteredItems.count-1) && isMore {
                self.index = self.index + 20
                apiGetExpBill()
                return
            }
        }
    }
    
    //    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
    //        if indexPath.section == (filteredItems.count-1) && isMore{
    //            print("Index \(indexPath.section) and isMore \((isMore)) count \(filteredItems.count)")
    //            if isMore{
    //                apiGetExpBill()
    //            }
    //        }
    //    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if indexPath.section == 0{
            if sortCalled == true{
                filteredItems.removeAll()
               sortCalled = false
            }
            
            if(indexPath.row == 4){
                popupSelected = 1 
                let sb = UIStoryboard(name: "Search", bundle: nil)
                let popup = sb.instantiateInitialViewController()! as! SearchViewController
                popup.modalPresentationStyle = .overFullScreen
                popup.delegate = self
                popup.from = "branch"
                self.present(popup, animated: true)
            }else if(indexPath.row == 2){
                popupSelected = 2
                let sb = UIStoryboard(name: "Search", bundle: nil)
                let popup = sb.instantiateInitialViewController()! as! SearchViewController
                popup.modalPresentationStyle = .overFullScreen
                popup.delegate = self
                popup.from = "supplier"
                self.present(popup, animated: true)
            }else if(indexPath.row == 6){
                popupSelected = 3
                let sb = UIStoryboard(name: "Search", bundle: nil)
                let popup = sb.instantiateInitialViewController()! as! SearchViewController
                popup.modalPresentationStyle = .overFullScreen
                popup.delegate = self
                popup.from = "ledger"
                self.present(popup, animated: true)
            }
        }else if indexPath.section != 0{
//            if sortCalled == true{
//                filteredItems.removeAll()
//                sortCalled = false
//            }
            //print("Selected Voucher no : \(filteredItems[indexPath.section-1].slno!)")
            if indexPath.row == 0{
                if disputeArray.count > 0 &&  disputeArray.contains(String(filteredItems[indexPath.section-1].slno!)){
                    let temp = disputeArray.firstIndex(of: String(filteredItems[indexPath.section-1].slno!))
                    disputeArray.remove(at: temp!)
                    print("Disp \(disputeArray)")
                    UserDefaults.standard.set(disputeArray, forKey: "Disputed")
                }
                if checkedArray.count > 0 &&   checkedArray.contains(String(filteredItems[indexPath.section-1].slno!)){
                    let temp = checkedArray.firstIndex(of: String(filteredItems[indexPath.section-1].slno!))
                    checkedArray.remove(at: temp!)
                    print("Che \(checkedArray)")
                    UserDefaults.standard.removeObject(forKey: "Checked")
                }else{
                    checkedArray.append(String(filteredItems[indexPath.section-1].slno!))
                }
                UserDefaults.standard.set(checkedArray, forKey: "Checked")
                self.CollectionView.reloadData()
                self.CollectionView.collectionViewLayout.invalidateLayout()
            }else if indexPath.row == 1{
                if checkedArray.count > 0 &&    checkedArray.contains(String(filteredItems[indexPath.section-1].slno!)){
                    let temp = checkedArray.firstIndex(of: String(filteredItems[indexPath.section-1].slno!))
                    checkedArray.remove(at: temp!)
                    print("Che \(checkedArray)")
                    UserDefaults.standard.set(checkedArray, forKey: "Checked")
                }
                if disputeArray.count > 0 &&  disputeArray.contains(String(filteredItems[indexPath.section-1].slno!)){
                    let temp = disputeArray.firstIndex(of: String(filteredItems[indexPath.section-1].slno!))
                    disputeArray.remove(at: temp!)
                    print("Disp \(disputeArray)")
                    UserDefaults.standard.removeObject(forKey: "Checked")
                }else{
                    disputeArray.append(String(filteredItems[indexPath.section-1].slno!))
                }
                UserDefaults.standard.set(disputeArray, forKey: "Disputed")
                self.CollectionView.reloadData()
                self.CollectionView.collectionViewLayout.invalidateLayout()
            }else if indexPath.row == 11{
                performSegue(withIdentifier: "expenseBillSegue", sender: self)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "expenseBillSegue") {
            if let destination = segue.destination as? viewPDFController,
                let index = CollectionView.indexPathsForSelectedItems?.first{
                if index.section > 0 && filteredItems[index.section-1].link != ""{
                    var urlArray = filteredItems[index.section-1].link!.split{$0 == ","}.map(String.init)
                    destination.webvwUrl = urlArray[urlArray.count - 1]
                }
                else{
                    return
                }
            }
        }
        
    }
    
//    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
//        if let index = CollectionView.indexPathsForSelectedItems?.first{
//            if((index.section) > 0){
//                if index.section == self.filteredItems.count + 1{
//                    return false
//                }else{
//                    return true}
//            }else{
//                return false
//            }
//        }else{
//            return false
//        }
//    }
    
    func setNormalText(value: String) -> NSAttributedString{
        let attributedString = NSAttributedString(string: NSLocalizedString(value, comment: ""), attributes:[
            NSAttributedString.Key.foregroundColor : UIColor.black
            ])
        return attributedString
    }
    
    func setCheckText(value: String) -> NSAttributedString{
        let attributedString = NSAttributedString(string: value, attributes:[
            NSAttributedString.Key.foregroundColor : UIColor(named: "ColorGreen") as Any,
            NSAttributedString.Key.underlineStyle:1.0
            ])
        return attributedString
    }
    
    func setDisputeText(value: String) -> NSAttributedString{
        let attributedString = NSAttributedString(string: value, attributes:[
            NSAttributedString.Key.foregroundColor : UIColor(named: "ColorRed") as Any,
            NSAttributedString.Key.underlineStyle:1.0
            ])
        return attributedString
    }
    
    func showSearchValue(value: String) {
        
        if popupSelected == 1{
            if value == "ALL"{
                branchName = ""
                supplierName = ""
                ledgerName = ""
                index = 0
                expenseBillObj.removeAll()
                filteredItems.removeAll()
                ViewControllerUtils.sharedInstance.showLoader()
                apiGetExpBill()
                return
            }
            branchName = value
            supplierName = ""
            ledgerName = ""
        }else if popupSelected == 2{
            supplierName = value
            branchName = ""
            ledgerName = ""
        }else if popupSelected == 3{
            ledgerName = value
            branchName = ""
            supplierName = ""
        }
        index = 0
        expenseBillObj.removeAll()
        filteredItems.removeAll()
        ViewControllerUtils.sharedInstance.showLoader()
        apiGetExpBill()
    }
    
 
    
    //API CALL...
    func apiGetExpBill(){
        
        let json: [String: Any] = ["CIN":UserDefaults.standard.value(forKey: "userCIN") as! String,"Cat":UserDefaults.standard.value(forKey: "userCategory") as! String,"ClientSecret":"ClientSecret","fromdate":dateFrom,"todate":dateTo,"BranchName":branchName,"SupplierName":supplierName,"LedgerName":ledgerName,"Index":index,"Count":count]
        let manager =  DataManager.shared
        print("Params Sent : \(json)")
        manager.makeAPICall(url: expensebillApiUrl, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            
            do {
                self.expenseBill = try JSONDecoder().decode([ExpenseBill].self, from: data!)
                self.expenseBillData = self.expenseBill[0].data
                for data in 0...(self.expenseBillData[0].expenseChilddata.count-1) {
                    self.expenseBillObj.append(self.expenseBillData[0].expenseChilddata[data])
                    self.filteredItems.append(self.expenseBillData[0].expenseChilddata[data])
                }
                //self.expenseBillObj  = self.expenseBillData[0].expenseChilddata
                //self.filteredItems  = self.expenseBillData[0].expenseChilddata
                //self.total = self.filteredItems.reduce(0, { $0 + Double($1.amount!)! })
                self.isMore = self.expenseBillData[0].ismore!
                print("Data Count : \(self.filteredItems.count)")
                self.CollectionView.reloadData()
                self.CollectionView.collectionViewLayout.invalidateLayout()
                self.noDataView.hideView(view: self.noDataView)
                ViewControllerUtils.sharedInstance.removeLoader()
            } catch let errorData {
                print(errorData.localizedDescription)
                ViewControllerUtils.sharedInstance.removeLoader()
                self.noDataView.showView(view: self.noDataView, from: "NDA")
            }
        }) { (Error) in
            print(Error?.localizedDescription as Any)
            ViewControllerUtils.sharedInstance.removeLoader()
            self.noDataView.showView(view: self.noDataView, from: "NDA")
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
