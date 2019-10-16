//
//  AgingReportView.swift
//  DealorsApp
//
//  Created by Goldmedal on 8/7/18.
//  Copyright © 2018 Goldmedal. All rights reserved.
//

import UIKit
@IBDesignable class AgingReportView: BaseCustomView {
    
    @IBOutlet weak var btnDownloadPdf: UIButton!
    @IBOutlet weak var tblAgingReport: IntrinsicTableView!
    
    var AgingReportMain = [AgingReportElement]()
    var AgingReportData = [AgingReportObj]()
    
    var AgingReportArr = [AgingDetail]()
    var AgingReportPdf = [Agingurl]()
    var strCin = ""
    var strPdfUrl = ""
    var agingReportApi=""
    
    let cellIdentifier = "\(DashAgingCell.self)"
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
     @IBOutlet weak var noDataView: NoDataView!
    
    override func xibSetup() {
        super.xibSetup()
        
         self.noDataView.hideView(view: self.noDataView)
        
        let loginData =  UserDefaults.standard.value(forKey: "loginData") as? Dictionary ?? [:]
        strCin = loginData["userlogid"] as? String ?? ""
        
        let initialData =  UserDefaults.standard.value(forKey: "initialData") as? Dictionary ?? [:]
        agingReportApi = (initialData["baseApi"] as? String ?? "")+""+(initialData["aging"] as? String ?? "")
        
        tblAgingReport.register(UINib(nibName: cellIdentifier, bundle: nil), forCellReuseIdentifier: cellIdentifier)
        
        if (Utility.isConnectedToNetwork()) {
             apiAgingReport()
        }
        else{
            self.noDataView.showView(view: self.noDataView, from: "NET")
            self.tblAgingReport.showNoData = true
        }
       
    }
    
    @IBAction func clicked_download_pdf(_ sender: UIButton) {
        guard let url = URL(string: strPdfUrl) else {
            
            var alert = UIAlertView(title: "Error", message: "Invalid Pdf", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
            
            return
        }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }

   
    
    func apiAgingReport(){
        self.noDataView.showView(view: self.noDataView, from: "LOADER")
        self.tblAgingReport.showNoData = true
        
        let json: [String: Any] = ["CIN":appDelegate.sendCin,"ClientSecret":"201020"]
        
        DataManager.shared.makeAPICall(url: agingReportApi, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            
            DispatchQueue.main.async {
            do {
                self.AgingReportMain = try JSONDecoder().decode([AgingReportElement].self, from: data!)
                
                self.AgingReportData = self.AgingReportMain[0].data
                
                self.AgingReportArr = self.AgingReportData[0].agingDetails
                
                self.AgingReportPdf = self.AgingReportData[0].agingurls
                
                self.strPdfUrl =  self.AgingReportPdf[0].url ?? ""
                
                let result = (self.AgingReportMain[0].result ?? false)!
             
            } catch let errorData {
                print(errorData.localizedDescription)
            }
                
                if(self.tblAgingReport != nil)
                { self.tblAgingReport.reloadData() }
                
                if(self.AgingReportArr.count > 0){
                    self.noDataView.hideView(view: self.noDataView)
                    self.tblAgingReport.showNoData = false
                }else{
                    self.noDataView.showView(view: self.noDataView, from: "NDA")
                    self.tblAgingReport.showNoData = true
                }
                
            }
        }) { (Error) in
            print(Error?.localizedDescription ?? "ERROR")
            self.noDataView.showView(view: self.noDataView, from: "ERR")
            self.tblAgingReport.showNoData = true
        }
    }
}





extension AgingReportView : UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 30
    }
}

extension AgingReportView : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return AgingReportArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! DashAgingCell
        
        cell.lblPeriod.text = AgingReportArr[indexPath.row].days ?? "-"
        
        if var amount = AgingReportArr[indexPath.row].amount as? String {
             cell.lblAmount.text = Utility.formatRupee(amount: Double(amount)!)
        }
       
        return cell
    }
    
}

