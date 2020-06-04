//
//  MonthwiseViewController.swift
//  ManagementApp
//
//  Created by Goldmedal on 22/05/20.
//  Copyright © 2020 Goldmedal. All rights reserved.
//

import UIKit

class MonthwiseViewController: BaseViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    //Outlets...
    @IBOutlet weak var CollectionView: UICollectionView!
    @IBOutlet weak var lblPartyName: UIButton!
    @IBOutlet weak var lblDivName: UIButton!
    @IBOutlet weak var btnFromDate: UIButton!
    @IBOutlet weak var btnToDate: UIButton!
    
    //Declarations...
    var monthSummary = [MonthSummary]()
    var monthSummaryObj = [MonthSummaryObj]()
    var filteredItems = [MonthSummaryObj]()
    var cellContentIdentifier = "\(CollectionViewCell.self)"
    var apiMonthSummaryUrl = ""
    var searchData = [SearchVendor]()
    var supplierArray = [SearchVendorObj]()
    var tempSupplierArr = [SearchVendorObj]()
    var partyID = "4"
    var divId = "2"
    let currDate = Date()
    var dateFormatter = DateFormatter()
    var fromDate: Date?
    var toDate: Date?
    var strFromDate = ""
    var strToDate = ""
    var fromdate = "04/01/2020"
    var todate = "03/31/2021"
    var total = ["unit":0.0,"openb":0.0,"torder":0.0,"trec":0.0,"bal":0.0]
    var searchDiv = false

    override func viewDidLoad() {
        super.viewDidLoad()
        addSlideMenuButton()
        ViewControllerUtils.sharedInstance.showLoader()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        strToDate = dateFormatter.string(from: currDate)
        fromDate = dateFormatter.date(from: strFromDate)
        toDate = dateFormatter.date(from: strToDate)
        apiMonthSummaryUrl = "https://test2.goldmedalindia.in/api/getmonthwiseordersummary"
        apiMonthSummary()
        apiGetAllVendors()
    }
    
    //Button...
    @IBAction func searchParty(_ sender: Any) {
        let sb = UIStoryboard(name: "PartyStoryboard", bundle: nil)
        let popup = sb.instantiateInitialViewController()! as! PartySearchController
        popup.modalPresentationStyle = .overFullScreen
        popup.delegate = self
        popup.fromPage = "Vendors"
        popup.supplierArray = tempSupplierArr
        popup.tempSupplierArr = tempSupplierArr
        self.present(popup, animated: true)
    }
    
    @IBAction func searchDiv(_ sender: Any) {
        searchDiv = true
        let sb = UIStoryboard(name: "PartyStoryboard", bundle: nil)
        let popup = sb.instantiateInitialViewController()! as! PartySearchController
        popup.modalPresentationStyle = .overFullScreen
        popup.delegate = self
        popup.multipleSelector = true
        popup.fromPage = "Division"
        self.present(popup, animated: true)
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
    
    //Popup Func...
    func showParty(value: String,cin: String) {
        if searchDiv{
            searchDiv = false
            divId = value
        }else{
            lblPartyName.setTitle("  \(value)", for: .normal)
            partyID = cin
            ViewControllerUtils.sharedInstance.showLoader()
        }
        apiMonthSummary()
    }
    
    func updateDate(value: String, date: Date) {
        if btnFromDate.isSelected {
            btnFromDate.setTitle(value, for: .normal)
            btnFromDate.isSelected = false
            fromDate = date
            strFromDate = Utility.formattedDateFromString(dateString: value, withFormat: "MM/dd/yyyy")!
            fromdate = strFromDate
            //dailyfromdate = fromdate
        }
        else
        {
            btnToDate.setTitle(value, for: .normal)
            btnToDate.isSelected = false
            toDate = date
            strToDate = Utility.formattedDateFromString(dateString: value, withFormat: "MM/dd/yyyy")!
            todate = strToDate
            //dailytodate = todate
        }
        
        apiMonthSummary()
    }
    
    //CollectionView Functions...
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return filteredItems.count + 2
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 7
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = CollectionView.dequeueReusableCell(withReuseIdentifier: cellContentIdentifier,
                                                      for: indexPath) as! CollectionViewCell
        cell.layer.borderWidth = 1
        cell.layer.borderColor = UIColor.white.cgColor
        //Header of CollectionView...
        
        if indexPath.section == 0 {
            cell.contentLabel.font = UIFont(name: "Roboto-Medium", size: 16)
            if #available(iOS 11.0, *) {
                cell.backgroundColor = UIColor.init(named: "Primary")
            } else {
                cell.backgroundColor = UIColor.gray
            }
            switch indexPath.row{
            case 0:
                cell.contentLabel.text = "Item Code"
            case 1:
                cell.contentLabel.text = "Item Name"
            case 2:
                cell.contentLabel.text = "Units"
            case 3:
                cell.contentLabel.text = "Open. Bal"
            case 4:
                cell.contentLabel.text = "T. Order"
            case 5:
                cell.contentLabel.text = "T.Recieved"
            case 6:
                cell.contentLabel.text = "Bal"
            default:
                break
            }
        }else if indexPath.section == filteredItems.count + 1{
            cell.contentLabel.font = UIFont(name: "Roboto-Medium", size: 16)
            if #available(iOS 11.0, *) {
                cell.backgroundColor = UIColor.init(named: "Primary")
            } else {
                cell.backgroundColor = UIColor.gray
            }
            switch indexPath.row{
            case 0:
                cell.contentLabel.text = " "
            case 1:
                cell.contentLabel.text = "SUM"
            case 2:
                cell.contentLabel.text = "UNIT"
            case 3:
                cell.contentLabel.text = Utility.formatRupee(amount: Double(total["openb"] ?? 0.0))
            case 4:
                cell.contentLabel.text = Utility.formatRupee(amount: Double(total["torder"] ?? 0.0))
            case 5:
                cell.contentLabel.text = Utility.formatRupee(amount: Double(total["trec"] ?? 0.0))
            case 6:
                cell.contentLabel.text = Utility.formatRupee(amount: Double(total["bal"] ?? 0.0))
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
                cell.contentLabel.text = filteredItems[indexPath.section-1].itemName
            case 1:
                cell.contentLabel.text = filteredItems[indexPath.section-1].itemCode
            case 2:
                cell.contentLabel.text = filteredItems[indexPath.section-1].unit
            case 3:
                if let openingBal = filteredItems[indexPath.section - 1].openingBal
                {
                    cell.contentLabel.text = Utility.formatRupee(amount: Double(openingBal )!)
                }
            case 4:
                if let totalOrder = filteredItems[indexPath.section - 1].totalOrder
                {
                    cell.contentLabel.text = Utility.formatRupee(amount: Double(totalOrder )!)
                }
            case 5:
                if let totalReceived = filteredItems[indexPath.section - 1].totalReceived
                {
                    cell.contentLabel.text = Utility.formatRupee(amount: Double(totalReceived )!)
                }
            case 6:
                if let bal = filteredItems[indexPath.section - 1].bal
                {
                    cell.contentLabel.text = Utility.formatRupee(amount: Double(bal )!)
                }
            default:
                break
            }
        }
        return cell
    }
    
    //API Functions
    func apiMonthSummary(){
        
        let json: [String: Any] = ["CIN":UserDefaults.standard.value(forKey: "userCIN") as! String,"Category":UserDefaults.standard.value(forKey: "userCategory") as! String,"ClientSecret":"ohdashfl","Fromdate":fromdate,"Todate":todate,"PatyId":partyID,"DivId":divId]
        print("apiMonthSummary DETAILS : \(json)")
        let manager =  DataManager.shared
        
        manager.makeAPICall(url: apiMonthSummaryUrl, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            
            do {
                self.monthSummary = try JSONDecoder().decode([MonthSummary].self, from: data!)
                self.monthSummaryObj = self.monthSummary[0].data
                self.filteredItems = self.monthSummary[0].data
                print("apiMonthSummary Result \(self.monthSummary[0].data)")
                //self.total["unit"] = self.filteredItems.reduce(0, { $0 + Double($1.unit!)! })
                self.total["openb"] = self.filteredItems.reduce(0, { $0 + Double($1.openingBal!)! })
                self.total["torder"] = self.filteredItems.reduce(0, { $0 + Double($1.totalOrder!)! })
                self.total["trec"] = self.filteredItems.reduce(0, { $0 + Double($1.totalOrder!)! })
                self.total["bal"] = self.filteredItems.reduce(0, { $0 + Double($1.bal!)! })
                self.CollectionView.reloadData()
                self.CollectionView.collectionViewLayout.invalidateLayout()
                self.CollectionView.isHidden = false
                ViewControllerUtils.sharedInstance.removeLoader()
            } catch let errorData {
                self.CollectionView.isHidden = true
                print(errorData.localizedDescription)
                ViewControllerUtils.sharedInstance.removeLoader()
            }
        }) { (Error) in
            self.CollectionView.isHidden = true
            print(Error?.localizedDescription as Any)
            ViewControllerUtils.sharedInstance.removeLoader()
        }
        
    }
    
    //API Function...
    func apiGetAllVendors(){
        let json: [String: Any] = ["CIN":UserDefaults.standard.value(forKey: "userCIN") as! String,"Category":UserDefaults.standard.value(forKey: "userCategory") as! String,"ClientSecret":"ClientSecret"]
        let manager =  DataManager.shared
        print("vendorArray Params \(json)")
        manager.makeAPICall(url: "https://api.goldmedalindia.in/api/getManagementVendor", params: json, method: .POST, success: { (response) in
            let data = response as? Data
            
            do {
                self.searchData = try JSONDecoder().decode([SearchVendor].self, from: data!)
                self.supplierArray  = self.searchData[0].data!
                
                for dealers in self.supplierArray{
                    self.tempSupplierArr.append(dealers)
                }
                
            } catch let errorData {
                print("Caught Error ------>\(errorData.localizedDescription)")
            }
        }) { (Error) in
            print("Error -------> \(Error?.localizedDescription as Any)")
        }
        
    }
 
}
