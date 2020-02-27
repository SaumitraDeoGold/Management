//
//  AllInvoiceViewController.swift
//  ManagementApp
//
//  Created by Goldmedal on 24/02/20.
//  Copyright © 2020 Goldmedal. All rights reserved.
//

import UIKit

class AllInvoiceViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    //Outlets...
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var noDataView: NoDataView!
    
    //Declarations...
    var vendorInvoiceStruct = [VendorOrderStruct]()
    var vendorInvoiceStructObj = [VendorOrderStructObj]()
    var vendorListData = [VendorOrderData]()
    var vendorInvoice = [VendorInvoiceStruct]()
    var vendorInvoiceObj = [VendorInvoiceStructObj]()
    var vendorData = [VendorListData]()
    var vendorPay = [VendorPayStuct]()
    var vendorPayObj = [VendorPayStuctObj]()
    var vendorPayData = [VendorPayData]()
    var supplierInvoiceStruct = [SupplierInvoiceStruct]()
    var supplierInvoiceStructObj = [SupplierInvoiceObj]()
    var supplierListData = [SupplierInvoiceData]()
    var supplierPayStruct = [SupplierPaymentStruct]()
    var supplierPayStructObj = [SupplierPaymentObj]()
    var supplierPayData = [SupplierPaymentData]()
    var vendorListApi = ""
    var vendorInvApi = ""
    var vendorPayApi = ""
    var supplierInvoiceApi = ""
    var supplierPayApi = ""
    var cinRecieved = ""
    let cellContentIdentifier = "\(CollectionViewCell.self)"
    var from = ""
    var toSend = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.noDataView.hideView(view: self.noDataView)
        ViewControllerUtils.sharedInstance.showLoader()
        vendorListApi = "https://test2.goldmedalindia.in/api/getVendorPurchaseAndLedgerBalanceOrderNo"
        vendorInvApi = "https://test2.goldmedalindia.in/api/getVendorPurchaseAndLedgerBalanceInvoiceNo"
        vendorPayApi = "https://test2.goldmedalindia.in/api/getVendorPurchaseAndLedgerBalancePayment"
        supplierInvoiceApi = "https://test2.goldmedalindia.in/api/getSupplierPurchaseAndLedgerBalanceInvoiceNo"
        supplierPayApi = "https://test2.goldmedalindia.in/api/getSupplierPurchaseAndLedgerBalancePayment"
        if from == "vendorOrder"{
            apiLastDispatchedMaterial()
        }else if from == "vendorInvoice"{
            apiVendorInvoice()
        }else if from == "vendorPay"{
            apiVendorPay()
        }else if from == "supplierInvoice"{
            apiSupplierInv()
        }else if from == "supplierPay"{
            apiSupplierPay()
        }
        
    }
    
    //CollectionVIew Funcs...
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if from == "vendorOrder"{
            return (self.vendorListData.count + 1)
        }else if from == "vendorPay"{
            return (self.vendorPayData.count + 1)
        }else if from == "supplierInvoice"{
            return supplierListData.count + 1
        }else if from == "supplierPay"{
            return supplierPayData.count + 1
        }else {
            return (self.vendorData.count + 1)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellContentIdentifier,
                                                      for: indexPath) as! CollectionViewCell
        cell.layer.borderWidth = 1
        cell.layer.borderColor = UIColor.white.cgColor
        if indexPath.section == 0 {
            cell.contentLabel.font = UIFont(name: "Roboto-Medium", size: 16)
            if #available(iOS 11.0, *) {
                cell.backgroundColor = UIColor.init(named: "Primary")
            } else {
                cell.backgroundColor = UIColor.gray
            }
            if indexPath.row == 0 {
                cell.contentLabel.text = "Date/PDF"
            } else if indexPath.row == 1 {
                cell.contentLabel.text = "Amount"
            }else if indexPath.row == 2 {
                cell.contentLabel.text = "Invoice No"
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
                cell.contentLabel.font = UIFont(name: "Roboto-Regular", size: 14)
                if #available(iOS 11.0, *) {
                    cell.backgroundColor = UIColor.init(named: "primaryLight")
                } else {
                    cell.backgroundColor = UIColor.lightGray
                }
                if indexPath.row == 0 {
                    cell.contentLabel.text = printDate(indexPath: indexPath)
                } else if indexPath.row == 1 {
                    cell.contentLabel.text = printAmount(indexPath: indexPath)
                } else if indexPath.row == 2 {
                    cell.contentLabel.text = printInv(indexPath: indexPath)
                }
            
        }
        
        return cell
        
    }
 
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == 0 && from != "vendorPay" && from != "supplierPay"{
            sendValue(indexPath: indexPath)
        }
    }
    
    func printDate(indexPath: IndexPath) -> String{
        switch from {
        case "vendorOrder":
            return "\(self.vendorListData[indexPath.section-1].date ?? "") 🔖"
        case "vendorInvoice":
            return "\(self.vendorData[indexPath.section-1].date ?? "") 🔖"
        case "vendorPay":
            return "\(self.vendorPayData[indexPath.section-1].date ?? "")"
        case "supplierInvoice":
            return "\(self.supplierListData[indexPath.section-1].date ?? "") 🔖"
        case "supplierPay":
            return "\(self.supplierPayData[indexPath.section-1].date ?? "")"
        default:
            return ""
        }
    }
    
    func printAmount(indexPath: IndexPath) -> String{
        switch from {
        case "vendorOrder":
            return Utility.formatRupee(amount: Double(self.vendorListData[indexPath.section-1].amount! ))
        case "vendorInvoice":
            return Utility.formatRupee(amount: Double(self.vendorData[indexPath.section-1].amount! ))
        case "vendorPay":
            return Utility.formatRupee(amount: Double(self.vendorPayData[indexPath.section-1].amount! ))
        case "supplierInvoice":
            return Utility.formatRupee(amount: Double(self.supplierListData[indexPath.section-1].amount! ))
        case "supplierPay":
            return Utility.formatRupee(amount: Double(self.supplierPayData[indexPath.section-1].amount! ))
        default:
            return ""
        }
    }
    
    func printInv(indexPath: IndexPath) -> String{
        switch from {
        case "vendorOrder":
            return self.vendorListData[indexPath.section-1].invoiceNo ?? "-"
        case "vendorInvoice":
            return self.vendorData[indexPath.section-1].invoiceNo ?? "-"
        case "vendorPay":
            return self.vendorPayData[indexPath.section-1].voucherNo ?? "-"
        case "supplierInvoice":
            return self.supplierListData[indexPath.section-1].invoiceNo ?? "-"
        case "supplierPay":
            return self.supplierPayData[indexPath.section-1].voucherNo ?? "-"
        default:
            return ""
        }
    }
    
    func sendValue(indexPath: IndexPath){
        
        if from == "vendorOrder"{
            toSend = vendorListData[indexPath.section-1].fileurl!
        }else if from == "vendorInvoice"{
            toSend = vendorData[indexPath.section-1].fileurl!
        }else if from == "supplierInvoice"{
            toSend = supplierListData[indexPath.section-1].fileurl!
        }
        if toSend == ""{
            let alert = UIAlertController(title: title, message: "No Data Found", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        performSegue(withIdentifier: "openPDF", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "openPDF") {
            if let destination = segue.destination as? viewPDFController,
                let _ = collectionView.indexPathsForSelectedItems?.first{
                destination.webvwUrl = toSend
            }
        }
        
    }
    
    //API CALLS
    func apiLastDispatchedMaterial(){
        self.noDataView.showView(view: self.noDataView, from: "LOADER")
        //self.collectionView.showNoData = true
        
        let json: [String: Any] =  ["VendorId":cinRecieved,"CIN":UserDefaults.standard.value(forKey: "userCIN") as! String, "Cat":UserDefaults.standard.value(forKey: "userCategory") as! String,"index":"0","Count":"500","ClientSecret":"ohdashfl"]
        print("Vendor Order Params \(json)")
        DataManager.shared.makeAPICall(url: vendorListApi, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            
            DispatchQueue.main.async {
                do {
                    self.vendorInvoiceStruct = try JSONDecoder().decode([VendorOrderStruct].self, from: data!)
                    self.vendorInvoiceStructObj = self.vendorInvoiceStruct[0].data
                    print("Vendor Order Data \(self.vendorInvoiceStructObj[0].purchaseAndLedgerBalanceOrderNoVendordata)")
                    self.vendorListData = self.vendorInvoiceStructObj[0].purchaseAndLedgerBalanceOrderNoVendordata
                    self.collectionView.reloadData()
                    self.collectionView.collectionViewLayout.invalidateLayout()
                    ViewControllerUtils.sharedInstance.removeLoader()
                    //self.DispatchedMaterialArray.append(contentsOf: self.DispatchedMaterialDataMain[0].dispatchdata)
                    
                } catch let errorData {
                    ViewControllerUtils.sharedInstance.removeLoader()
                    print(errorData.localizedDescription)
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
            }
        }) { (Error) in
            self.noDataView.showView(view: self.noDataView, from: "ERR")
            //self.collectionView.showNoData = true
            ViewControllerUtils.sharedInstance.removeLoader()
            print(Error?.localizedDescription)
        }
    }
    
    func apiVendorInvoice(){
        self.noDataView.showView(view: self.noDataView, from: "LOADER")
        
        let json: [String: Any] =  ["VendorId":cinRecieved,"CIN":UserDefaults.standard.value(forKey: "userCIN") as! String, "Cat":UserDefaults.standard.value(forKey: "userCategory") as! String,"index":"0","Count":"500","ClientSecret":"ohdashfl"]
        print("Vendor Invoice Params \(json)")
        DataManager.shared.makeAPICall(url: vendorInvApi, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            
            DispatchQueue.main.async {
                do {
                    self.vendorInvoice = try JSONDecoder().decode([VendorInvoiceStruct].self, from: data!)
                    self.vendorInvoiceObj = self.vendorInvoice[0].data
                    print("Vendor Invoice Data \(self.vendorInvoiceObj[0].purchaseAndLedgerBalanceInvoiceNoVendordata)")
                    self.vendorData = self.vendorInvoiceObj[0].purchaseAndLedgerBalanceInvoiceNoVendordata
                    
                    ViewControllerUtils.sharedInstance.removeLoader()
                    //self.DispatchedMaterialArray.append(contentsOf: self.DispatchedMaterialDataMain[0].dispatchdata)
                    
                } catch let errorData {
                    ViewControllerUtils.sharedInstance.removeLoader()
                    print("Caught Error \(errorData.localizedDescription)")
                }
                
                if(self.vendorData.count > 0)
                {
                    self.collectionView.reloadData()
                    self.collectionView.collectionViewLayout.invalidateLayout()
                    self.noDataView.hideView(view: self.noDataView)
                }
                else
                {
                    self.noDataView.showView(view: self.noDataView, from: "NDA")
                }
            }
        }) { (Error) in
            ViewControllerUtils.sharedInstance.removeLoader()
            self.noDataView.showView(view: self.noDataView, from: "ERR")
            print(Error?.localizedDescription)
        }
    }
    
    func apiVendorPay(){
        self.noDataView.showView(view: self.noDataView, from: "LOADER")
        
        let json: [String: Any] =  ["VendorId":cinRecieved,"CIN":UserDefaults.standard.value(forKey: "userCIN") as! String, "Cat":UserDefaults.standard.value(forKey: "userCategory") as! String,"index":"0","Count":"500","ClientSecret":"ohdashfl"]
        print("Vendor Invoice Params \(json)")
        DataManager.shared.makeAPICall(url: vendorPayApi, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            
            DispatchQueue.main.async {
                do {
                    self.vendorPay = try JSONDecoder().decode([VendorPayStuct].self, from: data!)
                    self.vendorPayObj = self.vendorPay[0].data
                    print("Vendor Invoice Data \(self.vendorPayObj[0].purchaseAndLedgerBalancePaymentVendordata)")
                    self.vendorPayData = self.vendorPayObj[0].purchaseAndLedgerBalancePaymentVendordata
                    self.collectionView.reloadData()
                    self.collectionView.collectionViewLayout.invalidateLayout()
                    ViewControllerUtils.sharedInstance.removeLoader()
                    //self.DispatchedMaterialArray.append(contentsOf: self.DispatchedMaterialDataMain[0].dispatchdata)
                    
                } catch let errorData {
                    ViewControllerUtils.sharedInstance.removeLoader()
                    print(errorData.localizedDescription)
                }
                
                if(self.vendorListData.count > 0)
                {
                    self.noDataView.hideView(view: self.noDataView)
                }
                else
                {
                    self.noDataView.showView(view: self.noDataView, from: "NDA")
                }
            }
        }) { (Error) in
            self.noDataView.showView(view: self.noDataView, from: "ERR")
            ViewControllerUtils.sharedInstance.removeLoader()
            print(Error?.localizedDescription)
        }
    }
    
    func apiSupplierInv(){
        self.noDataView.showView(view: self.noDataView, from: "LOADER")
        
        let json: [String: Any] =  ["SupplierId":cinRecieved,"CIN":UserDefaults.standard.value(forKey: "userCIN") as! String, "Cat":UserDefaults.standard.value(forKey: "userCategory") as! String,"index":"0","Count":"5","ClientSecret":"ohdashfl"]
        print("supplier Invoice Params \(json)")
        DataManager.shared.makeAPICall(url: supplierInvoiceApi, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            
            DispatchQueue.main.async {
                do {
                    self.supplierInvoiceStruct = try JSONDecoder().decode([SupplierInvoiceStruct].self, from: data!)
                    self.supplierInvoiceStructObj = self.supplierInvoiceStruct[0].data
                    print("supplier Invoice Data \(self.supplierInvoiceStructObj[0].purchaseAndLedgerBalanceInvoiceNoSupplierdata)")
                    self.supplierListData = self.supplierInvoiceStructObj[0].purchaseAndLedgerBalanceInvoiceNoSupplierdata
                    self.collectionView.reloadData()
                    self.collectionView.collectionViewLayout.invalidateLayout()
                    ViewControllerUtils.sharedInstance.removeLoader()
                    //self.DispatchedMaterialArray.append(contentsOf: self.DispatchedMaterialDataMain[0].dispatchdata)
                    
                } catch let errorData {
                    ViewControllerUtils.sharedInstance.removeLoader()
                    print(errorData.localizedDescription)
                }
                
            }
        }) { (Error) in
            self.noDataView.showView(view: self.noDataView, from: "ERR")
            ViewControllerUtils.sharedInstance.removeLoader()
            print(Error?.localizedDescription)
        }
    }
    
    func apiSupplierPay(){
        self.noDataView.showView(view: self.noDataView, from: "LOADER")
        
        let json: [String: Any] =  ["SupplierId":cinRecieved,"CIN":UserDefaults.standard.value(forKey: "userCIN") as! String, "Cat":UserDefaults.standard.value(forKey: "userCategory") as! String,"index":"0","Count":"500","ClientSecret":"ohdashfl"]
        print("Supp Pay Params \(json)")
        DataManager.shared.makeAPICall(url: supplierPayApi, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            
            DispatchQueue.main.async {
                do {
                    self.supplierPayStruct = try JSONDecoder().decode([SupplierPaymentStruct].self, from: data!)
                    self.supplierPayStructObj = self.supplierPayStruct[0].data
                    print("Supp Pay Data \(self.supplierPayStructObj[0].purchaseAndLedgerBalancePaymentSupplierdata)")
                    self.supplierPayData = self.supplierPayStructObj[0].purchaseAndLedgerBalancePaymentSupplierdata
                    self.collectionView.reloadData()
                    self.collectionView.collectionViewLayout.invalidateLayout()
                    ViewControllerUtils.sharedInstance.removeLoader()
                    //self.DispatchedMaterialArray.append(contentsOf: self.DispatchedMaterialDataMain[0].dispatchdata)
                    
                } catch let errorData {
                    ViewControllerUtils.sharedInstance.removeLoader()
                    print(errorData.localizedDescription)
                }
                
                
                if(self.vendorListData.count > 0)
                {
                    self.noDataView.hideView(view: self.noDataView)
                }
                else
                {
                    self.noDataView.showView(view: self.noDataView, from: "NDA")
                }
            }
        }) { (Error) in
            self.noDataView.showView(view: self.noDataView, from: "ERR")
            ViewControllerUtils.sharedInstance.removeLoader()
            print(Error?.localizedDescription)
        }
    }
    
}
