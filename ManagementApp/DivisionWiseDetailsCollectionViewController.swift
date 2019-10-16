//
//  DivisionWiseDetailsCollectionViewController.swift
//  G-Management
//
//  Created by Goldmedal on 08/03/19.
//  Copyright © 2019 Goldmedal. All rights reserved.
//

import UIKit

private let reuseIdentifier = "DetailViewCell"

class DivisionWiseDetailsCollectionViewController: UIViewController, PopupDateDelegate, UICollectionViewDataSource, UICollectionViewDelegate {
    
    var dataToRecieve = [BranchSale]()
    var totalSales = [TotalSale]()
    var salesData = [TotalSaleobj]()
    var saleDetail = [Saledetail]()
    var saleDetailTotal = SaledetailsTotal(wiringdevicetotal: "", lightetotal: "", wireandcabletotal: "", pipesandfittingtotal: "", mcbanddbtotal: "")
    var TotalSalesApiUrl = "https://test2.goldmedalindia.in/api/getTotalSaleDivisionWiseManagement"
    var index = 0
    var count = 20
    var isMore = true
    var dateTo = ""
    var dateFrom = ""
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet weak var detailView: UICollectionView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var cellContentIdentifier = "\(DetailViewCell.self)"
    override func viewDidLoad() {
        super.viewDidLoad()
        print(dataToRecieve[0].branchid!)
        ViewControllerUtils.sharedInstance.showLoader()
        apiTotalSaleDivisionWise()
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if collectionView == self.detailView{
            return saleDetail.count + 1
        }else{
            return 1
        }
    }


