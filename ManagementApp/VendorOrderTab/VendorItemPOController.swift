//
//  VendorItemPOController.swift
//  ManagementApp
//
//  Created by Goldmedal on 12/08/20.
//  Copyright © 2020 Goldmedal. All rights reserved.
//
struct VendorItemPO: Codable {
    let result: Bool?
    let message, servertime: String?
    let data: [VendorItemPOObj]
}

// MARK: - Datum
struct VendorItemPOObj: Codable {
    let itemCode: String?
    let itemslno: String?
    let itemDescription: String?
    let subcategory: String?
    let quantity, basicAmt, finalAmt: String?
    let ponum: String?
}
import UIKit
class VendorItemPOController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    
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
    var vendorInvoiceStruct = [VendorItemPO]()
    var vendorListData = [VendorItemPOObj]()
    var fromPurchase = true
    var itemid = ""
    var itemDesc = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.noDataView.hideView(view: self.noDataView)
         self.title = itemDesc
//        self.collectionView.register(UINib(nibName: "ContentCollectionViewCell", bundle: nil),
//                                     forCellWithReuseIdentifier: self.contentCellIdentifier)
        
        if (Utility.isConnectedToNetwork()) {
            //if fromPurchase{
                apiLastDispatchedMaterial()
//            }else{
//                apiSalePending()
//            }
        }
        else{
            self.noDataView.showView(view: self.noDataView, from: "NET")
            //self.collectionView.showNoData = true
        }
 
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return  (self.vendorListData.count + 1)
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
                cell.contentLabel.text = "Item No"
            }else if indexPath.row == 1 {
                cell.contentLabel.text = "SubCategory"
            }else if indexPath.row == 2 {
                cell.contentLabel.text = "Qty"
            } else if indexPath.row == 5 {
                cell.contentLabel.text = "Offer Price"
            }else if indexPath.row == 3 {
                cell.contentLabel.text = "Po Num"
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
                    cell.contentLabel.text = self.vendorListData[indexPath.section-1].itemslno ?? "-"
                } else if indexPath.row == 1 {
                    cell.contentLabel.text = self.vendorListData[indexPath.section-1].subcategory ?? "-"
                } else if indexPath.row == 2 {
                    cell.contentLabel.text = vendorListData[indexPath.section-1].quantity
                } else if indexPath.row == 3 {
                    cell.contentLabel.text = self.vendorListData[indexPath.section-1].ponum ?? "-"
                } else if indexPath.row == 5 {
                    if let basicAmt = vendorListData[indexPath.section-1].basicAmt as? String {
                        cell.contentLabel.text = Utility.formatRupee(amount: Double(basicAmt)!)
                    }
                } else if indexPath.row == 4 {
                    if let finalAmt = vendorListData[indexPath.section-1].finalAmt as? String {
                        cell.contentLabel.text = Utility.formatRupee(amount: Double(finalAmt)!)
                    }
                }
            }
        }
        
        return cell
    }
    
    func getIdiotsDateFormat(value: String) -> String{
        let inFormatDate = value.split{$0 == "/"}.map(String.init)
        let temp = "\(inFormatDate[0])-\(inFormatDate[1])-\(inFormatDate[2])"
        return temp
    }
    
    func apiLastDispatchedMaterial(){
        self.noDataView.showView(view: self.noDataView, from: "LOADER")
        //self.collectionView.showNoData = true
        
        let json: [String: Any] =  ["vendorid":appDelegate.sendCin,"CIN":UserDefaults.standard.value(forKey: "userCIN") as! String, "Category":UserDefaults.standard.value(forKey: "userCategory") as! String,"index":"0","cnt":"1000","ClientSecret":"ohdashfl","FromDate":"06-27-2018","ToDate":"06-27-2020","ItemnId":itemid]
        print("Vendor ItemPO Params \(json)")
        DataManager.shared.makeAPICall(url: "https://test2.goldmedalindia.in/api/getvendorhighestsalespowise", params: json, method: .POST, success: { (response) in
            let data = response as? Data
             
                do {
                    self.vendorInvoiceStruct = try JSONDecoder().decode([VendorItemPO].self, from: data!)
                    self.vendorListData = self.vendorInvoiceStruct[0].data
                    print("Vendor ItemPO Data \(self.vendorListData)")
                    
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
     

}
