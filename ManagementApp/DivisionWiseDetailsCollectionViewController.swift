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
    var dataFromPay = [BranchPay]()
    var totalSales = [TotalSale]()
    var salesData = [TotalSaleobj]()
    var saleDetail = [Saledetail]()
    var saleDetailTotal = SaledetailsTotal(wiringdevicetotal: "", lightetotal: "", wireandcabletotal: "", pipesandfittingtotal: "", mcbanddbtotal: "")
    var totalPay = [TotalPay]()
    var payData = [TotalPayObj]()
    var payDetail = [Paymentdetail]()
    var payDetailTotal = PaymentdetailsTotal(wiringdevicetotal: "", lightetotal: "", wireandcabletotal: "", pipesandfittingtotal: "", mcbanddbtotal: "")
    var TotalSalesApiUrl = "https://api.goldmedalindia.in/api/getTotalSaleDivisionWiseManagement"
    var TotalPayApiUrl = "https://api.goldmedalindia.in/api/getTotalPaymentDivisionWiseManagement"
    var index = 0
    var count = 20
    var isMore = true
    var dateTo = ""
    var dateFrom = ""
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var fromSales = ""
    
    @IBOutlet weak var detailView: UICollectionView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var cellContentIdentifier = "\(DetailViewCell.self)"
    override func viewDidLoad() {
        super.viewDidLoad()
        //print(dataToRecieve[0].branchid!)
        ViewControllerUtils.sharedInstance.showLoader()
        if fromSales == "yes"{
        apiTotalSaleDivisionWise()
        }else{
            apiTotalPayDivisionWise()
        }
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if collectionView == self.detailView{
            if fromSales == "yes"{
                return saleDetail.count + 1
            }else{
                return payDetail.count + 1
            }
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
                cell.contentLabel.text = (fromSales == "yes") ? saleDetail[indexPath.section - 1].partynm : payDetail[indexPath.section - 1].partynm
                if fromSales == "yes"{
                if saleDetail[indexPath.section - 1].partystatus != "Active"{
                    cell.contentLabel.textColor = UIColor(named: "ColorRed")
                }else{
                    cell.contentLabel.textColor = UIColor.black
                    }}else{
                    
                }
            case 1:
                cell.contentLabel.textColor = UIColor.black
                if let wiringdevices = (fromSales == "yes") ? saleDetail[indexPath.section - 1].wiringdevices : payDetail[indexPath.section - 1].wiringdevices
                {
                    cell.contentLabel.text = Utility.formatRupee(amount: Double(wiringdevices )!)
                }
            case 2:
                if let lights = (fromSales == "yes") ? saleDetail[indexPath.section - 1].lights : payDetail[indexPath.section - 1].lights
                {
                    cell.contentLabel.text = Utility.formatRupee(amount: Double(lights )!)
                }
            case 3:
                if let wireandcable = (fromSales == "yes") ? saleDetail[indexPath.section - 1].wireandcable : payDetail[indexPath.section - 1].wireandcable
                {
                    cell.contentLabel.text = Utility.formatRupee(amount: Double(wireandcable )!)
                }
            case 4:
                if let pipesandfittings = (fromSales == "yes") ? saleDetail[indexPath.section - 1].pipesandfittings : payDetail[indexPath.section - 1].pipesandfittings
                {
                    cell.contentLabel.text = Utility.formatRupee(amount: Double(pipesandfittings )!)
                }
            case 5:
                if let mcbanddbs = (fromSales == "yes") ? saleDetail[indexPath.section - 1].mcbanddbs : payDetail[indexPath.section - 1].mcbanddbs
                {
                    cell.contentLabel.text = Utility.formatRupee(amount: Double(mcbanddbs  )!)
                }
            case 6:
                let totalSum = (fromSales == "yes") ? Double(saleDetail[indexPath.section - 1].wiringdevices!)! + Double(saleDetail[indexPath.section - 1].lights!)! +
                    Double(saleDetail[indexPath.section - 1].wireandcable!)! + Double(saleDetail[indexPath.section - 1].pipesandfittings!)! + Double(saleDetail[indexPath.section - 1].mcbanddbs!)! : Double(payDetail[indexPath.section - 1].wiringdevices!)! + Double(payDetail[indexPath.section - 1].lights!)! +
                    Double(payDetail[indexPath.section - 1].wireandcable!)! + Double(payDetail[indexPath.section - 1].pipesandfittings!)! + Double(payDetail[indexPath.section - 1].mcbanddbs!)!
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
                    cell.contentLabel.text = (fromSales == "yes") ? "WD ₹" + saleDetailTotal.wiringdevicetotal! : "WD ₹" +  payDetailTotal.wiringdevicetotal!
                case 2:
                    cell.contentLabel.text = (fromSales == "yes") ? "Lights ₹" + saleDetailTotal.lightetotal! : "WD ₹" +  payDetailTotal.lightetotal!
                case 3:
                    cell.contentLabel.text = (fromSales == "yes") ? "Wire & Cable ₹" + saleDetailTotal.wireandcabletotal! : "WD ₹" +  payDetailTotal.wireandcabletotal!
                case 4:
                    cell.contentLabel.text = (fromSales == "yes") ? "Pipes & Fittings ₹" + saleDetailTotal.pipesandfittingtotal! : "WD ₹" +  payDetailTotal.pipesandfittingtotal!
                case 5:
                    cell.contentLabel.text = (fromSales == "yes") ? "Mcb & Dbs ₹" + saleDetailTotal.mcbanddbtotal! : "WD ₹" +  payDetailTotal.mcbanddbtotal!
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
            if fromSales == "yes"{
            if indexPath.section == (saleDetail.count-1){
                //print("Index \(indexPath.section) and isMore \((isMore)) count \(saleDetail.count)")
                if isMore{
                    index = index + 20
                    apiTotalSaleDivisionWise()
                }
            }
            }else{
                if indexPath.section == (payDetail.count-1){
                    //print("Index \(indexPath.section) and isMore \((isMore)) count \(saleDetail.count)")
                    if isMore{
                        index = index + 20
                        apiTotalPayDivisionWise()
                    }
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if (indexPath.section) > 0{
            appDelegate.sendCin = (fromSales == "yes") ? saleDetail[indexPath.section-1].cin! : payDetail[indexPath.section-1].cin!
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

    func apiTotalPayDivisionWise(){
        
        let json: [String: Any] = ["CIN":UserDefaults.standard.value(forKey: "userCIN") as! String,"Category":UserDefaults.standard.value(forKey: "userCategory") as! String,"BranchId":dataFromPay[0].branchid!,"FromDate":dateFrom,"ToDate":dateTo,"ClientSecret":"ClientSecret","index":index,"count":count]
        print("DivisionWiseDetails \(json)")
        let manager =  DataManager.shared
        
        manager.makeAPICall(url: TotalPayApiUrl, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            
            do {
                self.totalPay = try JSONDecoder().decode([TotalPay].self, from: data!)
                self.payData  = self.totalPay[0].data
                self.payDetailTotal = PaymentdetailsTotal(wiringdevicetotal: self.payData[0].paymentdetailsTotal.wiringdevicetotal!, lightetotal: self.payData[0].paymentdetailsTotal.lightetotal!, wireandcabletotal: self.payData[0].paymentdetailsTotal.wireandcabletotal!, pipesandfittingtotal: self.payData[0].paymentdetailsTotal.pipesandfittingtotal!, mcbanddbtotal: self.payData[0].paymentdetailsTotal.mcbanddbtotal!)
                for data in 0...(self.payData[0].paymentdetails.count-1) {
                    self.payDetail.append(self.payData[0].paymentdetails[data])
                }
                self.detailView.reloadData()
                self.detailView.collectionViewLayout.invalidateLayout()
                self.collectionView.reloadData()
                self.collectionView.collectionViewLayout.invalidateLayout()
                ViewControllerUtils.sharedInstance.removeLoader()
                self.isMore = self.payData[0].ismore!
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
