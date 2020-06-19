//
//  MonthwiseViewController.swift
//  ManagementApp
//
//  Created by Goldmedal on 22/05/20.
//  Copyright © 2020 Goldmedal. All rights reserved.
//

import UIKit

class MonthwiseViewController: BaseViewController, UITableViewDelegate , UITableViewDataSource {
    
    //Outlets...
    @IBOutlet weak var CollectionView: UICollectionView!
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var lblPartyName: UIButton!
    @IBOutlet weak var lblDivName: UIButton!
    @IBOutlet weak var btnFromDate: UIButton!
    @IBOutlet weak var btnToDate: UIButton!
    @IBOutlet weak var noDataView: NoDataView!
    
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
    var fromdate = "02/29/2020"
    var todate = "04/30/2020"
    var total = ["unit":0.0,"openb":0.0,"torder":0.0,"trec":0.0,"bal":0.0]
    var searchDiv = false
    var fromMonth = ["April-19","May-19","June-19","July-19","Aug-19","Sept-19","Oct-19","Nov-19","Dec-19","Jan-20","Feb-20","March-20","April-20","May-20","June-20","July-20","Aug-20","Sept-20","Oct-20","Nov-20","Dec-20"]
    var actualFromDate = ["04/01/2019","05/01/2019","06/01/2019","07/01/2019","08/01/2019","09/01/2019","10/01/2019","11/01/2019","12/01/2019","01/01/2020","02/01/2020","03/01/2020","04/01/2020","05/01/2020","06/01/2020","07/01/2020","08/01/2020","09/01/2020","10/01/2020","11/01/2020","12/01/2020"]
    var actualToDate = ["04/30/2019","05/31/2019","06/30/2019","07/31/2019","08/31/2019","09/30/2019","10/31/2019","11/30/2019","12/31/2019","01/31/2020","02/29/2020","03/31/2020","04/30/2020","05/31/2020","06/30/2020","07/31/2020","08/31/2020","09/30/2020","10/31/2020","11/30/2020","12/31/2020"]
    var fromSelected = "April-20"

    override func viewDidLoad() {
        super.viewDidLoad()
        addSlideMenuButton()
        self.noDataView.hideView(view: self.noDataView)
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
        let sb = UIStoryboard(name: "Sorting", bundle: nil)
        let popup = sb.instantiateInitialViewController()! as! SortViewController
        popup.modalPresentationStyle = .overFullScreen
        popup.delegate = self
        popup.showPicker = 1
        popup.pickerDataSource = fromMonth
        self.present(popup, animated: true)
    }
    
    @IBAction func clicked_to_date_div(_ sender: UIButton) {
        sender.isSelected = true
        let sb = UIStoryboard(name: "Sorting", bundle: nil)
        let popup = sb.instantiateInitialViewController()! as! SortViewController
        popup.modalPresentationStyle = .overFullScreen
        popup.delegate = self
        popup.showPicker = 1
        popup.pickerDataSource = selectToDate(value: fromSelected)
        self.present(popup, animated: true)
    }
    
    func selectToDate(value: String) -> Array<String>{
        var temp = [String]()
        let spotIndex = fromMonth.index(of: value)
        temp.append(fromMonth[spotIndex!])
        temp.append(fromMonth[spotIndex!+1])
        temp.append(fromMonth[spotIndex!+2])
        return temp
    }
    
    //Popup Func...
    func showParty(value: String,cin: String) {
        if searchDiv{
            searchDiv = false
            divId = value
        }else{
            lblPartyName.setTitle("  \(value)", for: .normal)
            partyID = cin 
        }
        ViewControllerUtils.sharedInstance.showLoader()
        apiMonthSummary()
    }
    
    func sortBy(value: String, position: Int) {
        
        if btnFromDate.isSelected {
            btnFromDate.setTitle("  \(value)", for: .normal)
            btnFromDate.isSelected = false
            fromSelected = value
            fromdate = actualFromDate[position]
        }else{
            btnToDate.setTitle(value, for: .normal)
            btnToDate.isSelected = false
            let temp = fromMonth.index(of: value)
            todate = actualToDate[temp!]
            ViewControllerUtils.sharedInstance.showLoader()
            apiMonthSummary()
        }
        
    }
    
    //TableView Functions...
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredItems.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "DispatchedMaterialCell", for: indexPath) as! DispatchedMaterialCell
        if(filteredItems.count>0){
            
            if let amount = filteredItems[indexPath.row].totalOrder as? String {
                cell.lblAmnt.text = Utility.formatRupee(amount: Double(amount)!)
            }
            if let amount = filteredItems[indexPath.row].bal as? String {
                cell.lblInvoiceDate.text = Utility.formatRupee(amount: Double(amount)!)
            }
            if let amount = filteredItems[indexPath.row].openingBal as? String {
                cell.lblDivision.text = Utility.formatRupee(amount: Double(amount)!)
            }
            if let amount = filteredItems[indexPath.row].totalReceived as? String {
                cell.lblTransporter.text = Utility.formatRupee(amount: Double(amount)!)
            }
            cell.lblInvoiceNumber.text = "\(filteredItems[indexPath.row].itemName!) / \(filteredItems[indexPath.row].itemCode!)"
            //cell.lblInvoiceDate.text = filteredItems[indexPath.row].bal!
        }
        return cell
    }
    
    //CollectionView Functions...