     func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 7
    }

     func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.detailView{
        let cell = detailView.dequeueReusableCell(withReuseIdentifier: cellContentIdentifier,
                                                                for: indexPath) as! DetailViewCell
        cell.layer.borderWidth = 1
        cell.layer.borderColor = UIColor.white.cgColor
        if indexPath.section == 0 {
            
            switch indexPath.row{
            case 0:
                cell.contentLabel.text = "Party Name"
//            case 1:
//                cell.contentLabel.text = "Executive Name"
            case 1:
                cell.contentLabel.text = "W D"
            case 2:
                cell.contentLabel.text = "Lights"
            case 3:
                cell.contentLabel.text = "W&C"
            case 4:
                cell.contentLabel.text = "P&F"
            case 5:
                cell.contentLabel.text = "Mcb&Dbs"
            case 6:
                cell.contentLabel.text = "Sum"
            default:
                break
            }
            cell.contentLabel.font = UIFont(name: "Roboto-Medium", size: 16)
            if #available(iOS 11.0, *) {
                cell.backgroundColor = UIColor.init(named: "Primary")
            } else {
                cell.backgroundColor = UIColor.gray
            }
        } else {
            switch indexPath.row{
            case 0:
                cell.contentLabel.text = saleDetail[indexPath.section - 1].partynm
                if saleDetail[indexPath.section - 1].partystatus != "Active"{
                    cell.contentLabel.textColor = UIColor(named: "ColorRed")
                }else{
                    cell.contentLabel.textColor = UIColor.black
                }
            case 1:
                cell.contentLabel.textColor = UIColor.black
                if let wiringdevices = saleDetail[indexPath.section - 1].wiringdevices
                {
                    cell.contentLabel.text = Utility.formatRupee(amount: Double(wiringdevices )!)
                }
            case 2:
                if let lights = saleDetail[indexPath.section - 1].lights
                {
                    cell.contentLabel.text = Utility.formatRupee(amount: Double(lights )!)
                }
            case 3:
                if let wireandcable = saleDetail[indexPath.section - 1].wireandcable
                {
                    cell.contentLabel.text = Utility.formatRupee(amount: Double(wireandcable )!)
                }
            case 4:
                if let pipesandfittings = saleDetail[indexPath.section - 1].pipesandfittings
                {
                    cell.contentLabel.text = Utility.formatRupee(amount: Double(pipesandfittings )!)
                }
            case 5:
                if let mcbanddbs = saleDetail[indexPath.section - 1].mcbanddbs
                {
                    cell.contentLabel.text = Utility.formatRupee(amount: Double(mcbanddbs  )!)
                }
            case 6:
                let totalSum = Double(saleDetail[indexPath.section - 1].wiringdevices!)! + Double(saleDetail[indexPath.section - 1].lights!)! +
                    Double(saleDetail[indexPath.section - 1].wireandcable!)! + Double(saleDetail[indexPath.section - 1].pipesandfittings!)! + Double(saleDetail[indexPath.section - 1].mcbanddbs!)!
                cell.contentLabel.text = Utility.formatRupee(amount: Double(totalSum  ))
                
            default:
                break
            }
            cell.contentLabel.font = UIFont(name: "Roboto-Medium", size: 14)
            if #available(iOS 11.0, *) {
                cell.backgroundColor = UIColor.init(named: "primaryLight")
            } else {
                cell.backgroundColor = UIColor.gray
            }
        }
        return cell
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellContentIdentifier,
                                                      for: indexPath) as! CollectionViewCell
            cell.layer.borderWidth = 1
            cell.layer.borderColor = UIColor.white.cgColor
            if indexPath.section == 0 {
                
                switch indexPath.row{
                case 0:
                    cell.contentLabel.text = "SUM"
//                case 1:
//                    cell.contentLabel.text = "Executive Names"
                case 1:
                    cell.contentLabel.text = "WD ₹" + saleDetailTotal.wiringdevicetotal!
                case 2:
                    cell.contentLabel.text = "Lights ₹" + saleDetailTotal.lightetotal!
                case 3:
                    cell.contentLabel.text = "Wire & Cable ₹" + saleDetailTotal.wireandcabletotal!
                case 4:
                    cell.contentLabel.text = "Pipes & Fittings ₹" + saleDetailTotal.pipesandfittingtotal!
                case 5:
                    cell.contentLabel.text = "Mcb & Dbs ₹" + saleDetailTotal.mcbanddbtotal!
                case 6:
                    cell.contentLabel.text = "SUM"
                default:
                    break
                }
                cell.contentLabel.font = UIFont(name: "Roboto-Medium", size: 14)
                if #available(iOS 11.0, *) {
                    cell.backgroundColor = UIColor.init(named: "Primary")
                } else {
                    cell.backgroundColor = UIColor.gray
                }
            }
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if collectionView == self.detailView{
            if indexPath.section == (saleDetail.count-1){
                print("Index \(indexPath.section) and isMore \((isMore)) count \(saleDetail.count)")
                if isMore{
                    index = index + 20
                    apiTotalSaleDivisionWise()
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if (indexPath.section) > 0{
            appDelegate.sendCin = saleDetail[indexPath.section-1].cin!
        }
    }
 
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        //Block Segue if branchname is clicked...
        if let index = detailView.indexPathsForSelectedItems?.first{
            if((index.section) > 0){
                return true
            }else{
                return false
            }
        }else{
            return false
        }

    }
    
    func apiTotalSaleDivisionWise(){
 
        let json: [String: Any] = ["CIN":UserDefaults.standard.value(forKey: "userCIN") as! String,"Category":UserDefaults.standard.value(forKey: "userCategory") as! String,"BranchId":dataToRecieve[0].branchid!,"FromDate":dateFrom,"ToDate":dateTo,"ClientSecret":"ClientSecret","index":index,"count":count]
        print("DivisionWiseDetails \(json)")
        let manager =  DataManager.shared
        
        manager.makeAPICall(url: TotalSalesApiUrl, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            
            do {
                self.totalSales = try JSONDecoder().decode([TotalSale].self, from: data!)
                self.salesData  = self.totalSales[0].data
                self.saleDetailTotal = SaledetailsTotal(wiringdevicetotal: self.salesData[0].saledetailsTotal.wiringdevicetotal!, lightetotal: self.salesData[0].saledetailsTotal.lightetotal!, wireandcabletotal: self.salesData[0].saledetailsTotal.wireandcabletotal!, pipesandfittingtotal: self.salesData[0].saledetailsTotal.pipesandfittingtotal!, mcbanddbtotal: self.salesData[0].saledetailsTotal.mcbanddbtotal!)
                for data in 0...(self.salesData[0].saledetails.count-1) {
                    self.saleDetail.append(self.salesData[0].saledetails[data])
                }
                self.detailView.reloadData()
                self.detailView.collectionViewLayout.invalidateLayout()
                self.collectionView.reloadData()
                self.collectionView.collectionViewLayout.invalidateLayout()
                ViewControllerUtils.sharedInstance.removeLoader()
                self.isMore = self.salesData[0].ismore!
            } catch let errorData {
                print(errorData.localizedDescription)
                ViewControllerUtils.sharedInstance.removeLoader()
            }
        }) { (Error) in
            print(Error?.localizedDescription as Any)
                ViewControllerUtils.sharedInstance.removeLoader()
        }
        
    }

    


}
