//
//  VendorOrderTab.swift
//  ManagementApp
//
//  Created by Goldmedal on 01/07/20.
//  Copyright © 2020 Goldmedal. All rights reserved.
//
struct VendorSalePendingOrder: Codable {
    let result: Bool?
    let message, servertime: String?
    let data: [VendorSalePendingOrderObj]?
}

// MARK: - Datum
struct VendorSalePendingOrderObj: Codable {
    let orderNo, orderDate, itemCode, division: String?
    let category, itemName, colorName, subcategory: String?
    let pendingQty, pendingDays, branchName: String?
}
import Foundation
import UIKit
import Charts
@IBDesignable class VendorOrderTab: BaseCustomView {
    
    var dateFormatter = DateFormatter()
    var strCin = ""
    var strToDate = ""
    let contentCellIdentifier = "\(ContentCollectionViewCell.self)"
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var vendorInvoiceStruct = [VendorPayStuct]()
    var vendorInvoiceStructObj = [VendorPayStuctObj]()
    var vendorListData = [VendorPayData]()
    var vendorSale = [VendorSalePendingOrder]()
    var vendorSaleObj = [VendorSalePendingOrderObj]()
    
    @IBOutlet weak var noDataView: NoDataView!
    @IBOutlet weak var btnItemWisePdf: RoundButton!
    @IBOutlet weak var btnItemWisePending: RoundButton!
    @IBOutlet weak var btnSummaryWisePending: RoundButton!
    @IBOutlet weak var btnSummaryWisePdf: RoundButton!
    
    var vendorListApi = ""
    
    @IBOutlet weak var collectionView: VendorOrderTabCollectionView!
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func xibSetup() {
        super.xibSetup()
        
        self.noDataView.hideView(view: self.noDataView)
        
        let loginData =  UserDefaults.standard.value(forKey: "loginData") as? Dictionary ?? [:]
        strCin = loginData["userlogid"] as? String ?? ""
        
        //let initialData =  UserDefaults.standard.value(forKey: "initialData") as? Dictionary ?? [:]
        vendorListApi = "https://api.goldmedalindia.in/api/getVendorPurchaseAndLedgerBalancePayment"
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
    
    @IBAction func clicked_summary_pending(_ sender: UIButton) {
 
        let storyboard = UIStoryboard(name: "VendorPurchase", bundle: nil)
        let destViewController = storyboard.instantiateViewController(withIdentifier: "SummaryPending") as! SummaryPendingController
        destViewController.fromPurchase = true
        destViewController.strToDate = getIdiotsDateFormat(value: strToDate)
        parentViewController?.navigationController!.pushViewController(destViewController, animated: true)
    }
    
    @IBAction func clicked_itemwise(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "VendorPurchase", bundle: nil)
        let destViewController = storyboard.instantiateViewController(withIdentifier: "VendorItemWisePending") as! VendorItemWiseController
        destViewController.fromPurchase = true
        //destViewController.strToDate = getIdiotsDateFormat(value: strToDate)
        parentViewController?.navigationController!.pushViewController(destViewController, animated: true)
    }
    
    func getIdiotsDateFormat(value: String) -> String{
        let inFormatDate = value.split{$0 == "/"}.map(String.init)
        let temp = "\(inFormatDate[0])-\(inFormatDate[1])-\(inFormatDate[2])"
        return temp
    }
    
    func apiLastDispatchedMaterial(){
            self.noDataView.showView(view: self.noDataView, from: "LOADER")
            self.collectionView.showNoData = true
    
            let json: [String: Any] =  ["CIN":UserDefaults.standard.value(forKey: "userCIN") as! String, "Category":UserDefaults.standard.value(forKey: "userCategory") as! String,"index":"0","Date":getIdiotsDateFormat(value: strToDate),"cnt":"5","vendorid":appDelegate.sendCin,"ClientSecret":"ohdashfl"]
            print("Vendor Invoice Params \(json)")
            DataManager.shared.makeAPICall(url: "https://test2.goldmedalindia.in/api/getvendorsalependingorder", params: json, method: .POST, success: { (response) in
                let data = response as? Data
    
                DispatchQueue.main.async {
                    do {
                        self.vendorSale = try JSONDecoder().decode([VendorSalePendingOrder].self, from: data!)
                        self.vendorSaleObj = self.vendorSale[0].data!
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
                        self.collectionView.showNoData = false
                    }
                    else
                    {
                        self.noDataView.showView(view: self.noDataView, from: "NDA")
                        self.collectionView.showNoData = true
                    }
                }
            }) { (Error) in
                self.noDataView.showView(view: self.noDataView, from: "ERR")
                self.collectionView.showNoData = true
                print(Error?.localizedDescription)
            }
        }
    
    
    func clickPdf(sender: UITapGestureRecognizer)
    {
        print("pdf name : \(sender.view!.tag)")

//        guard let url = URL(string: DispatchedMaterialArray[sender.view!.tag].url ?? "") else {
//
//            var alert = UIAlertView(title: "Error", message: "Invalid Pdf", delegate: nil, cancelButtonTitle: "OK")
//            alert.show()
//
//            return
//        }
//        if UIApplication.shared.canOpenURL(url) {
//            UIApplication.shared.open(url, options: [:], completionHandler: nil)
//        }
    }
    
}


