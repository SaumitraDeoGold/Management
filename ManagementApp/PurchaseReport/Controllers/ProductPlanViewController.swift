//
//  ProductPlanViewController.swift
//  ManagementApp
//
//  Created by Goldmedal on 20/05/20.
//  Copyright © 2020 Goldmedal. All rights reserved.
//

import UIKit

class ProductPlanViewController: BaseViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    //Outlets...
    @IBOutlet weak var CollectionView: UICollectionView!
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
    
 //CollectionView Functions...
 func numberOfSections(in collectionView: UICollectionView) -> Int {
   return filteredItems.count + 2
 }
 func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
     return 6
 }
 
 func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
     
     let cell = CollectionView.dequeueReusableCell(withReuseIdentifier: cellContentIdentifier,
                                                   for: indexPath) as! CollectionViewCell
     cell.layer.borderWidth = 1
     cell.layer.borderColor = UIColor.white.cgColor
         if indexPath.section == 0{
             cell.contentLabel.font = UIFont(name: "Roboto-Medium", size: 16)
             if #available(iOS 11.0, *) {
                 cell.backgroundColor = UIColor.init(named: "Primary")
             } else {
                 cell.backgroundColor = UIColor.gray
             }
             //cell.backgroundColor = UIColor.red
             switch indexPath.row{
             case 0:
                 cell.contentLabel.text = "Item Code"
             case 1:
                 cell.contentLabel.text = "Item name"
             case 2:
                 cell.contentLabel.text = "Vasai Stock"
             case 3:
                 cell.contentLabel.text = "Branch Stock"
             case 4:
                cell.contentLabel.text = "Purchase Pending"
             case 5:
                cell.contentLabel.text = "Avg Sales"
             default:
                 break
             }
             //cell.backgroundColor = UIColor.lightGray
         }else if indexPath.section == filteredItems.count + 1{
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
                cell.contentLabel.text = "Item Name"
             case 2:
                cell.contentLabel.text = Utility.formatRupee(amount: totalPP["VS"]!)
                 cell.contentLabel.textColor = UIColor.black
             case 3:
                 cell.contentLabel.text = Utility.formatRupee(amount: totalPP["BS"]!)
                 cell.contentLabel.textColor = UIColor.black
             case 4:
                cell.contentLabel.text = Utility.formatRupee(amount: totalPP["PP"]!)
                cell.contentLabel.textColor = UIColor.black
             case 5:
                cell.contentLabel.text = Utility.formatRupee(amount: totalPP["AvgS"]!)
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
                cell.contentLabel.text = filteredItems[indexPath.section - 1].itemCode
             case 1:
                cell.contentLabel.text = filteredItems[indexPath.section - 1].itemName
             case 2:
                 if let vasaiStock = filteredItems[indexPath.section - 1].vasaiStock
                 {
                     cell.contentLabel.text = Utility.formatRupee(amount: Double(vasaiStock )!)
                 }
             case 3:
                 if let branchStock = filteredItems[indexPath.section - 1].branchStock
                 {
                     cell.contentLabel.text = Utility.formatRupee(amount: Double(branchStock )!)
                 }
             case 4:
                if let purchasePending = filteredItems[indexPath.section - 1].purchasePending
                {
                    cell.contentLabel.text = Utility.formatRupee(amount: Double(purchasePending )!)
                }
             case 5:
                if let averageSale = filteredItems[indexPath.section - 1].averageSale
                {
                    cell.contentLabel.text = Utility.formatRupee(amount: Double(averageSale )!)
                }
             default:
                 break
             }
             //cell.backgroundColor = UIColor.groupTableViewBackground
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
            self.CollectionView.reloadData()
            self.CollectionView.collectionViewLayout.invalidateLayout()
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
