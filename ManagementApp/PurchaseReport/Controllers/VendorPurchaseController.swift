//
//  VendorPurchaseController.swift
//  ManagementApp
//
//  Created by Goldmedal on 18/05/20.
//  Copyright © 2020 Goldmedal. All rights reserved.
//

import UIKit

class VendorPurchaseController: BaseViewController, UITableViewDelegate , UITableViewDataSource {
    
    
    //Outlets...
    @IBOutlet weak var CollectionView: UICollectionView!
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var lblPartyName: UIButton!
    @IBOutlet weak var btnFromDate: UIButton!
    @IBOutlet weak var btnToDate: UIButton!
    
    //Declarations...
    var vendorPurchase = [VendorPurchaseOrder]()
    var vendorPurchaseObj = [VendorPurchaseOrderObj]()
    var filteredItems = [VendorPurchaseOrderObj]()
    var cellContentIdentifier = "\(CollectionViewCell.self)"
    var apiVendorPurchaseUrl = ""
    var searchData = [SearchVendor]()
    var supplierArray = [SearchVendorObj]()
    var tempSupplierArr = [SearchVendorObj]()
    var partyID = "185"
    let currDate = Date()
    var dateFormatter = DateFormatter()
    var fromDate: Date?
    var toDate: Date?
    var strFromDate = ""
    var strToDate = ""
    var fromdate = "04/01/2020"
    var todate = "03/31/2021"
    var searchDiv = false
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addSlideMenuButton()
        ViewControllerUtils.sharedInstance.showLoader()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        strToDate = dateFormatter.string(from: currDate)
        fromDate = dateFormatter.date(from: strFromDate)
        toDate = dateFormatter.date(from: strToDate)
        apiVendorPurchaseUrl = "https://test2.goldmedalindia.in/api/Getvendorpurorderall"
        apiVendorPurchase()
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
            filteredItems = self.vendorPurchaseObj.filter { $0.division == value }
            self.CollectionView.reloadData()
            self.CollectionView.collectionViewLayout.invalidateLayout()
            searchDiv = false
        }else{
            lblPartyName.setTitle("  \(value)", for: .normal)
            partyID = cin
            ViewControllerUtils.sharedInstance.showLoader()
            apiVendorPurchase()
        }
        
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
        
        apiVendorPurchase()
    }
    
    //Show Branches Func...
    func showSearchValue(value: String) {
        if value == "ALL" {
            filteredItems = self.vendorPurchaseObj
            self.CollectionView.reloadData()
            self.CollectionView.collectionViewLayout.invalidateLayout()
            return
        }
        filteredItems = self.vendorPurchaseObj.filter { $0.branch == value }
        self.CollectionView.reloadData()
        self.CollectionView.collectionViewLayout.invalidateLayout()
    }
    
    func getOnlyDate(value: String) -> String{
        var tempDate = value.split{$0 == " "}.map(String.init)
        var inFormatDate = tempDate[0].split{$0 == "/"}.map(String.init)
        let temp = "\(inFormatDate[1])/\(inFormatDate[0])/\(inFormatDate[2])"
        return temp
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
            
            if let amount = filteredItems[indexPath.row].total as? String {
                cell.lblAmnt.text = Utility.formatRupee(amount: Double(amount)!)
            }
            cell.lblInvoiceNumber.text = "\(filteredItems[indexPath.row].invoiceNo!) / \(filteredItems[indexPath.row].division!)"
            cell.lblInvoiceDate.text = getOnlyDate(value: filteredItems[indexPath.row].invoiceDate!)
            cell.lblItemName.text =  filteredItems[indexPath.row].party!
            cell.lblDivision.text = getOnlyDate(value: filteredItems[indexPath.row].receivedDate!)
            cell.lblLrNo.text = ""
            cell.lblTransporter.text = filteredItems[indexPath.row].branch!
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.sendCin = filteredItems[indexPath.item].partyId!
        appDelegate.partyName = filteredItems[indexPath.item].party!
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let destViewController : UIViewController = storyboard.instantiateViewController(withIdentifier: "NewDashBoard") 
        let _ : UIViewController = self.navigationController!.topViewController!
        self.navigationController!.pushViewController(destViewController, animated: true)
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let destViewController = storyboard.instantiateViewController(withIdentifier: "NewDashBoard") as! NewDashboardViewController
//        parent?.navigationController!.pushViewController(destViewController, animated: true)
    }
    
    //CollectionView Functions...
