//
//  YearlySalesView.swift
//  DealorsApp
//
//  Created by Goldmedal on 8/4/18.
//  Copyright © 2018 Goldmedal. All rights reserved.
//

import UIKit
@IBDesignable class YearlySalesView: BaseCustomView{
    
    @IBOutlet weak var tblYearlySales: IntrinsicTableView!
    @IBOutlet weak var noDataView: NoDataView!
    
    var YearlySalesMain = [YearlySalesAgreementElement]()
    var YearlySalesDataObj = [YearlySalesData]()
    var YsadetailData = [Ysadetail]()
    var strCin = ""
     let cellIdentifier = "\(YearlySalesCell.self)"
    var yearlySalesViewApi=""
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func xibSetup() {
        super.xibSetup()
        
         self.noDataView.hideView(view: self.noDataView)
        
        self.tblYearlySales.delegate = self;
        self.tblYearlySales.dataSource = self;
        
        let loginData =  UserDefaults.standard.value(forKey: "loginData") as? Dictionary ?? [:]
        strCin = loginData["userlogid"] as? String ?? ""
        
        let initialData =  UserDefaults.standard.value(forKey: "initialData") as? Dictionary ?? [:]
        yearlySalesViewApi = (initialData["baseApi"] as? String ?? "")+""+(initialData["ysAreport"] as? String ?? "")
        
        tblYearlySales.register(UINib(nibName: cellIdentifier, bundle: nil), forCellReuseIdentifier: cellIdentifier)
        
        if (Utility.isConnectedToNetwork()) {
             apiYearlySalesAgreement()
        }
        else{
            self.noDataView.showView(view: self.noDataView, from: "NET")
            self.tblYearlySales.showNoData = true
        }
    }
    
    func apiYearlySalesAgreement(){
        self.noDataView.showView(view: self.noDataView, from: "LOADER")
        self.tblYearlySales.showNoData = true
        
        let json: [String: Any] = ["CIN":appDelegate.sendCin,"ClientSecret":"201020"]
        
        DataManager.shared.makeAPICall(url: yearlySalesViewApi, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            
             DispatchQueue.main.async {
            do {
                self.YearlySalesMain = try JSONDecoder().decode([YearlySalesAgreementElement].self, from: data!)
                
                self.YearlySalesDataObj = self.YearlySalesMain[0].data
                
                self.YsadetailData = self.YearlySalesDataObj[0].ysadetails
            
            } catch let errorData {
                print(errorData.localizedDescription)
            }
                
                if(self.tblYearlySales != nil)
                { self.tblYearlySales.reloadData() }
                
                if(self.YsadetailData.count > 0){
                    self.noDataView.hideView(view: self.noDataView)
                    self.tblYearlySales.showNoData = false
                }else{
                    self.noDataView.showView(view: self.noDataView, from: "NDA")
                    self.tblYearlySales.showNoData = true
                }
                
            }
        }) { (Error) in
            print(Error?.localizedDescription)
            self.noDataView.showView(view: self.noDataView, from: "ERR")
            self.tblYearlySales.showNoData = true
        }
        
    }
}

    extension YearlySalesView : UITableViewDelegate {
        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
           return 60
        }
    }
    
    extension YearlySalesView : UITableViewDataSource {
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return YsadetailData.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! YearlySalesCell
            
            cell.lblDivision.text = YsadetailData[indexPath.row].groupnm?.capitalized ?? "-"
            
            var ysaTotal = 0.0
            var salesTotal = 0.0
            
            if var Ysa = YsadetailData[indexPath.row].ysa as? String {
                cell.lblYsa.text = Utility.formatRupee(amount: Double(Ysa)!)
                ysaTotal = Double(Ysa)!
            }
            
            if var Sales = YsadetailData[indexPath.row].sale as? String {
                 cell.lblSales.text = Utility.formatRupee(amount: Double(Sales)!)
                 salesTotal = Double(Sales)!
            }
            
            
            cell.lblOverallChg.text = Utility.formatRupee(amount: salesTotal - ysaTotal)
           
        
            if Double(YsadetailData[indexPath.row].ysa ?? "0.0")! > 0
            {
                cell.lblOverallPercent.text = String(format: "%.2f",((Double(YsadetailData[indexPath.row].sale ?? "0.0")!-Double(YsadetailData[indexPath.row].ysa!)!)/Double(YsadetailData[indexPath.row].ysa!)!)*100)+"%"
            }
            else{
                cell.lblOverallPercent.text = "-"
            }
            
            
            return cell
        }
    }

