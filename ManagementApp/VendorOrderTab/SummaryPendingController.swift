//
//  SummaryPendingController.swift
//  ManagementApp
//
//  Created by Goldmedal on 30/07/20.
//  Copyright © 2020 Goldmedal. All rights reserved.
//

import UIKit

class SummaryPendingController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, PopupDateDelegate {
    
    
    //Outlets...
    @IBOutlet weak var noDataView: NoDataView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    //Declarations...
    var vendorListApi = ""
    var dateFormatter = DateFormatter()
    var strCin = ""
    var strToDate = ""
    var cellContentIdentifier = "\(CollectionViewCell.self)"
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var vendorListData = [VendorPayData]()
    var vendorSale = [VendorSalePendingOrder]()
    var vendorSaleObj = [VendorSalePendingOrderObj]()
    var filteredItems = [VendorSalePendingOrderObj]()
    var fromPurchase = true
    var allSubCat = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.noDataView.hideView(view: self.noDataView)
         
//        self.collectionView.register(UINib(nibName: "ContentCollectionViewCell", bundle: nil),
//                                     forCellWithReuseIdentifier: self.contentCellIdentifier)
        
        if (Utility.isConnectedToNetwork()) {
            if fromPurchase{
                apiLastDispatchedMaterial()
            }else{
                apiSalePending()
            } 
        }
        else{
            self.noDataView.showView(view: self.noDataView, from: "NET")
            //self.collectionView.showNoData = true
        }
 
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return  (self.filteredItems.count + 1)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // swiftlint:disable force_cast
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellContentIdentifier,
        for: indexPath) as! CollectionViewCell
        
        if indexPath.section == 0 {
            if #available(iOS 11.0, *) {
                cell.backgroundColor = UIColor.init(named: "Primary")
            } else {
                cell.backgroundColor = UIColor.gray
            }
        } else {
            if #available(iOS 11.0, *) {
                cell.backgroundColor = UIColor.init(named: "primaryLight")
            } else {
                cell.backgroundColor = UIColor.lightGray
            }
        }
        
        cell.layer.borderWidth = 1
        cell.layer.borderColor = UIColor.white.cgColor
        
        if indexPath.section == 0 {
            if indexPath.row == 1 {
                cell.contentLabel.text = "Quantity"
            } else if indexPath.row == 0 {
                cell.contentLabel.text = "Item Name/Color"
            } else if indexPath.row == 3 {
                cell.contentLabel.text = "SubCategory"
            }else if indexPath.row == 2 {
                cell.contentLabel.text = "Pending Days"
            }
        }
        
         
        if indexPath.section != 0 {
            if(self.filteredItems.count > 0)
            {
                if indexPath.row == 0 {
                    cell.contentLabel.text = "\((self.filteredItems[indexPath.section-1].itemName!)) / \((self.filteredItems[indexPath.section-1].colorName!))"
                } else if indexPath.row == 5 {
                    cell.contentLabel.text = self.filteredItems[indexPath.section-1].division ?? "-"
                } else if indexPath.row == 3 {
                    cell.contentLabel.text = self.filteredItems[indexPath.section-1].subcategory ?? "-"
                } else if indexPath.row == 2 {
                    cell.contentLabel.text = self.filteredItems[indexPath.section-1].pendingDays ?? "-"
                } else if indexPath.row == 1 {
                    cell.contentLabel.text = self.filteredItems[indexPath.section-1].pendingQty ?? "-"
                } else if indexPath.row == 4 {
                    cell.contentLabel.text = self.filteredItems[indexPath.section-1].pendingDays ?? "-"
                }
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
         if indexPath.section != 0 && indexPath.section != filteredItems.count + 1 && fromPurchase{
            let storyboard = UIStoryboard(name: "VendorPurchase", bundle: nil)
            let destViewController = storyboard.instantiateViewController(withIdentifier: "SummaryPendingPO") as! SummaryPendingPOController
            destViewController.itemId = filteredItems[indexPath.section-1].itemslno!
            destViewController.itemName = filteredItems[indexPath.section-1].itemName!
            destViewController.strToDate = strToDate
            self.navigationController!.pushViewController(destViewController, animated: true)
         }else if indexPath.row == 3 && indexPath.section == 0{
            let sb = UIStoryboard(name: "PartyStoryboard", bundle: nil)
            let popup = sb.instantiateInitialViewController()! as! PartySearchController
            popup.modalPresentationStyle = .overFullScreen
            popup.delegate = self
            popup.fromPage = "Subcat Summary"
            popup.subcatSummary = allSubCat
            popup.tempSubcatSummary = allSubCat
            self.present(popup, animated: true)
        }
    }
    
    func showParty(value: String,cin: String) {
        if value == "ALL" {
            filteredItems = self.vendorSaleObj
            self.collectionView.reloadData()
            self.collectionView.collectionViewLayout.invalidateLayout()
            return
        }
        filteredItems = self.vendorSaleObj.filter { $0.subcategory == value }
        self.collectionView.reloadData()
        self.collectionView.collectionViewLayout.invalidateLayout()
    }
    
    func getIdiotsDateFormat(value: String) -> String{
        let inFormatDate = value.split{$0 == "/"}.map(String.init)
        let temp = "\(inFormatDate[0])-\(inFormatDate[1])-\(inFormatDate[2])"
        return temp
    }
    
    
    
    func apiLastDispatchedMaterial(){
            self.noDataView.showView(view: self.noDataView, from: "LOADER")
            //self.collectionView.showNoData = true
    
            let json: [String: Any] =  ["CIN":UserDefaults.standard.value(forKey: "userCIN") as! String, "Category":UserDefaults.standard.value(forKey: "userCategory") as! String,"index":"0","Date":strToDate,"cnt":"10000","vendorid":appDelegate.sendCin,"ClientSecret":"ohdashfl"]
            print("Vendor Invoice Params \(json)")
            DataManager.shared.makeAPICall(url: "https://test2.goldmedalindia.in/api/getvendorsalependingorder", params: json, method: .POST, success: { (response) in
                let data = response as? Data
    
                DispatchQueue.main.async {
                    do {
                        self.vendorSale = try JSONDecoder().decode([VendorSalePendingOrder].self, from: data!)
                        self.vendorSaleObj = self.vendorSale[0].data!
                        self.filteredItems = self.vendorSale[0].data!
                        self.allSubCat = self.filterDuplicates(arrayTwo: self.vendorSaleObj)
                        
//                        for item in 0..<self.vendorSaleObj.count{
//                            if item == 0 {
//                                self.allSubCat.append(self.vendorSaleObj[item].subcategory!)
//                            }else{
//                                if !self.allSubCat.contains(self.vendorSaleObj[item].subcategory!){
//                                    self.allSubCat.append(self.vendorSaleObj[item].subcategory!)
//                                }
//                            }
//                        }
                        print("Vendor Sale Data \(self.vendorSaleObj)")
    
                    } catch let errorData {
                        print(errorData.localizedDescription)
                    }
    
                    if(self.collectionView != nil)
                    {
                        self.collectionView.reloadData()
                    }
    
                    if(self.vendorSaleObj.count > 0)
                    {
                        self.noDataView.hideView(view: self.noDataView)
                        //self.collectionView.showNoData = false
                    }
                    else
                    {
                        self.noDataView.showView(view: self.noDataView, from: "NDA")
                        //self.collectionView.showNoData = true
                    }
                }
            }) { (Error) in
                self.noDataView.showView(view: self.noDataView, from: "ERR")
                //self.collectionView.showNoData = true
                print(Error?.localizedDescription)
            }
        }
    
    func filterDuplicates(arrayTwo: [VendorSalePendingOrderObj]) -> [String] {
        var arrayOne = [String]()
        for item in 0..<arrayTwo.count{
            if item == 0 {
                arrayOne.append(arrayTwo[item].subcategory!)
            }else{
                if !arrayOne.contains(arrayTwo[item].subcategory!){
                    arrayOne.append(arrayTwo[item].subcategory!)
                }
            }
        }
        return arrayOne
    }
    
    func apiSalePending(){
            self.noDataView.showView(view: self.noDataView, from: "LOADER")
            //self.collectionView.showNoData = true
    
            let json: [String: Any] =  ["CIN":UserDefaults.standard.value(forKey: "userCIN") as! String, "Category":UserDefaults.standard.value(forKey: "userCategory") as! String, "Date":strToDate,"cnt":"5","vendorid":appDelegate.sendCin,"ClientSecret":"ohdashfl"]
            print("Vendor Invoice Params \(json)")
            DataManager.shared.makeAPICall(url: "https://test2.goldmedalindia.in/api/getvendorpurchasependingorder", params: json, method: .POST, success: { (response) in
                let data = response as? Data
    
                DispatchQueue.main.async {
                    do {
                        self.vendorSale = try JSONDecoder().decode([VendorSalePendingOrder].self, from: data!)
                        self.vendorSaleObj = self.vendorSale[0].data!
                        self.filteredItems = self.vendorSale[0].data!
                        self.allSubCat = self.filterDuplicates(arrayTwo: self.vendorSaleObj)
                        print("Vendor Sale Data \(self.vendorSaleObj)")
                        print("All SubCat \(self.allSubCat)")
                    } catch let errorData {
                        print(errorData.localizedDescription)
                    }
    
                    if(self.collectionView != nil)
                    {
                        self.collectionView.reloadData()
                    }
    
                    if(self.vendorSaleObj.count > 0)
                    {
                        self.noDataView.hideView(view: self.noDataView)
                       // self.collectionView.showNoData = false
                    }
                    else
                    {
                        self.noDataView.showView(view: self.noDataView, from: "NDA")
                    //    self.collectionView.showNoData = true
                    }
                }
            }) { (Error) in
                self.noDataView.showView(view: self.noDataView, from: "ERR")
                //self.collectionView.showNoData = true
                print(Error?.localizedDescription)
            }
        }


}
