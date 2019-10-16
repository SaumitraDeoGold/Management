//
//  OrderSummaryViewController.swift
//  DealorsApp
//
//  Created by Goldmedal on 12/1/18.
//  Copyright © 2018 Goldmedal. All rights reserved.
//

import UIKit
import FirebaseAnalytics


class OrderSummaryViewController: BaseViewController , UITableViewDelegate , UITableViewDataSource {

    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var noDataView: NoDataView!
    var dateFormatter = DateFormatter()
    var fromDate: Date?
    var toDate: Date?
    var strFromDate = ""
    var strToDate = ""
    var strCin = ""
    @IBOutlet weak var btnToDate: UIButton!
    @IBOutlet weak var btnFromDate: UIButton!
    var orderSummaryApi=""
    var OrderSummaryElementMain = [OrderSummaryElement]()
    var OrderSummaryArr = [OrderSummaryObj]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        noDataView.hideView(view: noDataView)
        
        addSlideMenuButton()
        
        let currDate = Date()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        
        strToDate = dateFormatter.string(from: currDate)
        strFromDate = dateFormatter.string(from: Calendar.current.date(byAdding: .day, value: -90, to: currDate)!)
        
        btnFromDate.setTitle(strFromDate, for: .normal)
        btnToDate.setTitle(strToDate, for: .normal)
        
        strFromDate = Utility.formattedDateFromString(dateString: strFromDate, withFormat: "MM/dd/yyyy")!
        strToDate = Utility.formattedDateFromString(dateString: strToDate, withFormat: "MM/dd/yyyy")!
        
        let loginData =  UserDefaults.standard.value(forKey: "loginData") as? Dictionary ?? [:]
        strCin = loginData["userlogid"] as? String ?? ""
        
        let initialData =  UserDefaults.standard.value(forKey: "initialData") as? Dictionary ?? [:]
       // orderSummaryApi = (initialData["baseApi"] as? String ?? "")+""+(initialData["dispatchedMaterial"] as? String ?? "")
        orderSummaryApi = "https://api.goldmedalindia.in//api/GetOrderDetails"
        
        if (Utility.isConnectedToNetwork()) {
            print("Internet connection available")
            OperationQueue.main.addOperation {
                self.apiOrderSummary()
                self.noDataView.hideView(view: self.noDataView)
            }
        }
        else {
            print("No internet connection available")
            var alert = UIAlertView(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
            self.noDataView.showView(view: self.noDataView, from: "NET")
        }
        
        
        self.tableview.delegate = self;
        self.tableview.dataSource = self;
        
        Analytics.setScreenName("ORDER SUMMARY SCREEN", screenClass: "OrderSummaryViewController")
    }
    
    
    @IBAction func fromDate_clicked(_ sender: UIButton) {
        sender.isSelected = true
        let sb = UIStoryboard(name: "DatePicker", bundle: nil)
        
        let popup = sb.instantiateInitialViewController()  as? DatePickerController
        popup?.fromDate = fromDate
        popup?.toDate = toDate
        popup?.isFromDate = true
        popup?.delegate = self
        self.present(popup!, animated: true)
    }
    
    
    @IBAction func toDate_clicked(_ sender: UIButton) {
        sender.isSelected = true
        let sb = UIStoryboard(name: "DatePicker", bundle: nil)
        
        let popup = sb.instantiateInitialViewController()  as? DatePickerController
        popup?.delegate = self
        popup?.toDate = toDate
        popup?.fromDate = fromDate
        popup?.isFromDate = false
        self.present(popup!, animated: true)
    }
    
    
    func updateDate(value: String, date: Date) {
        if btnFromDate.isSelected {
            btnFromDate.setTitle(value, for: .normal)
            btnFromDate.isSelected = false
            fromDate = date
            strFromDate = Utility.formattedDateFromString(dateString: value, withFormat: "MM/dd/yyyy")!
        }
        else
        {
            btnToDate.setTitle(value, for: .normal)
            btnToDate.isSelected = false
            toDate = date
            strToDate = Utility.formattedDateFromString(dateString: value, withFormat: "MM/dd/yyyy")!
        }
        apiOrderSummary()
    }
    
    
    func apiOrderSummary(){
        ViewControllerUtils.sharedInstance.showLoader()
        
        let json: [String: Any] =
            ["CIN": strCin, "ClientSecret": "ClientSecret","FromDate":strFromDate,"ToDate":strToDate]
        
        print(" ORDER SUMMARY ------ ",json)
        
        DataManager.shared.makeAPICall(url: orderSummaryApi, params: json, method: .POST, success: { (response) in
            let data = response as? Data
         
            DispatchQueue.main.async {
                do {
                    self.OrderSummaryElementMain = try JSONDecoder().decode([OrderSummaryElement].self, from: data!)
                    self.OrderSummaryArr = self.OrderSummaryElementMain[0].data
                    
                    ViewControllerUtils.sharedInstance.removeLoader()
                } catch let errorData {
                    print(errorData.localizedDescription)
                    ViewControllerUtils.sharedInstance.removeLoader()
                }
            
                
                if(self.OrderSummaryArr.count > 0)
                {
                    if(self.tableview != nil)
                    {
                        self.tableview.reloadData()
                        self.tableview.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
                    }
                    
                    self.noDataView.hideView(view: self.noDataView)
                }
                else
                {
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
        return OrderSummaryArr.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "OrderSummaryCell", for: indexPath) as! OrderSummaryCell
       
            if let amount = OrderSummaryArr[indexPath.row].amount as? String {
                cell.lblOrderAmount.text = Utility.formatRupee(amount: Double(amount)!)
            }
            cell.lblPoNumber.text = OrderSummaryArr[indexPath.row].ponum
            cell.lblPoDate.text = OrderSummaryArr[indexPath.row].podt
            cell.lblPoTime.text = OrderSummaryArr[indexPath.row].potime
            cell.lblLogStatus.text = OrderSummaryArr[indexPath.row].logstatus

            let imvClickPdf = UITapGestureRecognizer(target: self, action: #selector(self.pdfTapped))
            cell.imvPdf.isUserInteractionEnabled = true
            cell.imvPdf.tag = indexPath.row
            cell.imvPdf.addGestureRecognizer(imvClickPdf)
     
        return cell
    }
    
    func pdfTapped(sender: UITapGestureRecognizer) {
        print("pdf name : \(sender.view?.tag)")
        
        guard let url = URL(string: OrderSummaryArr[sender.view!.tag].orderurl ?? "") else {
            var alert = UIAlertView(title: "Error", message: "Invalid Pdf", delegate: nil, cancelButtonTitle: "OK")
            alert.show()

            return
        }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  

}
