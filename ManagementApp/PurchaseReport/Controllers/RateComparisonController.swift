//
//  RateComparisonController.swift
//  ManagementApp
//
//  Created by Goldmedal on 27/05/20.
//  Copyright © 2020 Goldmedal. All rights reserved.
//

import UIKit

class RateComparisonController: BaseViewController, UITableViewDelegate , UITableViewDataSource {
    
    //Outlets...
    @IBOutlet weak var CollectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var lblCatName: UIButton!
    @IBOutlet weak var lblItemName: UIButton!
    @IBOutlet weak var lblTypeName: UIButton!
    
    //Declarations...
    var rateComparison = [RateComparison]()
    var rateComparisonObj = [RateComparisonObj]()
    var filteredItems = [RateComparisonObj]()
    var cellContentIdentifier = "\(CounterBoyApprovalCell.self)"
    var apiRateComparisonUrl = ""
    var apiGetSubCat = ""
    var subCategory = [SubCategory]()
    var subCategoryObj = [SubCategoryObj]()
    var apiGetSubCatItems = ""
    var subCatItemList = [SubCatItemList]()
    var subCatItemListObj = [SubCatItemListObj]()
    var subCatSel = "195"
    var itemSelected = false
    var itemId = "0"
    var partyType = "0"
    var total = ["mrp":0.0,"comp":0.0]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        apiRateComparisonUrl = "https://test2.goldmedalindia.in/api/getratecomparison"
        apiGetSubCat = "https://test2.goldmedalindia.in/api/getSubCategoryList"
        apiGetSubCatItems = "https://test2.goldmedalindia.in/api/getSubCatWiseItemList"
        ViewControllerUtils.sharedInstance.showLoader()
        addSlideMenuButton()
        apiRateComparison()
        apiGetAllSubCat()
        tableView.separatorStyle = .none
        
    }
    
    //Button...
    @IBAction func searchParty(_ sender: Any) {
        let sb = UIStoryboard(name: "PartyStoryboard", bundle: nil)
        let popup = sb.instantiateInitialViewController()! as! PartySearchController
        popup.modalPresentationStyle = .overFullScreen
        popup.delegate = self
        popup.fromPage = "SubCat"
        popup.subCatObj = subCategoryObj
        popup.tempSubCatObj = subCategoryObj
        self.present(popup, animated: true)
    }
    
    @IBAction func searchItems(_ sender: Any) {
        if subCategoryObj.count == 0{
            let alert = UIAlertController(title: "Access Denied", message: "Select Sub-Category First", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        if subCatItemListObj.count == 0{
            let alert = UIAlertController(title: "Sorry!", message: "No Data Found", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        itemSelected = true
        let sb = UIStoryboard(name: "PartyStoryboard", bundle: nil)
        let popup = sb.instantiateInitialViewController()! as! PartySearchController
        popup.modalPresentationStyle = .overFullScreen
        popup.delegate = self
        popup.fromPage = "Items"
        popup.subCatItems = subCatItemListObj
        popup.tempSubCatItemsObj = subCatItemListObj
        self.present(popup, animated: true)
    }
    
    @IBAction func selectPartyType(_ sender: Any) {
        let sb = UIStoryboard(name: "Sorting", bundle: nil)
        let popup = sb.instantiateInitialViewController()! as! SortViewController
        popup.modalPresentationStyle = .overFullScreen
        popup.delegate = self
        popup.showPicker = 1
        popup.pickerDataSource = ["ALL","VENDOR","SUPPLIER"]
        self.present(popup, animated: true)
    }
    
    //Popup Func...
    func showParty(value: String,cin: String) {
        if itemSelected{
            lblCatName.setTitle("  \(value)", for: .normal)
            itemId = cin
            ViewControllerUtils.sharedInstance.showLoader()
            apiRateComparison()
            itemSelected = false
        }else{
            lblCatName.setTitle("  \(value)", for: .normal)
            subCatSel = cin
            ViewControllerUtils.sharedInstance.showLoader()
            apiGetAllSubCatItems()
        }
        
    }
    
    func sortBy(value: String, position: Int) {
        lblTypeName.setTitle("  \(value)", for: .normal)
        switch position {
        case 0:
            partyType = "0"
        case 1:
            partyType = "2"
        case 2:
            partyType = "1"
        default:
            break
        }
        apiRateComparison()
    }
    
    //Tableview Functions...
        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return 275
        }
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return filteredItems.count
        }
        
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CounterBoyApprovalCell", for: indexPath) as! CounterBoyApprovalCell
            
            cell.contentLabel.text = "Item Code : \(filteredItems[indexPath.item].itemCode ?? "0")"
            cell.contentLabel1.text = "Item Name  : \(filteredItems[indexPath.item].itemName ?? "-")"
            cell.contentLabel2.text = "Party Name : \(filteredItems[indexPath.item].party ?? "-")"
            cell.contentLabel3.text = "Type : \(filteredItems[indexPath.item].partyType ?? "-")"
            cell.contentLabel4.text = "MRP : \(filteredItems[indexPath.item].mrp ?? "-")"
            cell.contentLabel5.text = "Comparison : \(filteredItems[indexPath.item].comparison ?? "-")"
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            return cell
        }
    
     
    
    //API Functions
    func apiRateComparison(){
        
        let json: [String: Any] = ["CIN":UserDefaults.standard.value(forKey: "userCIN") as! String,"Category":UserDefaults.standard.value(forKey: "userCategory") as! String,"ClientSecret":"ohdashfl","ItemId":itemId,"SubCatId":subCatSel,"PartyType":partyType]
        print("rateComparison DETAILS : \(json)")
        let manager =  DataManager.shared
        
        manager.makeAPICall(url: apiRateComparisonUrl, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            
            do {
                self.rateComparison = try JSONDecoder().decode([RateComparison].self, from: data!)
                self.rateComparisonObj = self.rateComparison[0].data
                self.filteredItems = self.rateComparison[0].data
                print("rateComparison Result \(self.rateComparison[0].data)")
                self.total["mrp"] = self.filteredItems.reduce(0, { $0 + Double($1.mrp!)! })
                self.total["comp"] = self.filteredItems.reduce(0, { $0 + Double($1.comparison!)! })
                self.tableView.reloadData()
                //self.CollectionView.collectionViewLayout.invalidateLayout()
                self.tableView.isHidden = false
                ViewControllerUtils.sharedInstance.removeLoader()
            } catch let errorData {
                self.tableView.isHidden = true
                print(errorData.localizedDescription)
                ViewControllerUtils.sharedInstance.removeLoader()
            }
        }) { (Error) in
            self.tableView.isHidden = true
            print(Error?.localizedDescription as Any)
            ViewControllerUtils.sharedInstance.removeLoader()
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.sendCin = filteredItems[indexPath.item].partyId!
        appDelegate.partyName = filteredItems[indexPath.item].party!
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let destViewController : UIViewController = storyboard.instantiateViewController(withIdentifier: "NewDashBoard")
        let topViewController : UIViewController = self.navigationController!.topViewController!
        self.navigationController!.pushViewController(destViewController, animated: true)
    }
    
    func apiGetAllSubCat(){
        let json: [String: Any] = ["CIN":UserDefaults.standard.value(forKey: "userCIN") as! String,"Category":UserDefaults.standard.value(forKey: "userCategory") as! String,"ClientSecret":"ClientSecret"]
        let manager =  DataManager.shared
        print("Subcat Params \(json)")
        manager.makeAPICall(url: apiGetSubCat, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            
            do {
                self.subCategory = try JSONDecoder().decode([SubCategory].self, from: data!)
                self.subCategoryObj  = self.subCategory[0].data
                print("subCategoryObj Params \(self.subCategoryObj)")
                //ViewControllerUtils.sharedInstance.removeLoader()
                
            } catch let errorData {
                print("Caught Error ------>\(errorData.localizedDescription)")
                //ViewControllerUtils.sharedInstance.removeLoader()
            }
        }) { (Error) in
            print("Error -------> \(Error?.localizedDescription as Any)")
            //ViewControllerUtils.sharedInstance.removeLoader()
        }
        
    }
    
    func apiGetAllSubCatItems(){
        let json: [String: Any] = ["CIN":UserDefaults.standard.value(forKey: "userCIN") as! String,"Category":UserDefaults.standard.value(forKey: "userCategory") as! String,"ClientSecret":"ClientSecret","SubCat":subCatSel]
        let manager =  DataManager.shared
        print("SubcatItems Params \(json)")
        manager.makeAPICall(url: apiGetSubCatItems, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            
            do {
                self.subCatItemList = try JSONDecoder().decode([SubCatItemList].self, from: data!)
                self.subCatItemListObj  = self.subCatItemList[0].data
                print("SubCategoryItems Params \(self.subCatItemList)")
                ViewControllerUtils.sharedInstance.removeLoader()
                
            } catch let errorData {
                print("Caught Error ------>\(errorData.localizedDescription)")
                ViewControllerUtils.sharedInstance.removeLoader()
            }
        }) { (Error) in
            print("Error -------> \(Error?.localizedDescription as Any)")
            //ViewControllerUtils.sharedInstance.removeLoader()
        }
        
    }
    
}