//    func numberOfSections(in collectionView: UICollectionView) -> Int {
//        return filteredItems.count + 2
//    }
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return 6
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//
//        let cell = CollectionView.dequeueReusableCell(withReuseIdentifier: cellContentIdentifier,
//                                                      for: indexPath) as! CollectionViewCell
//        cell.layer.borderWidth = 1
//        cell.layer.borderColor = UIColor.white.cgColor
//        //Header of CollectionView...
//
//        if indexPath.section == 0 {
//            cell.contentLabel.font = UIFont(name: "Roboto-Medium", size: 16)
//            if #available(iOS 11.0, *) {
//                cell.backgroundColor = UIColor.init(named: "Primary")
//            } else {
//                cell.backgroundColor = UIColor.gray
//            }
//            switch indexPath.row{
//            case 0:
//                cell.contentLabel.text = "Item Name"
//            case 1:
//                cell.contentLabel.text = "Item Code/Units"
//            case 2:
//                cell.contentLabel.text = "Open. Bal"
//            case 3:
//                cell.contentLabel.text = "T. Order"
//            case 4:
//                cell.contentLabel.text = "T.Recieved"
//            case 5:
//                cell.contentLabel.text = "Bal"
//            default:
//                break
//            }
//        }else if indexPath.section == filteredItems.count + 1{
//            cell.contentLabel.font = UIFont(name: "Roboto-Medium", size: 16)
//            if #available(iOS 11.0, *) {
//                cell.backgroundColor = UIColor.init(named: "Primary")
//            } else {
//                cell.backgroundColor = UIColor.gray
//            }
//            switch indexPath.row{
//            case 0:
//                cell.contentLabel.text = " "
//            case 1:
//                cell.contentLabel.text = "SUM"
//            case 2:
//                cell.contentLabel.text = Utility.formatRupee(amount: Double(total["openb"] ?? 0.0))
//            case 3:
//                cell.contentLabel.text = Utility.formatRupee(amount: Double(total["torder"] ?? 0.0))
//            case 4:
//                cell.contentLabel.text = Utility.formatRupee(amount: Double(total["trec"] ?? 0.0))
//            case 5:
//                cell.contentLabel.text = Utility.formatRupee(amount: Double(total["bal"] ?? 0.0))
//            default:
//                break
//            }
//        } else {
//            cell.contentLabel.font = UIFont(name: "Roboto-Regular", size: 14)
//            if #available(iOS 11.0, *) {
//                cell.backgroundColor = UIColor.init(named: "primaryLight")
//            } else {
//                cell.backgroundColor = UIColor.lightGray
//            }
//            switch indexPath.row{
//            case 0:
//                cell.contentLabel.text = filteredItems[indexPath.section-1].itemName
//            case 1:
//                cell.contentLabel.text = "\(filteredItems[indexPath.section-1].itemCode!)/\(filteredItems[indexPath.section-1].unit!) "
//            case 2:
//                if let openingBal = filteredItems[indexPath.section - 1].openingBal
//                {
//                    cell.contentLabel.text = Utility.formatRupee(amount: Double(openingBal )!)
//                }
//            case 3:
//                if let totalOrder = filteredItems[indexPath.section - 1].totalOrder
//                {
//                    cell.contentLabel.text = Utility.formatRupee(amount: Double(totalOrder )!)
//                }
//            case 4:
//                if let totalReceived = filteredItems[indexPath.section - 1].totalReceived
//                {
//                    cell.contentLabel.text = Utility.formatRupee(amount: Double(totalReceived )!)
//                }
//            case 5:
//                if let bal = filteredItems[indexPath.section - 1].bal
//                {
//                    cell.contentLabel.text = Utility.formatRupee(amount: Double(bal )!)
//                }
//            default:
//                break
//            }
//        }
//        return cell
//    }
    
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
                self.tableview.reloadData()
                self.noDataView.hideView(view: self.noDataView)
                ViewControllerUtils.sharedInstance.removeLoader()
            } catch let errorData {
                //self.CollectionView.isHidden = true
                self.noDataView.showView(view: self.noDataView, from: "NDA")
                print(errorData.localizedDescription)
                ViewControllerUtils.sharedInstance.removeLoader()
            }
        }) { (Error) in
            //self.CollectionView.isHidden = true
            self.noDataView.showView(view: self.noDataView, from: "NDA")
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
