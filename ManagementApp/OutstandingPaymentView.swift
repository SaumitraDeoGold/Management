//
//  OutstandingPaymentView.swift
//  DealorsApp
//
//  Created by Goldmedal on 8/7/18.
//  Copyright © 2018 Goldmedal. All rights reserved.
//

import Foundation
import AMPopTip
import UIKit

@IBDesignable class OutstandingPaymentView: BaseCustomView {
   
    @IBOutlet weak var imvInfo: UIImageView!
    @IBOutlet weak var lblLedgerBalance: UILabel!
    @IBOutlet weak var lblDue: UILabel!
    @IBOutlet weak var lblOverDue: UILabel!
    @IBOutlet weak var tblOutstanding: IntrinsicTableView!
    @IBOutlet weak var vwOutstandingSales: UIView!
    let cellIdentifier = "\(DashOutstandingCell.self)"
    
    @IBOutlet weak var noDataView: NoDataView!
    
    var OutstandingPaymentMain = [OutstandingPaymentElement]()
    var OutstandingPaymentData = [OutstandingPaymentObj]()
    
    var OutstandingPaymentArr = [Outstandingdetail]()
    var OutstandingPaymentTotal = [Outstandingtotal]()
    
    var strCin = ""
    var outstandingDivisionWiseApi=""
    var txtToolTip = "Due amount is below 60 days & Overdue amount is above 60 days"
    let popTip = PopTip()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func xibSetup() {
        super.xibSetup()
        
        // Do any additional setup after loading the view.
        self.tblOutstanding.delegate = self;
        self.tblOutstanding.dataSource = self;
        
        self.noDataView.hideView(view: self.noDataView)
      
        let loginData =  UserDefaults.standard.value(forKey: "loginData") as? Dictionary ?? [:]
        strCin = loginData["userlogid"] as? String ?? ""
        
        let initialData =  UserDefaults.standard.value(forKey: "initialData") as? Dictionary ?? [:]
        outstandingDivisionWiseApi = (initialData["baseApi"] as? String ?? "")+""+(initialData["outstandingDivisionWise"] as? String ?? "")
        
        let tapInfo = UITapGestureRecognizer(target: self, action: #selector(self.tapFunction))
        imvInfo.addGestureRecognizer(tapInfo)
        
         tblOutstanding.register(UINib(nibName: cellIdentifier, bundle: nil), forCellReuseIdentifier: cellIdentifier)
        
        if (Utility.isConnectedToNetwork()) {
             apiOutstandingPayment()
        }
        else{
            self.noDataView.showView(view: self.noDataView, from: "NET")
            self.tblOutstanding.showNoData = true
        }
    }
    
    
    @objc func tapFunction(sender:UITapGestureRecognizer) {
        
        popTip.bubbleColor = UIColor.black
        popTip.show(text: txtToolTip, direction: .none, maxWidth: 300, in: vwOutstandingSales, from: vwOutstandingSales.frame)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.popTip.hide()
        }
    }
    
    
    
    func apiOutstandingPayment(){
        self.noDataView.showView(view: self.noDataView, from: "LOADER")
        self.tblOutstanding.showNoData = true
        
        let json: [String: Any] = ["CIN":appDelegate.sendCin,"ClientSecret":"201020"]
        
        DataManager.shared.makeAPICall(url: outstandingDivisionWiseApi, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            
             DispatchQueue.main.async {
            do {
                self.OutstandingPaymentMain = try JSONDecoder().decode([OutstandingPaymentElement].self, from: data!)
                self.OutstandingPaymentData = self.OutstandingPaymentMain[0].data
                self.OutstandingPaymentArr = self.OutstandingPaymentData[0].outstandingdetails
                self.OutstandingPaymentTotal = self.OutstandingPaymentData[0].outstandingtotal
                
                let result = (self.OutstandingPaymentMain[0].result ?? false)!
                
                 if result
                    {
                        if let dueAmount = self.OutstandingPaymentTotal[0].duetotal
                        {
                            self.lblDue.text =  Utility.formatRupee(amount: Double(dueAmount)!)
                        }
                        
                        if let overDueAmount = self.OutstandingPaymentTotal[0].overduetotal as? String
                        {
                            self.lblOverDue.text =  Utility.formatRupee(amount: Double(overDueAmount)!)
                        }
                        
                        if let outstandingtotal = self.OutstandingPaymentTotal[0].outstandingtotal as? String
                        {
                            self.lblLedgerBalance.text =  Utility.formatRupee(amount: Double(outstandingtotal)!)
                        }

                    }
               
            } catch let errorData {
                print(errorData.localizedDescription)
            }
            
                if(self.tblOutstanding != nil)
                {
                self.tblOutstanding.reloadData()
                }
                
                if(self.OutstandingPaymentArr.count > 0){
                    self.noDataView.hideView(view: self.noDataView)
                    self.tblOutstanding.showNoData = false
                }else{
                    self.noDataView.showView(view: self.noDataView, from: "NDA")
                    self.tblOutstanding.showNoData = true
                }
        }
        }) { (Error) in
            print(Error?.localizedDescription ?? "ERROR")
             self.noDataView.showView(view: self.noDataView, from: "ERR")
            self.tblOutstanding.showNoData = true
        }
    }
 
}


extension OutstandingPaymentView : UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45
    }
}

extension OutstandingPaymentView : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return OutstandingPaymentArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! DashOutstandingCell
        
        if var dueAmount = OutstandingPaymentArr[indexPath.row].due as? String
        {
            cell.lblDue.text =  Utility.formatRupee(amount: Double(dueAmount)!)
        }
        
        if var overDueAmount = OutstandingPaymentArr[indexPath.row].overdue as? String
        {
            cell.lblOverDue.text =  Utility.formatRupee(amount: Double(overDueAmount)!)
        }
        
        if var outstandingtotal = OutstandingPaymentArr[indexPath.row].outstanding as? String
        {
            cell.lblTotal.text =  Utility.formatRupee(amount: Double(outstandingtotal)!)
        }

        cell.lblDivision.text = OutstandingPaymentArr[indexPath.row].divisionnm?.capitalized ?? "-"
        
        return cell
    }
    
}


