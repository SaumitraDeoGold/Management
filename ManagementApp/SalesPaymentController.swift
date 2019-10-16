//
//  SalesPaymentController.swift
//  DealorsApp
//
//  Created by Goldmedal on 4/3/18.
//  Copyright © 2018 Goldmedal. All rights reserved.
//

import UIKit
import FirebaseAnalytics

class SalesPaymentController: BaseViewController , UITableViewDelegate , UITableViewDataSource,UISearchBarDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btnFromDate: UIButton!
    @IBOutlet weak var btnToDate: UIButton!
    @IBOutlet weak var menuSalesPayment: UIBarButtonItem!
    @IBOutlet weak var searchBar: RoundSearchBar!
    @IBOutlet weak var noDataView: NoDataView!
    
    var fromIndex = 0
    let batchSize = 10
    var ismore = true
    var fromDate: Date?
    var toDate: Date?
    var strFromDate = ""
    var strToDate = ""
    var strSearchText = ""
    var strCin = ""
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var dateFormatter = DateFormatter()
    
    var SalesPaymentElementMain = [SalesPaymentElement]()
    var SalesPaymentDataMain = [SalesPaymentData]()
    var SalesPaymentArray = [SalesPaymentObject]()
    var salesPaymentReportApi=""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //addSlideMenuButton()
        
        self.noDataView.hideView(view: self.noDataView)
        
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
        salesPaymentReportApi = (initialData["baseApi"] as? String ?? "")+""+(initialData["salesPaymentReport"] as? String ?? "")
        
        
        // Do any additional setup after loading the view.
        if (Utility.isConnectedToNetwork()) {
            print("Internet connection available")
            OperationQueue.main.addOperation {
                self.SalesPaymentArray.removeAll()
                self.apiSalesPayment()
            }
            self.noDataView.hideView(view: self.noDataView)
        }
        else
        {
            print("No internet connection available")
            
            var alert = UIAlertView(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
            self.noDataView.showView(view: self.noDataView, from: "NET")
        }
        
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.searchBar.delegate = self;
        
        Analytics.setScreenName("SALES PAYMENT SCREEN", screenClass: "SalesPaymentController")
        //SQLiteDB.instance.addAnalyticsData(ScreenName: "SALES PAYMENT SCREEN", ScreenId: Int64(GlobalConstants.init().SALES_PAYMENT))
        
        
    }
    
    
    @IBAction func clicked_view_adjustment(_ sender: UIButton) {
        
        let sb = UIStoryboard(name: "AdjustedAmntPopup", bundle: nil)
        let popup = sb.instantiateInitialViewController()!
        self.present(popup, animated: true)
    }
    
    
    @IBAction func clicked_from_date(_ sender: UIButton) {
        sender.isSelected = true
        let sb = UIStoryboard(name: "DatePicker", bundle: nil)
        
        let popup = sb.instantiateInitialViewController()  as? DatePickerController
        popup?.fromDate = fromDate
        popup?.toDate = toDate
        popup?.isFromDate = true
        popup?.delegate = self
        self.present(popup!, animated: true)
    }
    
    
    @IBAction func clicked_to_date(_ sender: UIButton) {
        sender.isSelected = true
        let sb = UIStoryboard(name: "DatePicker", bundle: nil)
        
        let popup = sb.instantiateInitialViewController()  as? DatePickerController
        popup?.delegate = self
        popup?.toDate = toDate
        popup?.fromDate = fromDate
        popup?.isFromDate = false
        self.present(popup!, animated: true)
    }
    
    @IBAction func back_Button(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
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
        
        filterSearch()
    }
    
    
    //search filter
    func filterSearch(){
        fromIndex = 0
        self.SalesPaymentArray.removeAll()
        apiSalesPayment()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.characters.count > 2 {
            strSearchText = searchText
            filterSearch()
        }
        
        if searchText == ""
        {
            strSearchText = ""
            filterSearch()
            searchBar.resignFirstResponder()
        }
    }
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    
    
    func apiSalesPayment(){
        ViewControllerUtils.sharedInstance.showLoader()
        
        let json: [String: Any] = ["Index":fromIndex, "SearchText":strSearchText, "ToDate":strToDate, "ClientSecret":"ClientSecret", "FromDate":strFromDate, "CIN":appDelegate.sendCin, "Count":batchSize]
        
        DataManager.shared.makeAPICall(url: salesPaymentReportApi, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            
            let isSearch = self.strSearchText.trimmingCharacters(in: NSCharacterSet.whitespaces).count  > 0
            DispatchQueue.main.async {
                do {
                    self.SalesPaymentElementMain = try JSONDecoder().decode([SalesPaymentElement].self, from: data!)
                    
                    self.SalesPaymentDataMain = self.SalesPaymentElementMain[0].data
                    
                    if isSearch {
                        self.SalesPaymentArray = [SalesPaymentObject]()
                    }
                    
                    self.SalesPaymentArray.append(contentsOf:self.SalesPaymentDataMain[0].custrecieptdata)
                    
                    if self.SalesPaymentArray.count > 0, isSearch {
                        self.tableView.reloadData()
                        self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
                    }
                    
                    self.ismore = (self.SalesPaymentDataMain[0].ismore ?? false)!
                    
                    ViewControllerUtils.sharedInstance.removeLoader()
                } catch let errorData {
                    print(errorData.localizedDescription)
                    if self.strSearchText.trimmingCharacters(in: NSCharacterSet.whitespaces).count  > 0 {
                        self.SalesPaymentArray = [SalesPaymentObject]()
                    }
                    if self.SalesPaymentArray.count > 0, isSearch {
                        self.tableView.reloadData()
                        self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
                    }
                    ViewControllerUtils.sharedInstance.removeLoader()
                }
                
                if(self.tableView != nil)
                {
                    self.tableView.reloadData()
                }
                
                if(self.SalesPaymentArray.count>0){
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
        return SalesPaymentArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SalesPaymentCell", for: indexPath) as! SalesPaymentCell
        if(SalesPaymentArray.count > 0)
        {
            
            if var salesAmount = SalesPaymentArray[indexPath.row].amount as? String {
                cell.lblAmount.text = Utility.formatRupee(amount: Double(salesAmount)!)
            }
            cell.lblDate.text = SalesPaymentArray[indexPath.row].date ?? "-"
            cell.lblPaymentType.text = SalesPaymentArray[indexPath.row].instrumentType?.capitalized ?? "-"
            cell.lblDivision.text = SalesPaymentArray[indexPath.row].division?.capitalized ?? "-"
            cell.lblStatus.text = SalesPaymentArray[indexPath.row].status?.capitalized ?? "-"
            
            let salesAdj = UITapGestureRecognizer(target: self, action: #selector(SalesPaymentController.imageTapped))
            cell.imvSalesAdjustment.isUserInteractionEnabled = true
            cell.imvSalesAdjustment.tag = SalesPaymentArray[indexPath.row].slno ?? 0
            cell.imvSalesAdjustment.addGestureRecognizer(salesAdj)
        }
        print(indexPath.row," --------------------------------------",SalesPaymentArray.count,"------------------",SalesPaymentArray[indexPath.row].amount)
        
        if indexPath.row == SalesPaymentArray.count - 1 {
            
            if self.ismore {
                fromIndex = fromIndex + 10// last cell
                apiSalesPayment()
            }else{
                print("No more items")
            }
        }
        
        return cell
    }
    
    func imageTapped(sender: UITapGestureRecognizer) {
        //print("you tap image number : \(sender.view?.tag ?? 0)")
        let sb = UIStoryboard(name: "AdjustedAmntPopup", bundle: nil)
        
        let popup = sb.instantiateInitialViewController()  as? AdjustedAmntViewController
        popup?.intSlno = sender.view!.tag
        popup?.callFrom = "SalesPayment"
        self.present(popup!, animated: true)
        
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

