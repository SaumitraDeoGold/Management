//
//  LastDispatchesView.swift
//  DealorsApp
//
//  Created by Goldmedal on 8/7/18.
//  Copyright © 2018 Goldmedal. All rights reserved.
//

import Foundation
import UIKit
@IBDesignable class LastDispatchesView: BaseCustomView {
    
    var DispatchedMaterialElementMain = [DispatchedMaterialElement]()
    var DispatchedMaterialDataMain = [DispatchedMaterialData]()
    var DispatchedMaterialArray = [DispatchedMaterialObject]()
    var dateFormatter = DateFormatter()
    var strCin = ""
    var strToDate = ""
    let contentCellIdentifier = "\(ContentCollectionViewCell.self)"
    @IBOutlet weak var noDataView: NoDataView!
    
    var lastDispatchApi=""
    
    @IBOutlet weak var collectionView: IntrinsicCollectionView!
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func xibSetup() {
        super.xibSetup()
        
        self.noDataView.hideView(view: self.noDataView)
        
        let loginData =  UserDefaults.standard.value(forKey: "loginData") as? Dictionary ?? [:]
        strCin = loginData["userlogid"] as? String ?? ""
        
        let initialData =  UserDefaults.standard.value(forKey: "initialData") as? Dictionary ?? [:]
        lastDispatchApi = (initialData["baseApi"] as? String ?? "")+""+(initialData["dispatchedMaterial"] as? String ?? "")
        
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
        let dispatchedMaterial = parentViewController?.storyboard?.instantiateViewController(withIdentifier: "DispatchedMaterial") as! DispatchedMaterialController
        parentViewController?.navigationController!.pushViewController(dispatchedMaterial, animated: true)
        
    }
    
    
    func apiLastDispatchedMaterial(){
        self.noDataView.showView(view: self.noDataView, from: "LOADER")
        self.collectionView.showNoData = true
        
        let json: [String: Any] =
            ["CIN":"999999","ClientSecret":"ClientSecret","FromDate":"01/01/2018","ToDate":strToDate,"Index":0,"SearchText":"","Count":10]
        
        DataManager.shared.makeAPICall(url: lastDispatchApi, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            
            DispatchQueue.main.async {
                do {
                    self.DispatchedMaterialElementMain = try JSONDecoder().decode([DispatchedMaterialElement].self, from: data!)
                    self.DispatchedMaterialDataMain = self.DispatchedMaterialElementMain[0].data
                    
                    self.DispatchedMaterialArray = [DispatchedMaterialObject]()
                    
                    self.DispatchedMaterialArray.append(contentsOf: self.DispatchedMaterialDataMain[0].dispatchdata)
                    
                } catch let errorData {
                    print(errorData.localizedDescription)
                }
                
                if(self.collectionView != nil)
                {
                    self.collectionView.reloadData()
                }
                
                if(self.DispatchedMaterialArray.count > 0)
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
        
        guard let url = URL(string: DispatchedMaterialArray[sender.view!.tag].url ?? "") else {
            
            var alert = UIAlertView(title: "Error", message: "Invalid Pdf", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
            
            return
        }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
}


extension LastDispatchesView: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return  (self.DispatchedMaterialArray.count + 1)
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
                cell.contentLabel.text = "Date/PDF"
            } else if indexPath.row == 1 {
                cell.contentLabel.text = "Amount"
            }else if indexPath.row == 2 {
                cell.contentLabel.text = "Invoice"
            }else if indexPath.row == 3 {
                cell.contentLabel.text = "Division"
            }else if indexPath.row == 4 {
                cell.contentLabel.text = "Transporter"
            }else if indexPath.row == 5 {
                cell.contentLabel.text = "Lr No."
            }
        }
        
        let img = UIImage.init(named: "icon_dashboard_pdf")
        var imageview:UIImageView=UIImageView(frame: CGRect(x: 100, y: 10, width: 20, height: 20));
        imageview.image = img
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.clickPdf))
        imageview.addGestureRecognizer(tap)
        imageview.tag = indexPath.section-1
        imageview.isUserInteractionEnabled = true
        
        
        if indexPath.section != 0 {
            if(self.DispatchedMaterialArray.count > 0)
            {
                if indexPath.row == 0 {
                    cell.contentView.addSubview(imageview)
                    cell.contentLabel.textAlignment = .left
                    cell.contentLabel.text = "    \(self.DispatchedMaterialArray[indexPath.section-1].invoiceDate ?? "")"
                    
                } else if indexPath.row == 1 {
                    
                    if var lastDispatchtotal = self.DispatchedMaterialArray[indexPath.section-1].amount as? String
                    {
                        cell.contentLabel.text = Utility.formatRupee(amount: Double(lastDispatchtotal ?? "0.0")!)
                    }
                    
                } else if indexPath.row == 2 {
                    cell.contentLabel.text = self.DispatchedMaterialArray[indexPath.section-1].invoiceNo ?? "-"
                } else if indexPath.row == 3 {
                    cell.contentLabel.text = self.DispatchedMaterialArray[indexPath.section-1].division?.capitalized ?? "-"
                } else if indexPath.row == 4 {
                    cell.contentLabel.text = self.DispatchedMaterialArray[indexPath.section-1].transporterName?.capitalized ?? "-"
                } else if indexPath.row == 5 {
                    cell.contentLabel.text = self.DispatchedMaterialArray[indexPath.section-1].lrNo ?? "-"
                }
            }
        }
        
        return cell
    }
    
}

// MARK: - UICollectionViewDelegate
extension LastDispatchesView: UICollectionViewDelegate {
    
}



class IntrinsicCollectionView: UICollectionView {
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

