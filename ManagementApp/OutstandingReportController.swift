//
//  OutstandingReportController.swift
//  DealorsApp
//
//  Created by Goldmedal on 4/7/18.
//  Copyright © 2018 Goldmedal. All rights reserved.
//

import UIKit
import FirebaseAnalytics

class OutstandingReportController: UIViewController , UITableViewDelegate , UITableViewDataSource,PopupDateDelegate {
    
    @IBOutlet weak var imvBack: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var lblDueAmnt: UILabel!
    @IBOutlet weak var lblOverDueAmnt: UILabel!
    @IBOutlet weak var lblDivision: UILabel!
    @IBOutlet weak var lblOutsAmnt: UILabel!
    
    @IBOutlet weak var btnOutstanding: RoundButton!
    @IBOutlet weak var btnDivision: RoundButton!
    
    var OutstandingReportElementMain = [OutstandingReportElement]()
    var OutstandingReportDataMain = [OutstandingReportData]()
    var OutstandingReportArray = [OutstandingReportObject]()
    
    @IBOutlet weak var noDataView: NoDataView!
    
    var fromIndex = 0
    let batchSize = 10
    var ismore = true
    var strCin = ""
    var intDivid = 0
    var intOutsDays = 2500
    var strDivname = "ALL"
    var outstandingReportApi=""

