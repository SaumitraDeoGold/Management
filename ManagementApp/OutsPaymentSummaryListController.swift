//
//  OutsPaymentSummaryListController.swift
//  DealorsApp
//
//  Created by Goldmedal on 3/11/19.
//  Copyright © 2019 Goldmedal. All rights reserved.
//

import UIKit
import FirebaseAnalytics
import DropDown

class OutsPaymentSummaryListController: BaseViewController , UITableViewDelegate , UITableViewDataSource , TransactionRetryDelegate {
   
     @IBOutlet weak var vwDropDownSummary: RoundView!
   // @IBOutlet weak var vwDropDown: RoundView!
    @IBOutlet weak var lblDropdownText: UILabel!
   
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var noDataView: NoDataView!
    var dateFormatter = DateFormatter()
    
    var fromDate: Date?
    var toDate: Date?
    var strFromDate = ""
    var strToDate = ""
    var strCin = ""
    var strTransactionId = ""
    
    var totalSavings = 0
    var payableAmount = 0
    
    var OutsPaymentSummaryListElementMain = [OutsPaymentSummaryListElement]()
    var OutsPaymentSummaryListArray = [OutsPaymentSummaryListObj]()
    
     var OutsSummaryFilteredListArray = [OutsPaymentSummaryListObj]()
    
    var OutstandingPaymentDetailElementMain = [OutstandingPaymentDetailReportElement]()
    var OutstandingPaymentDetailDataMain = [OutstandingPaymentDetailObj]()
    var OutstandingPaymentDetailArrayToPass = [OutsInvoiceObj]()
    
    @IBOutlet weak var btnToDate: UIButton!
    @IBOutlet weak var btnFromDate: UIButton!
    var outsPaymentSummaryApi = ""
    var strApiTransactionRetry = ""
    
    let dropDown = DropDown()
    
     let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var callFrom = String()
    
    var arrStatus = [String]()
    
    var filteredString = "ALL"

