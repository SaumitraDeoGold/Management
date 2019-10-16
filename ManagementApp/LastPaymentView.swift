//
//  LastPaymentView.swift
//  DealorsApp
//
//  Created by Goldmedal on 8/7/18.
//  Copyright © 2018 Goldmedal. All rights reserved.
//

import Foundation
import UIKit
@IBDesignable class LastPaymentView: BaseCustomView {
    
    @IBOutlet weak var tblLastPayment: IntrinsicTableView!
    @IBOutlet weak var noDataView: NoDataView!
    @IBOutlet weak var btnAllPayments: UIButton!
  
    var LastPaymentMain = [LastPaymentElement]()
    var LastPaymentData = [LastPaymentObj]()
    var LastPaymentArr = [Custrecieptdatum]()
    var strCin = ""
    var strToDate = ""
    var dateFormatter = DateFormatter()
    let cellIdentifier = "\(DashLastPaymentCell.self)"
    var lastPaymentApi=""
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func xibSetup() {
        super.xibSetup()
        
         self.noDataView.hideView(view: self.noDataView)
        
        // Do any additional setup after loading the view.
        self.tblLastPayment.delegate = self;
        self.tblLastPayment.dataSource = self;
        
        let currDate = Date()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        strToDate = dateFormatter.string(from: currDate)
        strToDate = Utility.formattedDateFromString(dateString: strToDate, withFormat: "MM/dd/yyyy")!
        
        let loginData =  UserDefaults.standard.value(forKey: "loginData") as? Dictionary ?? [:]
        strCin = loginData["userlogid"] as? String ?? ""
        
        let initialData =  UserDefaults.standard.value(forKey: "initialData") as? Dictionary ?? [:]
        lastPaymentApi = (initialData["baseApi"] as? String ?? "")+""+(initialData["salesPaymentReport"] as? String ?? "")
        
        tblLastPayment.register(UINib(nibName: cellIdentifier, bundle: nil), forCellReuseIdentifier: cellIdentifier)
        
        if (Utility.isConnectedToNetwork()) {
            apiLastPayment()
        }
        else{
            self.noDataView.showView(view: self.noDataView, from: "NET")
            self.tblLastPayment.showNoData = true
        }
    }
    
    
    @IBAction func clicked_all_payment(_ sender: UIButton) {
        let lastOutsPayment = parentViewController?.storyboard?.instantiateViewController(withIdentifier: "SalesPaymentReceipt") as! SalesPaymentController
        parentViewController?.navigationController?.pushViewController(lastOutsPayment, animated: true)
    }
    
    
    func apiLastPayment(){
        self.noDataView.showView(view: self.noDataView, from: "LOADER")
        self.tblLastPayment.showNoData = true
        
        let json: [String: Any] = ["Index":"0", "SearchText":"", "ToDate":strToDate, "ClientSecret":"ClientSecret", "FromDate":"01/01/2018", "CIN":appDelegate.sendCin, "Count":"5"]
        
        DataManager.shared.makeAPICall(url: lastPaymentApi, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            
             DispatchQueue.main.async {
            do {
                self.LastPaymentMain = try JSONDecoder().decode([LastPaymentElement].self, from: data!)
                
                self.LastPaymentData = self.LastPaymentMain[0].data
                
                self.LastPaymentArr = self.LastPaymentData[0].custrecieptdata
                
                let result = (self.LastPaymentMain[0].result ?? false)!
           
            ViewControllerUtils.sharedInstance.removeLoader()
            } catch let errorData {
                print(errorData.localizedDescription)
            }
            
            if(self.tblLastPayment != nil)
            { self.tblLastPayment.reloadData() }
                
                if(self.LastPaymentArr.count > 0){
                    self.noDataView.hideView(view: self.noDataView)
                    self.tblLastPayment.showNoData = false
                }else{
                    self.noDataView.showView(view: self.noDataView, from: "NDA")
                    self.tblLastPayment.showNoData = true
                }
        }
        }) { (Error) in
            print(Error?.localizedDescription ?? "ERROR")
            self.noDataView.showView(view: self.noDataView, from: "ERR")
            self.tblLastPayment.showNoData = true
        }
    }
  
}


extension LastPaymentView : UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 30
    }
}

extension LastPaymentView : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return LastPaymentArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! DashLastPaymentCell
        
        cell.lblDate.text = LastPaymentArr[indexPath.row].date ?? "-"
        if let amount = LastPaymentArr[indexPath.row].amount as? String {
          cell.lblAmount.text = Utility.formatRupee(amount: Double(amount)!)
        }
        cell.lblMode.text = LastPaymentArr[indexPath.row].instrumentType?.capitalized ?? "-"
        cell.lblStatus.text = LastPaymentArr[indexPath.row].status?.capitalized ?? "-"
        
        return cell
    }
    
}