//    func numberOfSections(in collectionView: UICollectionView) -> Int {
//        return filteredItems.count + 1
//    }
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return 7
//    }
    
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
//            case 1:
//                cell.contentLabel.text = "Total"
//            case 3:
//                cell.contentLabel.text = "Inv No"
//            case 2:
//                cell.contentLabel.text = "Inv Date"
//            case 4:
//                cell.contentLabel.text = "Rec Date"
//            case 0:
//                cell.contentLabel.text = "Party Name"
//            case 5:
//                cell.contentLabel.text = "Division"
//            case 6:
//                cell.contentLabel.text = "Branch"
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
//            case 1:
//                cell.contentLabel.text = filteredItems[indexPath.section-1].total
//            case 3:
//                cell.contentLabel.text = filteredItems[indexPath.section-1].invoiceNo
//            case 2:
//                cell.contentLabel.text = getOnlyDate(value: filteredItems[indexPath.section-1].invoiceDate!)
//            case 4:
//                cell.contentLabel.text = getOnlyDate(value: filteredItems[indexPath.section-1].receivedDate!)
//            case 0:
//                cell.contentLabel.text = filteredItems[indexPath.section-1].party
//            case 6:
//                cell.contentLabel.text = filteredItems[indexPath.section-1].branch
//            case 5:
//                cell.contentLabel.text = filteredItems[indexPath.section-1].division
//            default:
//                break
//            }
//        }
//        return cell
//    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 0 && indexPath.row == 5{
            let sb = UIStoryboard(name: "PartyStoryboard", bundle: nil)
            let popup = sb.instantiateInitialViewController()! as! PartySearchController
            popup.modalPresentationStyle = .overFullScreen
            popup.delegate = self
            popup.fromPage = "Division"
            self.present(popup, animated: true)
        }else if indexPath.section == 0 && indexPath.row == 6{
            let sb = UIStoryboard(name: "Search", bundle: nil)
            let popup = sb.instantiateInitialViewController()! as! SearchViewController
            popup.modalPresentationStyle = .overFullScreen
            popup.delegate = self
            popup.from = "branch"
            self.present(popup, animated: true)
        }else if indexPath.section != 0 && indexPath.section != filteredItems.count + 1{
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.sendCin = filteredItems[indexPath.section-1].partyId!
            appDelegate.partyName = filteredItems[indexPath.item].party!
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let destViewController : UIViewController = storyboard.instantiateViewController(withIdentifier: "NewDashBoard")
            let topViewController : UIViewController = self.navigationController!.topViewController!
            self.navigationController!.pushViewController(destViewController, animated: true)
        }
    }
    
    //API Functions
    func apiVendorPurchase(){
        
        let json: [String: Any] = ["CIN":UserDefaults.standard.value(forKey: "userCIN") as! String,"Category":UserDefaults.standard.value(forKey: "userCategory") as! String,"ClientSecret":"ohdashfl","Fromdate":fromdate,"Todate":todate,"PartyId":partyID]
        print("Aging DETAILS : \(json)")
        let manager =  DataManager.shared
        
        manager.makeAPICall(url: apiVendorPurchaseUrl, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            
            do {
                self.vendorPurchase = try JSONDecoder().decode([VendorPurchaseOrder].self, from: data!)
                self.vendorPurchaseObj = self.vendorPurchase[0].data
                self.filteredItems = self.vendorPurchase[0].data
                self.tableview.reloadData()
                //self.CollectionView.collectionViewLayout.invalidateLayout()
                //self.CollectionView.isHidden = false
                ViewControllerUtils.sharedInstance.removeLoader()
            } catch let errorData {
                //self.CollectionView.isHidden = true
                print(errorData.localizedDescription)
                ViewControllerUtils.sharedInstance.removeLoader()
            }
        }) { (Error) in
            //self.CollectionView.isHidden = true
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
                print("vendorArray Result \(self.searchData[0].data!)")
                for dealers in self.supplierArray{
                    self.tempSupplierArr.append(dealers)
                }
                ViewControllerUtils.sharedInstance.removeLoader()
                
            } catch let errorData {
                print("Caught Error ------>\(errorData.localizedDescription)")
                ViewControllerUtils.sharedInstance.removeLoader()
            }
        }) { (Error) in
            print("Error -------> \(Error?.localizedDescription as Any)")
            ViewControllerUtils.sharedInstance.removeLoader()
        }
        
    }
    
    
}