    override func viewDidLoad() {
        super.viewDidLoad()

        noDataView.hideView(view: noDataView)
        
        addSlideMenuButton()
        
        let currDate = Date()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        
        strToDate = dateFormatter.string(from: currDate)
        strFromDate = dateFormatter.string(from: Calendar.current.date(byAdding: .day, value: -30, to: currDate)!)
        
        fromDate = dateFormatter.date(from: strFromDate)
        toDate = dateFormatter.date(from: strToDate)
        
        btnFromDate.setTitle(strFromDate, for: .normal)
        btnToDate.setTitle(strToDate, for: .normal)
        
        strFromDate = Utility.formattedDateFromString(dateString: strFromDate, withFormat: "MM/dd/yyyy")!
        strToDate = Utility.formattedDateFromString(dateString: strToDate, withFormat: "MM/dd/yyyy")!
        
        let loginData =  UserDefaults.standard.value(forKey: "loginData") as? Dictionary ?? [:]
        strCin = loginData["userlogid"] as? String ?? ""
        
        let initialData =  UserDefaults.standard.value(forKey: "initialData") as? Dictionary ?? [:]
        outsPaymentSummaryApi = (initialData["baseApi"] as? String ?? "")+""+(initialData["freePayPayment"] as? String ?? "")
        strApiTransactionRetry = (initialData["baseApi"] as? String ?? "")+""+(initialData["retryFreepayPaymentTransaction"] as? String ?? "")
//        outsPaymentSummaryApi = "https://api.goldmedalindia.in/api/GetFreePayPayment"
//        strApiTransactionRetry = "https://api.goldmedalindia.in/api/RetryFreepayPaymentTransaction"
        
        if (Utility.isConnectedToNetwork()) {
            print("Internet connection available")
            OperationQueue.main.addOperation {
                self.apiOutsPaymentSummaryList()
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
        
        let gesture = UITapGestureRecognizer(target: self, action: "clickDropdown:")
        self.vwDropDownSummary.addGestureRecognizer(gesture)
        
        Analytics.setScreenName("OUTSTANDING PAYMENT SUMMARY LIST SCREEN", screenClass: "OutsPaymentSummaryListController")
//        SQLiteDB.instance.addAnalyticsData(ScreenName: "OUTSTANDING PAYMENT SUMMARY LIST SCREEN", ScreenId: Int64(GlobalConstants.init().OUTSTANDING_PAYMENT_SUMMARY_LIST))
        
        if(callFrom.elementsEqual("otp")){
             self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: makeBackButton())
        }
       
    }
    
    func makeBackButton() -> UIButton {
        let backButtonImage = UIImage(named: "left_arrow")?.withRenderingMode(.alwaysTemplate)
        let backButton = UIButton(type: .custom)
        backButton.frame = CGRect(x: 0, y: 0, width: 45, height: 45)
        backButton.setImage(backButtonImage, for: .normal)
        backButton.addTarget(self, action: #selector(self.backButtonPressed), for: .touchUpInside)
        return backButton
    }
    
    @objc func backButtonPressed() {
        dismiss(animated: true, completion: nil)
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
    
    @IBAction func refresh_list(_ sender: UIButton) {
      
        if (Utility.isConnectedToNetwork()) {
                self.apiOutsPaymentSummaryList()
                self.noDataView.hideView(view: self.noDataView)
        }
        else {
            print("No internet connection available")
            var alert = UIAlertView(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
            self.noDataView.showView(view: self.noDataView, from: "NET")
        }
        
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
        
        apiOutsPaymentSummaryList()
      
    }
    
    //  - - - - - - outstanding transaction history list - - - - - - - - - -
    func apiOutsPaymentSummaryList(){
        ViewControllerUtils.sharedInstance.showLoader()
        self.OutsPaymentSummaryListArray.removeAll()
        
        let json: [String: Any] =
          
            ["CIN":strCin,"ClientSecret":"ClientSecret","fromdate":strFromDate,"todate":strToDate]
        
        print("apiOutsPaymentSummaryList ------ ",json)
        
        DataManager.shared.makeAPICall(url: outsPaymentSummaryApi, params: json, method: .POST, success: { (response) in
            let data = response as? Data
          
            DispatchQueue.main.async {
                do {
                    self.OutsPaymentSummaryListElementMain = try JSONDecoder().decode([OutsPaymentSummaryListElement].self, from: data!)
                    self.OutsPaymentSummaryListArray = self.OutsPaymentSummaryListElementMain[0].data
                   
                    self.OutsSummaryFilteredListArray.removeAll()
                    self.OutsSummaryFilteredListArray.append(contentsOf: self.OutsPaymentSummaryListArray)
               
                    print("SUMMARY - - - - - ",self.OutsPaymentSummaryListArray)
                    
                    self.arrStatus.append("ALL")
                  
                    for i in self.OutsPaymentSummaryListArray
                    {
                        self.arrStatus.append(i.status ?? "-")
                    }
                    
                    let uniqueOrdered = Array(NSOrderedSet(array: self.arrStatus))
                    
                    self.dropDown.dataSource = uniqueOrdered as! [String]
                    
                  //  self.dropDown.dataSource = ["ALL","SUCCESS","CANCEL"]
                    
                    self.lblDropdownText.text = self.dropDown.dataSource[0]
                    
                    self.dropDown.dismissMode = .onTap
                    
                    if(self.tableview != nil)
                    {
                        self.tableview.reloadData()
                    }
                    
                    if(self.OutsSummaryFilteredListArray.count > 0)
                    {
                        self.noDataView.hideView(view: self.noDataView)
                    }
                    else
                    {
                        self.noDataView.showView(view: self.noDataView, from: "NDA")
                    }
                    
                    ViewControllerUtils.sharedInstance.removeLoader()
                    
                } catch let errorData {
                    print(errorData.localizedDescription)
                    ViewControllerUtils.sharedInstance.removeLoader()
                    self.noDataView.showView(view: self.noDataView, from: "NDA")
                }
                
               
            }
        }) { (Error) in
            ViewControllerUtils.sharedInstance.removeLoader()
            print(Error?.localizedDescription)
            self.noDataView.showView(view: self.noDataView, from: "ERR")
        }
    }
    
    
    @objc func clickDropdown(_ sender:UITapGestureRecognizer){
        
        dropDown.show()
        
        // The view to which the drop down will appear on
        dropDown.anchorView = vwDropDownSummary // UIView or UIBarButtonItem
        
        
        // Action triggered on selection
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            print("Selected item: \(item) at index: \(index)")
            self.lblDropdownText.text = item
         
            self.filteredString = item
            
            self.dropDown.hide()
            
            self.OutsSummaryFilteredListArray.removeAll()
            
            if(self.filteredString.elementsEqual("ALL")){
                self.OutsSummaryFilteredListArray.append(contentsOf: self.OutsPaymentSummaryListArray)
            }else{
                self.OutsSummaryFilteredListArray = self.OutsPaymentSummaryListArray.filter({($0.status ?? "-")!.elementsEqual(self.filteredString)})
            }
            print("List - - - ",self.OutsSummaryFilteredListArray.count)
            
             self.tableview.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
            
            self.tableview.reloadData()
           
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         print("List - - - ",self.OutsSummaryFilteredListArray.count)
        return OutsSummaryFilteredListArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 240
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "OutsPaymentSummaryCell", for: indexPath) as! OutsPaymentSummaryCell
     
        if let discountAmount = OutsSummaryFilteredListArray[indexPath.row].discoumtamt as? Int {
            cell.lblDiscoumtamt.text = Utility.formatRupee(amount: Double(discountAmount))
        }
        
        if let savedAmount = OutsSummaryFilteredListArray[indexPath.row].savedamt as? Int {
            cell.lblSavedamt.text = Utility.formatRupee(amount: Double(savedAmount))
        }
        
        if let totalAmount = OutsSummaryFilteredListArray[indexPath.row].totalamt as? Int {
            cell.lblTotalamt.text = Utility.formatRupee(amount: Double(totalAmount))
        }
        
        cell.lblStatus.text = OutsSummaryFilteredListArray[indexPath.row].status?.capitalized ?? "-"
        cell.lblReceipt.text = OutsSummaryFilteredListArray[indexPath.row].receipt ?? "-"
        cell.lblOrderNumber.text = OutsSummaryFilteredListArray[indexPath.row].transactionid ?? "-"
        cell.lblVoucherdt.text = OutsSummaryFilteredListArray[indexPath.row].voucherdt ?? "-"
        
        let status_flag = (OutsSummaryFilteredListArray[indexPath.row].statusflag ?? 0)!
        
        if(status_flag == 2){
            cell.lblStatus.textColor = UIColor.green
        }
        else if(status_flag == 4){
            cell.lblStatus.textColor = UIColor.blue
        }else if(status_flag == 3){
            cell.lblStatus.textColor = UIColor.red
        }else {
            cell.lblStatus.textColor = UIColor.darkGray
        }
        
        if((OutsSummaryFilteredListArray[indexPath.row].retry ?? false)!){
            cell.btnRetry.isHidden = false
        }else{
            cell.btnRetry.isHidden = true
        }
        
        cell.delegate = self
       
        return cell
    }
    
    
    func btnRetry(cell: OutsPaymentSummaryCell) {
        
        let indexPath = self.tableview.indexPath(for: cell)
        
        strTransactionId = (OutsSummaryFilteredListArray[indexPath!.row].transactionid ?? "")!
        totalSavings = (OutsSummaryFilteredListArray[indexPath!.row].savedamt ?? 0)!
        payableAmount = (OutsSummaryFilteredListArray[indexPath!.row].discoumtamt ?? 0)!
      
        if (Utility.isConnectedToNetwork()) {
            print("Internet connection available")
            OperationQueue.main.addOperation {
                if(!self.strTransactionId.isEmpty)
                {
                    self.apiRetryTransaction()
                }else{
                    var alert = UIAlertView(title: "Invalid", message: "Transaction id is not valid", delegate: nil, cancelButtonTitle: "OK")
                    alert.show()
                }
            }
        }
        else {
            print("No internet connection available")
            var alert = UIAlertView(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
        }
    }
    
    
    func btnRaiseDispute(cell: OutsPaymentSummaryCell) {
        let indexPath = self.tableview.indexPath(for: cell)
        
        strTransactionId = (OutsSummaryFilteredListArray[indexPath!.row].transactionid ?? "")!
        
        if (Utility.isConnectedToNetwork()) {
            let sb = UIStoryboard(name: "RaiseDisputePopup", bundle: nil)
            
            let popup = sb.instantiateInitialViewController()  as? RaiseDisputePopupController
            popup?.strTrxId = strTransactionId
            self.present(popup!, animated: true)
        }
        else {
            print("No internet connection available")
            var alert = UIAlertView(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
        }
    }
    
    
    
    // - - - - - - - - - - - Api for retry transaction - - - - - - - - - - - -
    func apiRetryTransaction(){
      
        ViewControllerUtils.sharedInstance.showLoader()
      
        let json: [String: Any] =
            ["CIN":strCin,"ClientSecret":"ClientSecret","transactionid":strTransactionId]
        
        print("apiRetryTransaction ------ ",json)
        
        DataManager.shared.makeAPICall(url: strApiTransactionRetry, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            DispatchQueue.main.async {
                do {
                    self.OutstandingPaymentDetailElementMain = try JSONDecoder().decode([OutstandingPaymentDetailReportElement].self, from: data!)
                    self.OutstandingPaymentDetailDataMain = self.OutstandingPaymentDetailElementMain[0].data
                    self.OutstandingPaymentDetailArrayToPass =  self.OutstandingPaymentDetailDataMain[0].invoices
                    
                    ViewControllerUtils.sharedInstance.removeLoader()
                    
                    // - - - - save tx no here - -  - - - -
                    if(self.OutstandingPaymentDetailElementMain[0].result ?? false){
                        UIApplication.shared.endIgnoringInteractionEvents()
                      
                            let vcOutstandingPaymentSummary  = self.storyboard?.instantiateViewController(withIdentifier: "OutstandingSummary") as! OutstandingSummaryViewController
                            vcOutstandingPaymentSummary.strlocalTransactionId = self.OutstandingPaymentDetailDataMain[0].transno ?? "-"
                            vcOutstandingPaymentSummary.strGrandTotal = self.OutstandingPaymentDetailDataMain[0].grandtotal ?? "-"
                            vcOutstandingPaymentSummary.strSavedAmountTotal = self.OutstandingPaymentDetailDataMain[0].savedamounttotal ?? "0"
                            vcOutstandingPaymentSummary.strDiscountAmountTotal = self.OutstandingPaymentDetailDataMain[0].withdiscountamounttotal ?? "0"
                            vcOutstandingPaymentSummary.intVerifyPayableAmount = self.payableAmount
                            vcOutstandingPaymentSummary.intVerifySavedAmount = self.totalSavings
                            vcOutstandingPaymentSummary.delegateDismiss = self
                            vcOutstandingPaymentSummary.outsPaymentObject = self.OutstandingPaymentDetailArrayToPass
                            
                            self.present(vcOutstandingPaymentSummary, animated: false, completion: nil)
                       
                    }else{
                        var alert = UIAlertView(title: "Error", message: "Something went wrong", delegate: nil, cancelButtonTitle: "OK")
                        alert.show()
                        self.dismiss(animated: true, completion: nil)
                    }
                    
                    
                } catch let errorData {
                    print(errorData.localizedDescription)
                    ViewControllerUtils.sharedInstance.removeLoader()
                    
                    var alert = UIAlertView(title: "Error", message: "Something went wrong", delegate: nil, cancelButtonTitle: "OK")
                    alert.show()
                    self.dismiss(animated: true, completion: nil)
                }
                
            }
            
        }) { (Error) in
            ViewControllerUtils.sharedInstance.removeLoader()
            print(Error?.localizedDescription)
            
            var alert = UIAlertView(title: "Error", message: "Something went wrong", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
            self.dismiss(animated: true, completion: nil)
            
        }
    }
  


}
