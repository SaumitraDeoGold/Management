//
//  VendorPurchaseItemwise.swift
//  ManagementApp
//
//  Created by Goldmedal on 17/07/20.
//  Copyright © 2020 Goldmedal. All rights reserved.
//

import Foundation
import UIKit
@IBDesignable class VendorPurchaseItemwise: BaseCustomView {
    
    var dateFormatter = DateFormatter()
    var strCin = ""
    var strToDate = ""
    let contentCellIdentifier = "\(ContentCollectionViewCell.self)"
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var vendorInvoiceStruct = [VendorOrderBottomData]()
    var vendorListData = [VendorOrderBottomObj]()
    
    @IBOutlet weak var noDataView: NoDataView!
    
    var vendorListApi = ""
    
    @IBOutlet weak var collectionView: VendorPurItemCollectionView!
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func xibSetup() {
        super.xibSetup()
        
        self.noDataView.hideView(view: self.noDataView)
        
        let loginData =  UserDefaults.standard.value(forKey: "loginData") as? Dictionary ?? [:]
        strCin = loginData["userlogid"] as? String ?? ""
        
        //let initialData =  UserDefaults.standard.value(forKey: "initialData") as? Dictionary ?? [:]
        vendorListApi = "https://test2.goldmedalindia.in/api/getvendorhighestpurchaseitemwise"
        //(initialData["baseApi"] as? String ?? "")+""+(initialData["dispatchedMaterial"] as? String ?? "")
        
        let currDate = Date()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        strToDate = dateFormatter.string(from: currDate)
        strToDate = Utility.formattedDateFromString(dateString: strToDate, withFormat: "MM/dd/yyyy")!
        
        self.collectionView.register(UINib(nibName: "ContentCollectionViewCell", bundle: nil),
                                     forCellWithReuseIdentifier: self.contentCellIdentifier)
        
        if (Utility.isConnectedToNetwork()) {
            apiLastDispatchedMaterial()
        }
        else{
            self.noDataView.showView(view: self.noDataView, from: "NET")
            self.collectionView.showNoData = true
        }
        
    }
    
    @IBAction func clicked_itemwise(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "VendorPurchase", bundle: nil)
        let destViewController = storyboard.instantiateViewController(withIdentifier: "VendorItemWisePending") as! VendorItemWiseController
        destViewController.fromPurchase = false
        //destViewController.strToDate = getIdiotsDateFormat(value: strToDate)
        parentViewController?.navigationController!.pushViewController(destViewController, animated: true)
    }
    
      
    
    func apiLastDispatchedMaterial(){
        self.noDataView.showView(view: self.noDataView, from: "LOADER")
        self.collectionView.showNoData = true
       
        let json: [String: Any] =  ["vendorid":appDelegate.sendCin,"CIN":UserDefaults.standard.value(forKey: "userCIN") as! String, "Category":UserDefaults.standard.value(forKey: "userCategory") as! String,"cnt":"5","ClientSecret":"ohdashfl","FromDate":"06-27-2018","ToDate":"06-27-2020"]
        print("Vendor Sale Itemwise Params \(json)")
        DataManager.shared.makeAPICall(url: vendorListApi, params: json, method: .POST, success: { (response) in
            let data = response as? Data
             
                do {
                    self.vendorInvoiceStruct = try JSONDecoder().decode([VendorOrderBottomData].self, from: data!)
                    self.vendorListData = self.vendorInvoiceStruct[0].data
                    print("Vendor Sale Itemwise Data \(self.vendorListData)")
                    
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
                    self.collectionView.showNoData = false
                }
                else
                {
                    self.noDataView.showView(view: self.noDataView, from: "NDA")
                    self.collectionView.showNoData = true
                }
            
        }) { (Error) in
            self.noDataView.showView(view: self.noDataView, from: "ERR")
            self.collectionView.showNoData = true
            print(Error?.localizedDescription)
        }
    }
    
    
    //    func clickPdf(sender: UITapGestureRecognizer)
    //    {
    //        print("pdf name : \(sender.view!.tag)")
    //
    //        //        guard let url = URL(string: DispatchedMaterialArray[sender.view!.tag].url ?? "") else {
    //        //
    //        //            var alert = UIAlertView(title: "Error", message: "Invalid Pdf", delegate: nil, cancelButtonTitle: "OK")
    //        //            alert.show()
    //        //
    //        //            return
    //        //        }
    //        //        if UIApplication.shared.canOpenURL(url) {
    //        //            UIApplication.shared.open(url, options: [:], completionHandler: nil)
    //        //        }
    //    }
    
}


extension VendorPurchaseItemwise: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return  (self.vendorListData.count + 1)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // swiftlint:disable force_cast
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: contentCellIdentifier,
                                                      for: indexPath) as! ContentCollectionViewCell
        
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
            if(self.vendorListData.count > 0)
            {
                 if indexPath.row == 0 {
                    cell.contentLabel.text = self.vendorListData[indexPath.section-1].itemDescription ?? "-"
                } else if indexPath.row == 1 {
                    cell.contentLabel.text = self.vendorListData[indexPath.section-1].subcategory ?? "-"
                } else if indexPath.row == 2 {
                    cell.contentLabel.text = vendorListData[indexPath.section-1].totalQty
                } else if indexPath.row == 5 {
                    cell.contentLabel.text = self.vendorListData[indexPath.section-1].offerPrice ?? "-"
                } else if indexPath.row == 3 {
                    if let basicAmt = vendorListData[indexPath.section-1].basicAmt  {
                        cell.contentLabel.text = Utility.formatRupee(amount: Double(basicAmt)!)
                    }
                    //cell.contentLabel.text = self.vendorListData[indexPath.section-1].basicAmt ?? "-"
                }
//                 else if indexPath.row == 4 {
//                    if let finalAmt = vendorListData[indexPath.section-1].finalAmt as? String {
//                        cell.contentLabel.text = Utility.formatRupee(amount: Double(finalAmt)!)
//                    }
//                    //cell.contentLabel.text = self.vendorListData[indexPath.section-1].finalAmt ?? "-"
//                }
            }
        }
        
        return cell
    }
    
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        if indexPath.row == 0{
//            if vendorListData[indexPath.section-1].fileurl == ""{
//                var alert = UIAlertView(title: "Alert", message: "No Data Found", delegate: nil, cancelButtonTitle: "OK")
//                alert.show()
//                return
//            }
//            let storyboard = UIStoryboard(name: "Main", bundle: nil)
//            let vc = storyboard.instantiateViewController(withIdentifier: "Webview") as! viewPDFController
//            vc.webvwUrl = vendorListData[indexPath.section-1].fileurl!
//            parentViewController?.navigationController!.pushViewController(vc, animated: true)
//            //performSegue(withIdentifier: "byWebview", sender: self)
//        }
//    }
    
}

// MARK: - UICollectionViewDelegate
extension VendorPurchaseItemwise: UICollectionViewDelegate {
    
}



class VendorPurItemCollectionView: UICollectionView {
    var showNoData = false
    override var contentSize:CGSize {
        didSet {
            self.invalidateIntrinsicContentSize()
        }
    }
    
    override var intrinsicContentSize: CGSize {
        self.layoutIfNeeded()
        return CGSize(width: UIViewNoIntrinsicMetric, height: (showNoData) ? 300 : contentSize.height)
    }
    
}


