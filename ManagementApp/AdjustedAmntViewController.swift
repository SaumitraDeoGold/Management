//
//  AdjustedAmntViewController.swift
//  DealorsApp
//
//  Created by Goldmedal on 4/28/18.
//  Copyright © 2018 Goldmedal. All rights reserved.
//

import UIKit
import FirebaseAnalytics


class AdjustedAmntViewController:  UIViewController , UITableViewDelegate , UITableViewDataSource {
    
    @IBOutlet weak var viewHeight: NSLayoutConstraint!
    
    var salesAdjustedAmntData = [AdjustedAmntElement]()
    var salesAdjustedAmntArray = [AdjustedAmntArray]()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var imvClose: UIImageView!
    @IBOutlet weak var vwClose: UIView!
    
    var strCin = ""
    var strType = String()
    var intSlno = Int()
    var callFrom = String()
    var adjustedAmntApi=""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let loginData =  UserDefaults.standard.value(forKey: "loginData") as? Dictionary ?? [:]
        strCin = loginData["userlogid"] as? String ?? ""
        
        let initialData =  UserDefaults.standard.value(forKey: "initialData") as? Dictionary ?? [:]
        if(callFrom.isEqual("SalesPayment")){
            adjustedAmntApi = (initialData["baseApi"] as? String ?? "")+""+(initialData["salesPaymentReportDetails"] as? String ?? "")
        }else if(callFrom.isEqual("CreditDebit")){
            adjustedAmntApi = (initialData["baseApi"] as? String ?? "")+""+(initialData["creditNoteDetails"] as? String ?? "")
        }
        
        // Do any additional setup after loading the view.
        if (Utility.isConnectedToNetwork()) {
            print("Internet connection available")
            OperationQueue.main.addOperation {
                self.apiSalesAdjustedAmnt()
            }
        }
        else{
            print("No internet connection available")
            
            var alert = UIAlertView(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
        }
        
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        
        let tabClose = UITapGestureRecognizer(target: self, action: #selector(self.tapFunction))
        vwClose.addGestureRecognizer(tabClose)
    }
    
    @objc func tapFunction(sender:UITapGestureRecognizer) {
        print("tap working")
        dismiss(animated: true)
    }
    
    
    func apiSalesAdjustedAmnt(){
        ViewControllerUtils.sharedInstance.showLoader()
        
        var json: [String: Any]? = nil
        
        if(callFrom.isEqual("SalesPayment")){
            json = ["CIN":strCin,"SlNo":intSlno]
        }else if(callFrom.isEqual("CreditDebit")){
            json = ["ClientSecret":"201010","CIN":strCin,"SlNo":intSlno,"Type":strType]
        }
        
        print(json)
        
        DataManager.shared.makeAPICall(url: adjustedAmntApi, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            DispatchQueue.main.async {
                do {
                    self.salesAdjustedAmntData = try JSONDecoder().decode([AdjustedAmntElement].self, from: data!)
                    self.salesAdjustedAmntArray = self.salesAdjustedAmntData[0].data
                    
                } catch let errorData {
                    print(errorData.localizedDescription)
                }
                
                if(self.salesAdjustedAmntArray.count == 0){
                    var alert = UIAlertView(title: "No Data Available", message: "No Data Available", delegate: nil, cancelButtonTitle: "OK")
                    alert.show()
                    
                    self.dismiss(animated: true)
                }
                
                
                if(self.tableView != nil)
                {
                    self.tableView.reloadData()
                    self.viewHeight.constant = CGFloat((self.salesAdjustedAmntArray.count*40)+80)
                }
                
            }
            ViewControllerUtils.sharedInstance.removeLoader()
        }) { (Error) in
            ViewControllerUtils.sharedInstance.removeLoader()
            print(Error?.localizedDescription)
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "AdjustedAmntCell", for: indexPath) as! AdjustedAmntCell
        
        cell.lblInvDetail.text = (salesAdjustedAmntArray[indexPath.row].invoice ?? "-")+"\n("+(salesAdjustedAmntArray[indexPath.row].invoiceDate ?? "-")+")"
        
        if var adjustedAmount = salesAdjustedAmntArray[indexPath.row].adjustedAmount as? String {
            cell.lblAdjustedAmnt.text = Utility.formatRupee(amount: Double(adjustedAmount)!)
        }
        
        return cell
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return salesAdjustedAmntArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
}