extension VendorOrderTab: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return  (self.vendorSaleObj.count + 1)
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
            if indexPath.row == 1 {
                cell.contentLabel.text = "Quantity"
            } else if indexPath.row == 0 {
                cell.contentLabel.text = "Item Name/Color"
            } else if indexPath.row == 2 {
                cell.contentLabel.text = "SubCategory"
            }else if indexPath.row == 3 {
                cell.contentLabel.text = "Pending Days"
            }
        }
        
//        let img = UIImage.init(named: "icon_dashboard_pdf")
//        var imageview:UIImageView=UIImageView(frame: CGRect(x: 100, y: 10, width: 20, height: 20));
//        imageview.image = img
        
//        let tap = UITapGestureRecognizer(target: self, action: #selector(self.clickPdf))
//        imageview.addGestureRecognizer(tap)
//        imageview.tag = indexPath.section-1
//        imageview.isUserInteractionEnabled = true
        
        
        if indexPath.section != 0 {
            if(self.vendorSaleObj.count > 0)
            {
                 if indexPath.row == 0 {
                    cell.contentLabel.text = "\((self.vendorSaleObj[indexPath.section-1].itemName!)) / \((self.vendorSaleObj[indexPath.section-1].colorName!))"
                } else if indexPath.row == 5 {
                    cell.contentLabel.text = self.vendorSaleObj[indexPath.section-1].division ?? "-"
                } else if indexPath.row == 2 {
                    cell.contentLabel.text = self.vendorSaleObj[indexPath.section-1].category ?? "-"
                } else if indexPath.row == 3 {
                    cell.contentLabel.text = self.vendorSaleObj[indexPath.section-1].subcategory ?? "-"
                } else if indexPath.row == 1 {
                    cell.contentLabel.text = self.vendorSaleObj[indexPath.section-1].pendingQty ?? "-"
                } else if indexPath.row == 4 {
                    cell.contentLabel.text = self.vendorSaleObj[indexPath.section-1].pendingDays ?? "-"
                }
            }
        }
        
        return cell
    }
    
}

// MARK: - UICollectionViewDelegate
extension VendorOrderTab: UICollectionViewDelegate {
    
}



