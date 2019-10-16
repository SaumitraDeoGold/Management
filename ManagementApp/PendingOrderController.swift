//
//  PendingOrderController.swift
//  DealorsApp
//
//  Created by Goldmedal on 4/3/18.
//  Copyright © 2018 Goldmedal. All rights reserved.
//

import UIKit
import FirebaseAnalytics


class PendingOrderController: BaseViewController , UITableViewDelegate , UITableViewDataSource,UISearchBarDelegate {
    
    var PendingOrderMain = [PendingOrderElement]()
    var PendingOrderDataMain = [PendingOrderData]()
    var PendingOrderArray = [PendingOrderObject]()
    
    var PendingOrderPdfMain = [PendingOrderPDFElement]()
    var PendingOrderPdfData = [PendingOrderPdfObj]()
    
    @IBOutlet weak var searchBar: RoundSearchBar!
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btnDivisionPicker: UIButton!
    @IBOutlet weak var btnOrderWisePicker: UIButton!
    @IBOutlet weak var btnPendingOrder: UIButton!
    @IBOutlet weak var noDataView: NoDataView!
    
    var fromIndex = 0
    let batchSize = 10
    var ismore = true
    var strSearchText = ""
    var strCin = ""
    var strCurrDate = ""
    var intOrderType = Int()
    var intDivId = 0
    var callFrom = Int()
    var pendingOrdersApi=""
    var pendingOrdersPDFApi=""
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        //addSlideMenuButton()
        
        self.noDataView.hideView(view: self.noDataView)
        
        let loginData =  UserDefaults.standard.value(forKey: "loginData") as? Dictionary ?? [:]
        strCin = loginData["userlogid"] as? String ?? ""
        
        let initialData =  UserDefaults.standard.value(forKey: "initialData") as? Dictionary ?? [:]
        pendingOrdersApi = (initialData["baseApi"] as? String ?? "")+""+(initialData["pendingOrders"] as? String ?? "")
        pendingOrdersPDFApi = (initialData["baseApi"] as? String ?? "")+""+(initialData["pendingOrdersPDF"] as? String ?? "")
        
        strCurrDate = Utility.currDate()
        
        if callFrom != 1
        {
            intOrderType = 1
            btnOrderWisePicker.setTitle("Order Wise",for: .normal)
        }else{
            if(intOrderType == 1){
                btnOrderWisePicker.setTitle("Order Wise",for: .normal)
            }else{
                btnOrderWisePicker.setTitle("Summary Wise",for: .normal)
            }
        }
        
