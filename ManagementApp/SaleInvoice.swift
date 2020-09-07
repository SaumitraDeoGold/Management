//
//  SaleInvoice.swift
//  ManagementApp
//
//  Created by Goldmedal on 26/08/20.
//  Copyright © 2020 Goldmedal. All rights reserved.
//
struct SaleInvData: Codable {
    let result: Bool?
    let message, servertime: String?
    let data: [SaleInvArr]
}

// MARK: - Datum
struct SaleInvArr: Codable {
    let saleAndLedgerBalanceInvoiceNoVendordata: [SaleInvObj]
    let ismore: Bool?
}

// MARK: - SaleAndLedgerBalanceInvoiceNoVendordatum
struct SaleInvObj: Codable {
    let slno: Int?
    let invoiceNo, date: String?
    let fileurl: String?
    let amount: Double?
}
import Foundation
import UIKit
@IBDesignable class SaleInvoice: BaseCustomView {
     
    var dateFormatter = DateFormatter()
    var strCin = ""
    var strToDate = ""
    let contentCellIdentifier = "\(ContentCollectionViewCell.self)"
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var vendorInvoiceStruct = [SaleInvData]()
    var vendorInvoiceStructObj = [SaleInvArr]()
    var vendorListData = [SaleInvObj]()
    
    @IBOutlet weak var noDataView: NoDataView!
    
    var vendorListApi = ""
    
    @IBOutlet weak var collectionView: SaleInvCollectionVw!
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func xibSetup() {
        super.xibSetup()
        
        self.noDataView.hideView(view: self.noDataView)
        
        let loginData =  UserDefaults.standard.value(forKey: "loginData") as? Dictionary ?? [:]
        strCin = loginData["userlogid"] as? String ?? ""
        
        //let initialData =  UserDefaults.standard.value(forKey: "initialData") as? Dictionary ?? [:]
        vendorListApi = "https://test2.goldmedalindia.in/api/getsaleinvoicevendor"
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
    
    @IBAction func clicked_all_invoice(_ sender: UIButton) {
        let allInvoices = parentViewController?.storyboard?.instantiateViewController(withIdentifier: "AllInvoice") as! AllInvoiceViewController
        allInvoices.cinRecieved = appDelegate.sendCin
        allInvoices.from = "saleInvoice"
        parentViewController?.navigationController!.pushViewController(allInvoices, animated: true)
    }
    
    
    func apiLastDispatchedMaterial(){
        self.noDataView.showView(view: self.noDataView, from: "LOADER")
        self.collectionView.showNoData = true
        
        let json: [String: Any] =  ["VendorId":appDelegate.sendCin,"CIN":UserDefaults.standard.value(forKey: "userCIN") as! String, "Cat":UserDefaults.standard.value(forKey: "userCategory") as! String,"index":"0","Count":"5","ClientSecret":"ohdashfl"]
        print("Sale Invoice Params \(json)")
        DataManager.shared.makeAPICall(url: vendorListApi, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            
            DispatchQueue.main.async {
                do {
                    self.vendorInvoiceStruct = try JSONDecoder().decode([SaleInvData].self, from: data!)
                    self.vendorInvoiceStructObj = self.vendorInvoiceStruct[0].data
                    print("Sale Invoice Data \(self.vendorInvoiceStructObj[0].saleAndLedgerBalanceInvoiceNoVendordata)")
                    self.vendorListData = self.vendorInvoiceStructObj[0].saleAndLedgerBalanceInvoiceNoVendordata
                    
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
            }
        }) { (Error) in
            self.noDataView.showView(view: self.noDataView, from: "ERR")
            self.collectionView.showNoData = true
            print(Error?.localizedDescription)
        }
    }
    
    func getIndianDate(value: String) -> String{
        let inFormatDate1 = value.split{$0 == " "}.map(String.init)
        let inFormatDate = inFormatDate1[0].split{$0 == "/"}.map(String.init)
        let temp = "\(inFormatDate[1])/\(inFormatDate[0])/\(inFormatDate[2])"
        return temp
    }
    
    
    func clickPdf(sender: UITapGestureRecognizer)
    {
        
//        print("pdf name : \(sender.view!.tag)")
//
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


extension SaleInvoice: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return  (self.vendorListData.count + 1)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
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
                cell.contentLabel.text = "Date/PDF"
            } else if indexPath.row == 1 {
                cell.contentLabel.text = "Amount"
            }else if indexPath.row == 2 {
                cell.contentLabel.text = "Invoice"
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
                    cell.contentView.addSubview(imageview)
                    cell.contentLabel.textAlignment = .left
                    cell.contentLabel.text = "    \(getIndianDate(value: vendorListData[indexPath.section-1].date!))"
                } else if indexPath.row == 1 {
                    cell.contentLabel.text = Utility.formatRupee(amount: Double(self.vendorListData[indexPath.section-1].amount! ))
                } else if indexPath.row == 2 {
                    cell.contentLabel.text = self.vendorListData[indexPath.section-1].invoiceNo ?? "-"
                }
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == 0{
            if vendorListData[indexPath.section-1].fileurl == ""{
                var alert = UIAlertView(title: "Alert", message: "No Data Found", delegate: nil, cancelButtonTitle: "OK")
                alert.show()
                return
            }
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "Webview") as! viewPDFController
            vc.webvwUrl = vendorListData[indexPath.section-1].fileurl!
            parentViewController?.navigationController!.pushViewController(vc, animated: true)
            //performSegue(withIdentifier: "byWebview", sender: self)
        }
    }
    
    
    
}

// MARK: - UICollectionViewDelegate
extension SaleInvoice: UICollectionViewDelegate {
    
}



class SaleInvCollectionVw: UICollectionView {
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