class VendorOrderTabCollectionView: UICollectionView {
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
//@IBDesignable class VendorOrderTab: BaseCustomView {
//
//    @IBOutlet weak var collectionView: VendorOrderTabCollectionView!
//    var strCin = ""
//    var strType = ""
//    var strTotalAmnt = "-"
//    var strCurrDate = ""
//    let cellIdentifier = "\(DashPendingOrderCell.self)"
//    let appDelegate = UIApplication.shared.delegate as! AppDelegate
//    var vendorSale = [VendorSalePendingOrder]()
//    var vendorSaleObj = [VendorSalePendingOrderObj]()
//    let contentCellIdentifier = "\(CollectionViewCell.self)"
//
//     @IBOutlet weak var noDataView: NoDataView!
//
//
//    @IBOutlet weak var btnItemWisePdf: RoundButton!
//    @IBOutlet weak var btnItemWisePending: RoundButton!
//    @IBOutlet weak var btnSummaryWisePending: RoundButton!
//    @IBOutlet weak var btnSummaryWisePdf: RoundButton!
//
//
//
//    override func xibSetup() {
//        super.xibSetup()
//
//         self.noDataView.hideView(view: self.noDataView)
//
//
//        btnItemWisePdf.imageView?.contentMode = .scaleAspectFit
//        btnSummaryWisePdf.imageView?.contentMode = .scaleAspectFit
//
//
//
//         self.noDataView.hideView(view: self.noDataView)
//
//        strCurrDate = Utility.currDate()
//
////        let currDate = Date()
////        dateFormatter.dateFormat = "dd/MM/yyyy"
////        strToDate = dateFormatter.string(from: currDate)
////        strToDate = Utility.formattedDateFromString(dateString: strToDate, withFormat: "MM/dd/yyyy")!
//
//        self.collectionView.register(UINib(nibName: "CollectionViewCell", bundle: nil),
//                                     forCellWithReuseIdentifier: self.contentCellIdentifier)
//
//        if (Utility.isConnectedToNetwork()) {
//            apiLastDispatchedMaterial()
//        }
//        else{
//            self.noDataView.showView(view: self.noDataView, from: "NET")
//            self.collectionView.showNoData = true
//        }
//    }
//
//
//
//
//    @IBAction func clicked_item_wise_pdf(_ sender: Any) {
//        //apiDownloadPendingOrder(intOrderType: 1)
//    }
//
//    @IBAction func clicked_summary_wise_pdf(_ sender: Any) {
//        //apiDownloadPendingOrder(intOrderType: 2)
//    }
//
//
//    @IBAction func clicked_summary_wise_pending(_ sender: Any) {
//        let pendingOrderSummary = parentViewController?.storyboard?.instantiateViewController(withIdentifier: "PendingOrder") as! PendingOrderController
//        pendingOrderSummary.intOrderType = 2
//        pendingOrderSummary.callFrom = 1
//        parentViewController?.navigationController?.pushViewController(pendingOrderSummary, animated: true)
//    }
//
//    @IBAction func clicked_item_wise_pending(_ sender: Any) {
//        let pendingOrderItem = parentViewController?.storyboard?.instantiateViewController(withIdentifier: "PendingOrder") as! PendingOrderController
//        pendingOrderItem.intOrderType = 1
//        pendingOrderItem.callFrom = 1
//        parentViewController?.navigationController?.pushViewController(pendingOrderItem, animated: true)
//    }
//
//
//   func apiLastDispatchedMaterial(){
//        self.noDataView.showView(view: self.noDataView, from: "LOADER")
//        self.collectionView.showNoData = true
//
//        let json: [String: Any] =  ["CIN":UserDefaults.standard.value(forKey: "userCIN") as! String, "Category":UserDefaults.standard.value(forKey: "userCategory") as! String,"index":"0","Date":"06-27-2020","cnt":"5","vendorid":appDelegate.sendCin,"ClientSecret":"ohdashfl"]
//        print("Vendor Invoice Params \(json)")
//        DataManager.shared.makeAPICall(url: "https://test2.goldmedalindia.in/api/getvendorsalependingorder", params: json, method: .POST, success: { (response) in
//            let data = response as? Data
//
//            DispatchQueue.main.async {
//                do {
//                    self.vendorSale = try JSONDecoder().decode([VendorSalePendingOrder].self, from: data!)
//                    self.vendorSaleObj = self.vendorSale[0].data!
//                    print("Vendor Sale Data \(self.vendorSaleObj)")
//
//                } catch let errorData {
//                    print(errorData.localizedDescription)
//                }
//
//                if(self.collectionView != nil)
//                {
//                    self.collectionView.reloadData()
//                }
//
//                if(self.vendorSaleObj.count > 0)
//                {
//                    self.noDataView.hideView(view: self.noDataView)
//                    self.collectionView.showNoData = false
//                }
//                else
//                {
//                    self.noDataView.showView(view: self.noDataView, from: "NDA")
//                    self.collectionView.showNoData = true
//                }
//            }
//        }) { (Error) in
//            self.noDataView.showView(view: self.noDataView, from: "ERR")
//            self.collectionView.showNoData = true
//            print(Error?.localizedDescription)
//        }
//    }
//
//
//
//
//}
//
//extension VendorOrderTab: UICollectionViewDataSource {
//
//    func numberOfSections(in collectionView: UICollectionView) -> Int {
//        return  (self.vendorSaleObj.count + 1)
//    }
//
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return 7
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        // swiftlint:disable force_cast
//
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: contentCellIdentifier,
//                                                      for: indexPath) as! CollectionViewCell
//
//        if indexPath.section == 0 {
//            if #available(iOS 11.0, *) {
//                cell.backgroundColor = UIColor.init(named: "Primary")
//            } else {
//                cell.backgroundColor = UIColor.gray
//            }
//        } else {
//            if #available(iOS 11.0, *) {
//                cell.backgroundColor = UIColor.init(named: "primaryLight")
//            } else {
//                cell.backgroundColor = UIColor.lightGray
//            }
//        }
//
//        cell.layer.borderWidth = 1
//        cell.layer.borderColor = UIColor.white.cgColor
//
//        if indexPath.section == 0 {
//            if indexPath.row == 0 {
//                cell.contentLabel.text = "Date"
//            } else if indexPath.row == 1 {
//                cell.contentLabel.text = "Item Name"
//            }else if indexPath.row == 2 {
//                cell.contentLabel.text = "Division"
//            }else if indexPath.row == 3 {
//                cell.contentLabel.text = "Category"
//            } else if indexPath.row == 4 {
//                cell.contentLabel.text = "SubCategory"
//            }else if indexPath.row == 5 {
//                cell.contentLabel.text = "Pending Qty"
//            }else if indexPath.row == 6 {
//                cell.contentLabel.text = "Pending Days"
//            }
//        }
//
//        let img = UIImage.init(named: "icon_dashboard_pdf")
//        var imageview:UIImageView=UIImageView(frame: CGRect(x: 100, y: 10, width: 20, height: 20));
//        imageview.image = img
//
////        let tap = UITapGestureRecognizer(target: self, action: #selector(self.clickPdf))
////        imageview.addGestureRecognizer(tap)
////        imageview.tag = indexPath.section-1
////        imageview.isUserInteractionEnabled = true
//
//
//        if indexPath.section != 0 {
//            if(self.vendorSaleObj.count > 0)
//            {
//                if indexPath.row == 0 {
//                    //cell.contentView.addSubview(imageview)
//                    //cell.contentLabel.textAlignment = .left
//                    cell.contentLabel.text = "    \(self.vendorSaleObj[indexPath.section-1].orderDate ?? "")"
//                } else if indexPath.row == 1 {
//                    cell.contentLabel.text = self.vendorSaleObj[indexPath.section-1].itemName ?? "-"
//                } else if indexPath.row == 2 {
//                    cell.contentLabel.text = self.vendorSaleObj[indexPath.section-1].division ?? "-"
//                } else if indexPath.row == 3 {
//                    cell.contentLabel.text = self.vendorSaleObj[indexPath.section-1].category ?? "-"
//                } else if indexPath.row == 4 {
//                    cell.contentLabel.text = self.vendorSaleObj[indexPath.section-1].subcategory ?? "-"
//                } else if indexPath.row == 5 {
//                    cell.contentLabel.text = self.vendorSaleObj[indexPath.section-1].pendingQty ?? "-"
//                } else if indexPath.row == 6 {
//                    cell.contentLabel.text = self.vendorSaleObj[indexPath.section-1].pendingDays ?? "-"
//                }
//            }
//        }
//
//        return cell
//    }
//
////    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
////        if indexPath.row == 0{
////            if vendorListData[indexPath.section-1].fileurl == ""{
////                var alert = UIAlertView(title: "Alert", message: "No Data Found", delegate: nil, cancelButtonTitle: "OK")
////                alert.show()
////                return
////            }
////            let storyboard = UIStoryboard(name: "Main", bundle: nil)
////            let vc = storyboard.instantiateViewController(withIdentifier: "Webview") as! viewPDFController
////            vc.webvwUrl = vendorListData[indexPath.section-1].fileurl!
////            parentViewController?.navigationController!.pushViewController(vc, animated: true)
////            //performSegue(withIdentifier: "byWebview", sender: self)
////        }
////    }
//
//}
//
//extension VendorOrderTab: UICollectionViewDelegate {
//
//}
//
//
//
//
//class VendorOrderTabCollectionView: UICollectionView {
//    var showNoData = false
//    override var contentSize:CGSize {
//        didSet {
//            self.invalidateIntrinsicContentSize()
//        }
//    }
//
//    override var intrinsicContentSize: CGSize {
//        self.layoutIfNeeded()
//        return CGSize(width: UIViewNoIntrinsicMetric, height: (showNoData) ? 300 : contentSize.height)
//    }
//
//}