        if (Utility.isConnectedToNetwork()) {
            print("Internet connection available")
            OperationQueue.main.addOperation {
                self.apiPendingOrder()
            }
            self.noDataView.hideView(view: self.noDataView)
        }
        else {
            print("No internet connection available")
            
            var alert = UIAlertView(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
            
            self.noDataView.showView(view: self.noDataView, from: "NET")
        }
         
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.searchBar.delegate = self;
        
        Analytics.setScreenName("PENDING ORDER SCREEN", screenClass: "PendingOrderController")
        //SQLiteDB.instance.addAnalyticsData(ScreenName: "PENDING ORDER SCREEN", ScreenId: Int64(GlobalConstants.init().PENDING_ORDER))
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func updatePositionValue(value: String, position: Int, from: String) {
        if(from == "ORDER")
        {
            btnOrderWisePicker.setTitle(value, for: .normal)
            intOrderType = position
        }
        
        if(from == "DIVISION"){
            btnDivisionPicker.setTitle(value, for: .normal)
            intDivId = position
        }
        
        filterSearch()
    }
    
    @IBAction func clicked_pending_order(_ sender: UIButton) {
        apiDownloadPendingOrder()
    }
    
    @IBAction func clicked_division(_ sender: UIButton) {
        let sb = UIStoryboard(name: "DivisionPicker", bundle: nil)
        let popup = sb.instantiateInitialViewController() as? DivisionPicker
        popup?.delegate = self
        self.present(popup!, animated: true)
    }
    
    @IBAction func clicked_order(_ sender: UIButton) {
        let sb = UIStoryboard(name: "OrderType", bundle: nil)
        let popup = sb.instantiateInitialViewController() as? OrderTypeViewController
        popup?.delegate = self
        self.present(popup!, animated: true)
    }
    
    @IBAction func back_Button(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    //search filter
    func filterSearch(){
        fromIndex = 0
        self.PendingOrderArray.removeAll()
        apiPendingOrder()
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
    
    // -------------- Pending order list
    func apiPendingOrder(){
        ViewControllerUtils.sharedInstance.showLoader()
        
        let json: [String: Any] = ["CIN":appDelegate.sendCin,"ClientSecret":"ClientSecret","Division":intDivId,"SearchText":strSearchText,"Index":fromIndex,"Count":batchSize,"AsonDate":strCurrDate,"Type":intOrderType]
        
        print("PENDING ORDER --- ",json)
        
        DataManager.shared.makeAPICall(url: pendingOrdersApi, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            let isSearch = self.strSearchText.trimmingCharacters(in: NSCharacterSet.whitespaces).count  > 0
            
            DispatchQueue.main.async {
                do {
                    self.PendingOrderMain = try JSONDecoder().decode([PendingOrderElement].self, from: data!)
                    self.PendingOrderDataMain = self.PendingOrderMain[0].data
                    
                    if isSearch {
                        self.PendingOrderArray = [PendingOrderObject]()
                    }
                    
                    self.PendingOrderArray.append(contentsOf:self.PendingOrderDataMain[0].pendingdata)
                    
                    if self.PendingOrderArray.count > 0, isSearch {
                        self.tableView.reloadData()
                        self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
                    }
                    
                    self.ismore = (self.PendingOrderDataMain[0].ismore ?? false)!
                    
                    ViewControllerUtils.sharedInstance.removeLoader()
                } catch let errorData {
                    print(errorData.localizedDescription)
                    ViewControllerUtils.sharedInstance.removeLoader()
                    if self.strSearchText.trimmingCharacters(in: NSCharacterSet.whitespaces).count  > 0 {
                        self.PendingOrderArray = [PendingOrderObject]()
                    }
                    if self.PendingOrderArray.count > 0, isSearch {
                        self.tableView.reloadData()
                        self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
                    }
                }
                
                if(self.PendingOrderArray.count>0){
                    if(self.tableView != nil)
                    {
                        self.tableView.reloadData()
                    }
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
    
    // ----------- Download pending order
    func apiDownloadPendingOrder() {
        
        let json: [String: Any] = ["CIN":appDelegate.sendCin,"ClientSecret":"ClientSecret","AsonDate":strCurrDate,"Type":intOrderType]
        
        print("PENDING PDF JSON -- ",json)
        
        DataManager.shared.makeAPICall(url: pendingOrdersPDFApi, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            
            DispatchQueue.main.async {
                do {
                    self.PendingOrderPdfMain = try JSONDecoder().decode([PendingOrderPDFElement].self, from: data!)
                    self.PendingOrderPdfData = self.PendingOrderPdfMain[0].data
                    
                    guard let url = URL(string: self.PendingOrderPdfData[0].url ?? "") else {
                        
                        var alert = UIAlertView(title: "Error", message: "Invalid Pdf", delegate: nil, cancelButtonTitle: "OK")
                        alert.show()
                        
                        return
                    }
                    if UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                    
                } catch let errorData {
                    print(errorData.localizedDescription)
                }
            }
        }) { (Error) in
            ViewControllerUtils.sharedInstance.removeLoader()
            print(Error?.localizedDescription)
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return PendingOrderArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PendingOrderCell", for: indexPath) as! PendingOrderCell
        if(PendingOrderArray.count > 0){
            
            if var pendingAmount = PendingOrderArray[indexPath.row].amount as? String
            {
                cell.lblAmount.text = Utility.formatRupee(amount: Double(pendingAmount)!)
            }
            
            cell.lblDate.text = PendingOrderArray[indexPath.row].poDt
            cell.lblPoNo.text = PendingOrderArray[indexPath.row].poNum
            cell.lblQuantity.text = PendingOrderArray[indexPath.row].pendingQty
            cell.lblPendingOrderName.text = PendingOrderArray[indexPath.row].itemName?.capitalized ?? "-"
        }
        
        print(indexPath.row," --------------------------------------",PendingOrderArray.count)
        
        if indexPath.row == PendingOrderArray.count - 1 {
            
            if self.ismore {
                fromIndex = fromIndex + 10// last cell
                apiPendingOrder()
            }else{
                print("No more items")
            }
        }
        
        return cell
    }
}
