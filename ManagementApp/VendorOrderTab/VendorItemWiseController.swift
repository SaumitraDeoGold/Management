//
//  VendorItemWiseController.swift
//  ManagementApp
//
//  Created by Goldmedal on 30/07/20.
//  Copyright © 2020 Goldmedal. All rights reserved.
//

import Foundation
import UIKit
class VendorItemWiseController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, PopupDateDelegate {
    
    
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
    var vendorInvoiceStruct = [VendorOrderBottomData]()
    var vendorListData = [VendorOrderBottomObj]()
    var filteredItems = [VendorOrderBottomObj]()
    var fromPurchase = true
    var allSubCat = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.noDataView.hideView(view: self.noDataView)
         
//        self.collectionView.register(UINib(nibName: "ContentCollectionViewCell", bundle: nil),
//                                     forCellWithReuseIdentifier: self.contentCellIdentifier)
        
        if (Utility.isConnectedToNetwork()) {
            if fromPurchase{
                self.title = "All Highest Purchase Itemwise"
                apiLastDispatchedMaterial()
            }else{
                self.title = "All Highest Sale Itemwise"
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
            if indexPath.row == 0 {
                cell.contentLabel.text = "Item Desc"
            }else if indexPath.row == 1 {
                cell.contentLabel.text = "SubCategory"
            }else if indexPath.row == 2 {
                cell.contentLabel.text = "Qty"
            } else if indexPath.row == 5 {
                cell.contentLabel.text = "Offer Price"
            }else if indexPath.row == 3 {
                cell.contentLabel.text = "Before Tax Amt"
            }else if indexPath.row == 4 {
                cell.contentLabel.text = "Final Amt"
            }
        }
        
        let img = UIImage.init(named: "icon_dashboard_pdf")
        var imageview:UIImageView=UIImageView(frame: CGRect(x: 100, y: 10, width: 20, height: 20));
        imageview.image = img
        
        //        let tap = UITapGestureRecognizer(target: self, action: #selector(self.clickPdf))
        //        imageview.addGestureRecognizer(tap)
        //        imageview.tag = indexPath.section-1
        //        imageview.isUserInteractionEnabled = true
        
        
        if indexPath.section != 0 {
            if(self.filteredItems.count > 0)
            {
                  if indexPath.row == 0 {
                    cell.contentLabel.text = self.filteredItems[indexPath.section-1].itemDescription ?? "-"
                } else if indexPath.row == 1 {
                    cell.contentLabel.text = self.filteredItems[indexPath.section-1].subcategory ?? "-"
                } else if indexPath.row == 2 {
                    cell.contentLabel.text = fromPurchase ? filteredItems[indexPath.section-1].quantity : filteredItems[indexPath.section-1].totalQty
                } else if indexPath.row == 5 {
                    cell.contentLabel.text = self.filteredItems[indexPath.section-1].offerPrice ?? "-"
                } else if indexPath.row == 3 {
                    if let basicAmt = filteredItems[indexPath.section-1].basicAmt as? String {
                        cell.contentLabel.text = Utility.formatRupee(amount: Double(basicAmt)!)
                    }
                } else if indexPath.row == 4 {
                    if let finalAmt = filteredItems[indexPath.section-1].finalAmt as? String {
                        cell.contentLabel.text = Utility.formatRupee(amount: Double(finalAmt)!)
                    }
                }
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
         if indexPath.section != 0 && indexPath.section != filteredItems.count + 1 && fromPurchase{
            let storyboard = UIStoryboard(name: "VendorPurchase", bundle: nil)
            let destViewController = storyboard.instantiateViewController(withIdentifier: "VendorItemWisePO") as! VendorItemPOController
            destViewController.itemid = filteredItems[indexPath.section-1].itemslno!
            destViewController.itemDesc = filteredItems[indexPath.section-1].itemDescription!
            self.navigationController!.pushViewController(destViewController, animated: true)
        }else if indexPath.row == 1 && indexPath.section == 0{
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
            filteredItems = self.vendorListData
            self.collectionView.reloadData()
            self.collectionView.collectionViewLayout.invalidateLayout()
            return
        }
        filteredItems = self.vendorListData.filter { $0.subcategory == value }
        self.collectionView.reloadData()
        self.collectionView.collectionViewLayout.invalidateLayout()
    }
    
    func filterDuplicates(arrayTwo: [VendorOrderBottomObj]) -> [String] {
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
    
    func getIdiotsDateFormat(value: String) -> String{
        let inFormatDate = value.split{$0 == "/"}.map(String.init)
        let temp = "\(inFormatDate[0])-\(inFormatDate[1])-\(inFormatDate[2])"
        return temp
    }
    
    func apiLastDispatchedMaterial(){
        self.noDataView.showView(view: self.noDataView, from: "LOADER")
        //self.collectionView.showNoData = true
        
        let json: [String: Any] =  ["vendorid":appDelegate.sendCin,"CIN":UserDefaults.standard.value(forKey: "userCIN") as! String, "Category":UserDefaults.standard.value(forKey: "userCategory") as! String,"index":"0","cnt":"10000","ClientSecret":"ohdashfl","FromDate":"06-27-2018","ToDate":"06-27-2020"]
        print("Vendor Bottom Params \(json)")
        DataManager.shared.makeAPICall(url: "https://test2.goldmedalindia.in/api/getvendorhighestsalesItemwise", params: json, method: .POST, success: { (response) in
            let data = response as? Data
             
                do {
                    self.vendorInvoiceStruct = try JSONDecoder().decode([VendorOrderBottomData].self, from: data!)
                    self.vendorListData = self.vendorInvoiceStruct[0].data
                    self.filteredItems = self.vendorInvoiceStruct[0].data
                    self.allSubCat = self.filterDuplicates(arrayTwo: self.vendorListData)
                    print("Vendor Bottom Data \(self.vendorListData)")
                    
                    //self.DispatchedMaterialArray.append(contentsOf: self.DispatchedMaterialDataMain[0].dispatchdata)
                    
                } catch let errorData {
                    print(errorData.localizedDescription)
                }
                
                if(self.collectionView != nil)
                {
                    self.collectionView.reloadData()
                }
                
                if(self.vendorListData.count > 0)
                {
                    self.noDataView.hideView(view: self.noDataView)
                    //self.collectionView.showNoData = false
                }
                else
                {
                    self.noDataView.showView(view: self.noDataView, from: "NDA")
                    //self.collectionView.showNoData = true
                }
            
        }) { (Error) in
            self.noDataView.showView(view: self.noDataView, from: "ERR")
            //self.collectionView.showNoData = true
            print(Error?.localizedDescription)
        }
    }
    
    func apiSalePending(){
        self.noDataView.showView(view: self.noDataView, from: "LOADER")
        //self.collectionView.showNoData = true
        
        let json: [String: Any] =  ["vendorid":appDelegate.sendCin,"CIN":UserDefaults.standard.value(forKey: "userCIN") as! String, "Category":UserDefaults.standard.value(forKey: "userCategory") as! String,"cnt":"10000","ClientSecret":"ohdashfl","FromDate":"06-27-2018","ToDate":"06-27-2020"]
        print("Vendor Bottom Params \(json)")
        DataManager.shared.makeAPICall(url: "https://test2.goldmedalindia.in/api/getvendorhighestpurchaseitemwise", params: json, method: .POST, success: { (response) in
            let data = response as? Data
            
            do {
                self.vendorInvoiceStruct = try JSONDecoder().decode([VendorOrderBottomData].self, from: data!)
                self.vendorListData = self.vendorInvoiceStruct[0].data
                self.filteredItems = self.vendorInvoiceStruct[0].data
                self.allSubCat = self.filterDuplicates(arrayTwo: self.vendorListData)
                print("Vendor Bottom Data \(self.vendorListData)")
                
                //self.DispatchedMaterialArray.append(contentsOf: self.DispatchedMaterialDataMain[0].dispatchdata)
                
            } catch let errorData {
                print(errorData.localizedDescription)
            }
            
            if(self.collectionView != nil)
            {
                self.collectionView.reloadData()
            }
            
            if(self.vendorListData.count > 0)
            {
                self.noDataView.hideView(view: self.noDataView)
                //self.collectionView.showNoData = false
            }
            else
            {
                self.noDataView.showView(view: self.noDataView, from: "NDA")
               // self.collectionView.showNoData = true
            }
            
        }) { (Error) in
            self.noDataView.showView(view: self.noDataView, from: "ERR")
            //self.collectionView.showNoData = true
            print(Error?.localizedDescription)
        }
    }


}
