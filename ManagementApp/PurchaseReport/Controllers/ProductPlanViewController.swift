//
//  ProductPlanViewController.swift
//  ManagementApp
//
//  Created by Goldmedal on 20/05/20.
//  Copyright © 2020 Goldmedal. All rights reserved.
//

import UIKit

class ProductPlanViewController: BaseViewController, UITableViewDelegate , UITableViewDataSource {

    //Outlets...
    @IBOutlet weak var CollectionView: UICollectionView!
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var lblPartyName: UIButton!
    
    //Declarations...
    var apiProductPlan = ""
    var productPlanning = [ProductPlanning]()
    var productPlanningObj = [ProductPlanningObj]()
    var filteredItems = [ProductPlanningObj]()
    var cellContentIdentifier = "\(CollectionViewCell.self)"
    var totalPP = ["VS":0.0,"BS":0.0,"PP":0.0,"AvgS":0.0]
    var apiGetSubCat = ""
    var subCategory = [SubCategory]()
    var subCategoryObj = [SubCategoryObj]()
    var subcat = "341"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        apiProductPlan = "https://test2.goldmedalindia.in/api/Getproductionplaing"
        apiGetSubCat = "https://test2.goldmedalindia.in/api/getSubCategoryList"
        ViewControllerUtils.sharedInstance.showLoader()
        addSlideMenuButton()
        apiProductPlanningData()
        apiGetAllSubCat()
        // Do any additional setup after loading the view.
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
    
    //Popup Func...
    func showParty(value: String,cin: String) {
        lblPartyName.setTitle("  \(value)", for: .normal)
        subcat = cin
        ViewControllerUtils.sharedInstance.showLoader()
        apiProductPlanningData()
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
         
         if let amount = filteredItems[indexPath.row].averageSale as? String {
             cell.lblAmnt.text = filteredItems[indexPath.row].averageSale
         }
//         if let amount = filteredItems[indexPath.row].purchasePending as? String {
//             cell.lblLrNo.text = filteredItems[indexPath.row].purchasePending
//         }
         if let amount = filteredItems[indexPath.row].branchStock as? String {
             cell.lblDivision.text = filteredItems[indexPath.row].branchStock
         }
         if let amount = filteredItems[indexPath.row].vasaiStock as? String {
             cell.lblTransporter.text = filteredItems[indexPath.row].vasaiStock
         }
         cell.lblInvoiceNumber.text = "\(filteredItems[indexPath.row].itemName!) / \(filteredItems[indexPath.row].itemCode!)"
        cell.lblInvoiceDate.text = filteredItems[indexPath.row].purchasePending!
         //cell.lblItemName.text = filteredItems[indexPath.row].party!
     }
     return cell
 }
     
 //API CALLS..............
 func apiProductPlanningData(){
     
     let json: [String: Any] = ["ClientSecret":"jgsfhfdk","CIN":UserDefaults.standard.value(forKey: "userCIN") as! String,"Category":UserDefaults.standard.value(forKey: "userCategory") as! String,"SubCategory":subcat]
     
     let manager =  DataManager.shared
     print("apiPurchaseSales params \(json)")
     manager.makeAPICall(url: apiProductPlan, params: json, method: .POST, success: { (response) in
         let data = response as? Data
         
         do {
            self.productPlanning = try JSONDecoder().decode([ProductPlanning].self, from: data!)
            //print("Accounts Ledgerwise result \(self.productPlanning[0].data)")
            self.productPlanningObj = self.productPlanning[0].data
            self.filteredItems = self.productPlanning[0].data 
            self.totalPP["VS"] = self.filteredItems.reduce(0, { $0 + Double($1.vasaiStock!)! })
            self.totalPP["BS"] = self.filteredItems.reduce(0, { $0 + Double($1.branchStock!)! })
            self.totalPP["PP"] = self.filteredItems.reduce(0, { $0 + Double($1.purchasePending!)! })
            self.totalPP["AvgS"] = self.filteredItems.reduce(0, { $0 + Double($1.averageSale ?? "0.0")! })
            self.tableview.reloadData()
            //self.CollectionView.collectionViewLayout.invalidateLayout()
             //self.CollectionView.setContentOffset(CGPoint.zero, animated: true)
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

}
