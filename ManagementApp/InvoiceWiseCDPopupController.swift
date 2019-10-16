//
//  InvoiceWiseCDPopupController.swift
//  DealorsApp
//
//  Created by Goldmedal on 3/19/19.
//  Copyright © 2019 Goldmedal. All rights reserved.
//

import UIKit


class InvoiceWiseCDPopupController: UIViewController, UITableViewDelegate , UITableViewDataSource {
    
    @IBOutlet weak var viewHeight: NSLayoutConstraint!
    
    var OutsInvoiceWiseCdElementMain = [OutsInvoiceWiseCdElement]()
    var OutsInvoiceWiseCdArrMain = [OutsInvoiceWiseCdObj]()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var imvClose: UIImageView!
    @IBOutlet weak var lblInvoiceHeader: UILabel!
    @IBOutlet weak var vwClose: UIView!
    @IBOutlet weak var lblInvoiceNo: UILabel!
    
    var strInvNo = String()
    var outsAmount = String()
    var extraDiscount = Double()
    
    var savedAmount = 0
    var payableAmount = 0
    
    var strCin = ""
    var invoiceWiseCDApi=""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let loginData =  UserDefaults.standard.value(forKey: "loginData") as? Dictionary ?? [:]
        strCin = loginData["userlogid"] as? String ?? ""
        
        let initialData =  UserDefaults.standard.value(forKey: "initialData") as? Dictionary ?? [:]
       // invoiceWiseCDApi = "https://api.goldmedalindia.in//api/getInvoicewiseCD"
        invoiceWiseCDApi = (initialData["baseApi"] as? String ?? "")+""+(initialData["invoicewiseCD"] as? String ?? "")
        
        lblInvoiceNo.text = strInvNo
        
        // Do any additional setup after loading the view.
        if (Utility.isConnectedToNetwork()) {
            print("Internet connection available")
            OperationQueue.main.addOperation {
                self.apiInvoiceWiseCD()
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
    
    
    func apiInvoiceWiseCD(){
        ViewControllerUtils.sharedInstance.showLoader()
        
        let json: [String: Any] = ["CIN":strCin,"ClientSecret":"201020","InvoiceNo":strInvNo]
        
        DataManager.shared.makeAPICall(url: invoiceWiseCDApi, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            DispatchQueue.main.async {
                do {
                    self.OutsInvoiceWiseCdElementMain = try JSONDecoder().decode([OutsInvoiceWiseCdElement].self, from: data!)
                    self.OutsInvoiceWiseCdArrMain = self.OutsInvoiceWiseCdElementMain[0].data
                    
                } catch let errorData {
                    print(errorData.localizedDescription)
                }
                
                if(self.tableView != nil)
                {
                    self.tableView.reloadData()
                    self.viewHeight.constant = CGFloat((self.OutsInvoiceWiseCdArrMain.count*40)+80)
                }
                
                
                if(self.OutsInvoiceWiseCdArrMain.count == 0){
                    var alert = UIAlertView(title: "No Data available", message: "No Data available", delegate: nil, cancelButtonTitle: "OK")
                    alert.show()
                    
                    self.dismiss(animated: true)
                }
                
            }
            ViewControllerUtils.sharedInstance.removeLoader()
        }) { (Error) in
            ViewControllerUtils.sharedInstance.removeLoader()
            print(Error?.localizedDescription)
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "InvoiceWiseCDCell", for: indexPath) as! InvoiceWiseCDCell
        
        cell.lblDueDate.text = OutsInvoiceWiseCdArrMain[indexPath.row].duedate ?? "-"
        cell.lblDueDays.text = OutsInvoiceWiseCdArrMain[indexPath.row].duedays ?? "-"
        
        var totalSavedPercent = Double(OutsInvoiceWiseCdArrMain[indexPath.row].percentage ?? "0.0")! + self.extraDiscount
        
        cell.lblCDPercent.text = String(totalSavedPercent ?? 0.0) + "%"
        
        savedAmount = Int(Double(Double(outsAmount ?? "0")! * totalSavedPercent/100).rounded())
        
        payableAmount = Int(outsAmount ?? "0")! - savedAmount
    
            
        cell.lblSavedAmount.text = Utility.formatRupee(amount: Double(savedAmount))
        cell.lblPayableAmount.text = Utility.formatRupee(amount: Double(payableAmount))
       
        return cell
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return OutsInvoiceWiseCdArrMain.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
}