    override func viewDidLoad() {
        super.viewDidLoad()
        
         self.noDataView.hideView(view: self.noDataView)
        
        let loginData =  UserDefaults.standard.value(forKey: "loginData") as? Dictionary ?? [:]
        strCin = loginData["userlogid"] as? String ?? ""
        
        let initialData =  UserDefaults.standard.value(forKey: "initialData") as? Dictionary ?? [:]
        outstandingReportApi = (initialData["baseApi"] as? String ?? "")+""+(initialData["outstandingReport"] as? String ?? "")

        // Do any additional setup after loading the view.
        if (Utility.isConnectedToNetwork()) {
            print("Internet connection available")
            OperationQueue.main.addOperation {
            self.OutstandingReportArray.removeAll()
            self.apiOutstandingReport()
            }
            self.noDataView.hideView(view: self.noDataView)
        }
        else{
            print("No internet connection available")
            
            var alert = UIAlertView(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
            
             self.noDataView.showView(view: self.noDataView, from: "NET")
        }
       
        
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        
        let tabBack = UITapGestureRecognizer(target: self, action: #selector(OutstandingReportController.tapFunction))
        imvBack.addGestureRecognizer(tabBack)
        
        Analytics.setScreenName("OUTSTANDING REPORT SCREEN", screenClass: "OutstandingReportController")
    }
    
    @objc func tapFunction(sender:UITapGestureRecognizer) {
        print("back")
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func clicked_division(_ sender: UIButton) {
        let sb = UIStoryboard(name: "DivisionPicker", bundle: nil)
        let popup = sb.instantiateInitialViewController() as? DivisionPicker
        popup?.delegate = self
        self.present(popup!, animated: true)
    }
    
    
    @IBAction func clicked_outstanding(_ sender: UIButton) {
        let sb = UIStoryboard(name: "OrderType", bundle: nil)
        let popup = sb.instantiateInitialViewController() as? OrderTypeViewController
        popup?.delegate = self
        popup?.showPicker = 1
        self.present(popup!, animated: true)
    }
    
    
    func updatePositionValue(value: String, position: Int, from: String) {
        if(from == "ORDER")
        {
            btnOutstanding.setTitle(value, for: .normal)
            intOutsDays = position
        }
        
        if(from == "DIVISION"){
            btnDivision.setTitle(value, for: .normal)
             intDivid = position
             strDivname = value
           
        }
  
        self.OutstandingReportArray.removeAll()
        self.OutstandingReportDataMain.removeAll()
        fromIndex = 0
        apiOutstandingReport()
    }
    
    func apiOutstandingReport() {
        ViewControllerUtils.sharedInstance.showLoader()

        let json: [String: Any] = ["CIN":strCin,"ClientSecret":"201020","Division":intDivid,"OutstangingDays":intOutsDays,"Index":fromIndex,"Count":batchSize]
        
        print("OUTSTANDING REPORT DETAIL ----",json)
        
        DataManager.shared.makeAPICall(url: outstandingReportApi, params: json, method: .POST, success: { (response) in
            let data = response as? Data
             DispatchQueue.main.async {
            do {
                self.OutstandingReportElementMain = try JSONDecoder().decode([OutstandingReportElement].self, from: data!)
                self.OutstandingReportDataMain = self.OutstandingReportElementMain[0].data
                self.OutstandingReportArray.append(contentsOf:self.OutstandingReportDataMain[0].outstandingdata)
                self.ismore = (self.OutstandingReportDataMain[0].ismore ?? false)!
           
                if var dueAmnt = self.OutstandingReportDataMain[0].totaldueoverdue[0].due as? String {
                    self.lblDueAmnt.text = Utility.formatRupee(amount: Double(dueAmnt)!)
                }
                
                if var overdueAmnt = self.OutstandingReportDataMain[0].totaldueoverdue[0].overDue as? String {
                    self.lblOverDueAmnt.text = Utility.formatRupee(amount: Double(overdueAmnt)!)
                }
           
                self.lblDivision.text = self.strDivname ?? "-"
                
                if var outstandingAmnt = self.OutstandingReportDataMain[0].totaloutstanding[0].ouststandingAmt as? String {
                    self.lblOutsAmnt.text = Utility.formatRupee(amount: Double(outstandingAmnt)!)
                }
                
                 ViewControllerUtils.sharedInstance.removeLoader()
            } catch let errorData {
                print(errorData.localizedDescription)
                
                self.lblDueAmnt.text = "-"
                self.lblOverDueAmnt.text = "-"
                self.lblDivision.text = self.strDivname
                self.lblOutsAmnt.text = "-"
                
                 ViewControllerUtils.sharedInstance.removeLoader()
            }
                
               
                    if(self.tableView != nil)
                    {
                        self.tableView.reloadData()
                    }
                
               if(self.OutstandingReportArray.count>0){
                    self.noDataView.hideView(view: self.noDataView)
                }else{
                    self.noDataView.showView(view: self.noDataView, from: "NDA")
                }
                
          }
           
        }) { (Error) in
            ViewControllerUtils.sharedInstance.removeLoader()
            print(Error?.localizedDescription)
            self.noDataView.showView(view: self.noDataView, from: "ERR")
        }
        
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return OutstandingReportArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
   
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        let cell = tableView.dequeueReusableCell(withIdentifier: "OutstandingReportCell", for: indexPath) as! OutstandingReportCell
        
        cell.lblDueDays.text = OutstandingReportArray[indexPath.row].dueDays ?? "-"
        cell.lblInvoiceNo.text = OutstandingReportArray[indexPath.row].invoiceNo ?? "-"
        cell.lblInvoiceDate.text = OutstandingReportArray[indexPath.row].invoiceDate ?? "-"
     
        if var invoiceAmnt = OutstandingReportArray[indexPath.row].invoiceAmt as? String {
            cell.lblinvoiceAmnt.text = Utility.formatRupee(amount: Double(invoiceAmnt)!)
        }
        if var OutsAmnt = OutstandingReportArray[indexPath.row].ouststandingAmt as? String {
           cell.lblOutsAmnt.text = Utility.formatRupee(amount: Double(OutsAmnt)!)
        }
        cell.lblDivision.text = OutstandingReportArray[indexPath.row].divisionName?.capitalized ?? "-"
        
        print(indexPath.row," --------------------------------------",OutstandingReportArray.count)
        
        if indexPath.row == OutstandingReportArray.count - 1 {
            
            if self.ismore {
                fromIndex = fromIndex + 10// last cell
                apiOutstandingReport()
            }else{
                print("No more items")
            }
        }
        
        return cell
    }
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    

 

}
