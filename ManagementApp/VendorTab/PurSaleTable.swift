//
//  PurSaleTable.swift
//  ManagementApp
//
//  Created by Goldmedal on 26/08/20.
//  Copyright © 2020 Goldmedal. All rights reserved.
//
 struct PurSale: Codable {
     let result: Bool?
     let message, servertime: String?
     let data: [PurSaleObj]
 }

 // MARK: - Datum
 struct PurSaleObj: Codable {
     let month, sale, purchase, diffrence: String?
     let jv, payment: String?
 }
import Foundation
import UIKit
@IBDesignable class PurSaleTable: BaseCustomView, PopupDateDelegate {
     
    var dateFormatter = DateFormatter()
    var strCin = ""
    var strToDate = ""
    let contentCellIdentifier = "\(ContentCollectionViewCell.self)"
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var purSale = [PurSale]()
    var purSaleObj = [PurSaleObj]()
    var opType = 3
    var opValue = 0
    var currPosition = 0
    var callFrom = 0
    var finYear = "2020-2021"
    
    @IBOutlet weak var noDataView: NoDataView!
    @IBOutlet weak var lblDate: UILabel!
    
    var PurSaleApi = ""
    
    @IBOutlet weak var collectionView: PurSaleCollnVw!
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func xibSetup() {
        super.xibSetup()
        
        self.noDataView.hideView(view: self.noDataView)
        
        let loginData =  UserDefaults.standard.value(forKey: "loginData") as? Dictionary ?? [:]
        strCin = loginData["userlogid"] as? String ?? ""
        let gesture = UITapGestureRecognizer(target: self, action: #selector(self.clickDropdown))
        lblDate.isUserInteractionEnabled = true
        lblDate.addGestureRecognizer(gesture)
        //let initialData =  UserDefaults.standard.value(forKey: "initialData") as? Dictionary ?? [:]
        PurSaleApi = "https://test2.goldmedalindia.in/api/getvendorsalepurchasemonthwise"
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
    
    @objc func clickDropdown(_ sender:UITapGestureRecognizer){
        //lblFinYear.text = "Financial Year"
        let sb = UIStoryboard(name: "CustomYearPicker", bundle: nil)
        let popup = sb.instantiateInitialViewController()! as! CustomYearPickerController
        popup.modalPresentationStyle = .overFullScreen
        popup.delegate = self
        popup.showPicker = 3
        parentViewController!.present(popup, animated: true)
        callFrom = 0
        opType = 3
        opValue = 0
    }
    
    func updatePositionValue(value: String, position: Int, from: String) {
        ViewControllerUtils.sharedInstance.showLoader()
        switch callFrom {
        case 0:
            lblDate.text = "\(value) ▼"
            finYear = value
            apiLastDispatchedMaterial()
        
        default:
            print("Error")
        }
        
        
    }
    
    
    func apiLastDispatchedMaterial(){
        self.noDataView.showView(view: self.noDataView, from: "LOADER")
        self.collectionView.showNoData = true
        
        let json: [String: Any] =  ["CIN":UserDefaults.standard.value(forKey: "userCIN") as! String, "Category":UserDefaults.standard.value(forKey: "userCategory") as! String,"Finyear":finYear,"Vendor":appDelegate.sendCin,"ClientSecret":"ohdashfl"]
        print("Sale Invoice Params \(json)")
        DataManager.shared.makeAPICall(url: PurSaleApi, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            
            DispatchQueue.main.async {
                do {
                    self.purSale = try JSONDecoder().decode([PurSale].self, from: data!)
                    self.purSaleObj = self.purSale[0].data
                    print("purSale  Data \(self.purSaleObj)")
                    //self.DispatchedMaterialArray.append(contentsOf: self.DispatchedMaterialDataMain[0].dispatchdata)
                    
                } catch let errorData {
                    ViewControllerUtils.sharedInstance.removeLoader()
                    print(errorData.localizedDescription)
                }
                
                if(self.collectionView != nil)
                {
                    self.collectionView.reloadData()
                }
                ViewControllerUtils.sharedInstance.removeLoader()
                if(self.purSaleObj.count > 0)
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
            ViewControllerUtils.sharedInstance.removeLoader()
            self.noDataView.showView(view: self.noDataView, from: "ERR")
            self.collectionView.showNoData = true
            print(Error?.localizedDescription)
        }
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


extension PurSaleTable: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return  (self.purSaleObj.count + 1)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 6
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
                cell.contentLabel.text = "Month"
            } else if indexPath.row == 1 {
                cell.contentLabel.text = "Sale (Including Tax)"
            }else if indexPath.row == 2 {
                cell.contentLabel.text = "Purchase (Including Tax)"
            } else if indexPath.row == 3 {
                cell.contentLabel.text = "Difference"
            }else if indexPath.row == 4 {
                cell.contentLabel.text = "JV"
            }else if indexPath.row == 5 {
                cell.contentLabel.text = "Payment"
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
            if(self.purSaleObj.count > 0)
            {
                if indexPath.row == 0 {
                    cell.contentLabel.text = "    \(self.purSaleObj[indexPath.section-1].month ?? "")"
                } else if indexPath.row == 1 {
                    cell.contentLabel.text = Utility.formatRupee(amount: Double(self.purSaleObj[indexPath.section-1].sale! )!)
                }else if indexPath.row == 2 {
                    cell.contentLabel.text = Utility.formatRupee(amount: Double(self.purSaleObj[indexPath.section-1].purchase! )!)
                }else if indexPath.row == 3 {
                    cell.contentLabel.text = Utility.formatRupee(amount: Double(self.purSaleObj[indexPath.section-1].diffrence! )!)
                }else if indexPath.row == 4 {
                    cell.contentLabel.text = Utility.formatRupee(amount: Double(self.purSaleObj[indexPath.section-1].jv! )!)
                }else if indexPath.row == 5 {
                    cell.contentLabel.text = Utility.formatRupee(amount: Double(self.purSaleObj[indexPath.section-1].payment! )!)
                }
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
extension PurSaleTable: UICollectionViewDelegate {
    
}



class PurSaleCollnVw: UICollectionView {
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
