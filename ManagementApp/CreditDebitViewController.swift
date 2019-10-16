//
//  CreditDebitViewController.swift
//  DealorsApp
//
//  Created by Goldmedal on 9/5/18.
//  Copyright © 2018 Goldmedal. All rights reserved.
//

import UIKit
import FirebaseAnalytics

class CreditDebitViewController: BaseViewController , UITableViewDelegate , UITableViewDataSource,UISearchBarDelegate
{
    var strSearchText = ""
    var strCin = ""
    var finYear = ""
    
    var CreditListApi = ""
    var DebitListApi = ""
    
    var CreditDebitElementMain = [CreditDebitNoteElement]()
    var CreditDebitArray = [CreditDebitObj]()
    
    @IBOutlet weak var searchBar: RoundSearchBar!
    @IBOutlet var tabButtons: [UIButton]!
    @IBOutlet var lineLabels: [UILabel]!
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var noDataView: NoDataView!
    
    
    @IBOutlet weak var btnFinancialYear: RoundButton!
    @IBOutlet weak var btnYearly: UIButton!
    @IBOutlet weak var btnMonthly: UIButton!
    @IBOutlet weak var btnQuarterly: UIButton!
    
    
    var opType = 3;
    var opValue = 0;
    var currPosition = 0;
    var callFrom = 0
    
    var finalApi = ""
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var selectedTab = "Credit"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //addSlideMenuButton()
        
        finYear = Utility.currFinancialYear()
        
        let loginData =  UserDefaults.standard.value(forKey: "loginData") as? Dictionary ?? [:]
        strCin = loginData["userlogid"] as? String ?? ""
        
        let initialData =  UserDefaults.standard.value(forKey: "initialData") as? Dictionary ?? [:]
        CreditListApi = (initialData["baseApi"] as? String ?? "")+""+(initialData["ledgerAmount"] as? String ?? "")
        DebitListApi = (initialData["baseApi"] as? String ?? "")+""+(initialData["ledgerAmountDebit"] as? String ?? "")
        
        
        finYear = Utility.currFinancialYear()
        btnFinancialYear.setTitle(finYear, for: .normal)
        
        self.tableview.delegate = self;
        self.tableview.dataSource = self;
        self.searchBar.delegate = self;
        
        tabAction(sender: tabButtons[0])
        
        Analytics.setScreenName("CREDIT DEBIT SCREEN", screenClass: "CreditDebitViewController")
        //SQLiteDB.instance.addAnalyticsData(ScreenName: "CREDIT DEBIT SCREEN", ScreenId: Int64(GlobalConstants.init().CREDIT_DEBIT))
        
        btnYearly.titleLabel?.font = UIFont(name:"Roboto-Bold", size: 12.0)
        btnMonthly.titleLabel?.font = UIFont(name:"Roboto-Regular", size: 12.0)
        btnQuarterly.titleLabel?.font = UIFont(name:"Roboto-Regular", size: 12.0)
    }
    
    
    //Button Functions...
    @IBAction func backBtnClick(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
 
    @IBAction func monthly_clicked(_ sender: UIButton) {
        let sb = UIStoryboard(name: "CustomYearPicker", bundle: nil)
        let popup = sb.instantiateInitialViewController()! as! CustomYearPickerController
        popup.delegate = self
        popup.showPicker = 1
        self.present(popup, animated: true)
        callFrom = 1
        opType = 1
    }
    
    
    @IBAction func quarterly_clicked(_ sender: UIButton) {
        let sb = UIStoryboard(name: "CustomYearPicker", bundle: nil)
        let popup = sb.instantiateInitialViewController()! as! CustomYearPickerController
        popup.delegate = self
        popup.showPicker = 2
        self.present(popup, animated: true)
        callFrom = 2
        opType = 2
    }
    
    
    @IBAction func yearly_clicked(_ sender: UIButton) {
        let sb = UIStoryboard(name: "CustomYearPicker", bundle: nil)
        let popup = sb.instantiateInitialViewController()! as! CustomYearPickerController
        popup.delegate = self
        popup.showPicker = 3
        self.present(popup, animated: true)
        callFrom = 3
        opType = 3
        opValue = 0
    }
    
    @IBAction func clicked_year(_ sender: UIButton)
    {
        
        opType = 3
        opValue = 0
        
        // apiDivisionWiseSales()
        if(selectedTab.elementsEqual("Debit")){
            finalApi = DebitListApi
            filterSearch()
        }else{
            finalApi = CreditListApi
            filterSearch()
        }
        
        btnYearly.titleLabel?.font = UIFont(name:"Roboto-Bold", size: 12.0)
        btnMonthly.titleLabel?.font = UIFont(name:"Roboto-Regular", size: 12.0)
        btnQuarterly.titleLabel?.font = UIFont(name:"Roboto-Regular", size: 12.0)
    }
    
    func updatePositionValue(value: String, position: Int, from: String) {
        if(callFrom == 3){
            btnFinancialYear.setTitle(value, for: .normal)
            finYear = value
            opValue = 0
        }else if(callFrom == 2) {
            currPosition = position + 1
            opValue = currPosition
        }else{
            currPosition = position + 1
            
            if(currPosition < 4){
                currPosition = (position+1) + 9
            }else{
                currPosition = (position+1) - 3
            }
            opValue = currPosition
        }
        
        
        
        if(selectedTab.elementsEqual("Debit")){
            finalApi = DebitListApi
            filterSearch()
        }else{
            finalApi = CreditListApi
            filterSearch()
        }
        
        if(opType == 1){
            btnYearly.titleLabel?.font = UIFont(name:"Roboto-Regular", size: 12.0)
            btnMonthly.titleLabel?.font = UIFont(name:"Roboto-Bold", size: 12.0)
            btnQuarterly.titleLabel?.font = UIFont(name:"Roboto-Regular", size: 12.0)
        }else if(opType == 2){
            btnYearly.titleLabel?.font = UIFont(name:"Roboto-Regular", size: 12.0)
            btnMonthly.titleLabel?.font = UIFont(name:"Roboto-Regular", size: 12.0)
            btnQuarterly.titleLabel?.font = UIFont(name:"Roboto-Bold", size: 12.0)
        }else if(opType == 3){
            btnYearly.titleLabel?.font = UIFont(name:"Roboto-Bold", size: 12.0)
            btnMonthly.titleLabel?.font = UIFont(name:"Roboto-Regular", size: 12.0)
            btnQuarterly.titleLabel?.font = UIFont(name:"Roboto-Regular", size: 12.0)
        }
        
    }
    
    
    
    
    
    
    @IBAction func tabAction(sender: UIButton) {
        for (index, button) in tabButtons.enumerated() {
            let labelLine = lineLabels[index]
            labelLine.backgroundColor = (button == sender) ? UIColor.red : UIColor.clear
        }
        
        if (Utility.isConnectedToNetwork()) {
            switch sender.tag {
            case 0:
                
                finalApi = CreditListApi
                filterSearch()
                selectedTab = "Credit"
                
                break
            case 1:
                
                finalApi = DebitListApi
                filterSearch()
                selectedTab = "Debit"
                
                break
            default:
                break
            }
            self.noDataView.hideView(view: self.noDataView)
        }
        else{
            self.noDataView.showView(view: self.noDataView, from: "NET")
        }
        
    }
    
    
    
    //search filter
    func filterSearch(){
        self.CreditDebitArray.removeAll()
        apiCreditDebitNote()
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
    
    
    func apiCreditDebitNote(){
        ViewControllerUtils.sharedInstance.showLoader()
        
        let json: [String: Any] =
            ["CIN":appDelegate.sendCin,"FinYear":finYear,"searchtxt":strSearchText,"ReportType":opType,"ReportValue":opValue]
        
        print(" CREDIT DEBIT ------ ",json)
        print("- - - - ",finYear," - -- - ",opType," - -- - ",opValue)
        
        DataManager.shared.makeAPICall(url: finalApi, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            
            let isSearch = self.strSearchText.trimmingCharacters(in: NSCharacterSet.whitespaces).count  > 0
            DispatchQueue.main.async {
                do {
                    self.CreditDebitElementMain = try JSONDecoder().decode([CreditDebitNoteElement].self, from: data!)
                    
                    if isSearch {
                        self.CreditDebitArray = [CreditDebitObj]()
                    }
                    
                    self.CreditDebitArray.append(contentsOf: self.CreditDebitElementMain[0].data)
                    
                    if self.CreditDebitArray.count > 0, isSearch {
                        self.tableview.reloadData()
                        self.tableview.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
                    }
                    
                } catch let errorData {
                    print(errorData.localizedDescription)
                    if self.strSearchText.trimmingCharacters(in: NSCharacterSet.whitespaces).count  > 0 {
                        self.CreditDebitArray = [CreditDebitObj]()
                    }
                    if self.CreditDebitArray.count > 0, isSearch {
                        self.tableview.reloadData()
                        self.tableview.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
                    }
                }
                
                if(self.tableview != nil)
                {
                    self.tableview.reloadData()
                }
                
                if(self.CreditDebitArray.count>0){
                    self.noDataView.hideView(view: self.noDataView)
                }else{
                    self.noDataView.showView(view: self.noDataView, from: "NDA")
                }
                ViewControllerUtils.sharedInstance.removeLoader()
            }
        }) { (Error) in
            ViewControllerUtils.sharedInstance.removeLoader()
            print(Error?.localizedDescription)
            self.noDataView.showView(view: self.noDataView, from: "ERR")
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CreditDebitArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CreditDebitCell", for: indexPath) as! CreditDebitCell
        if(CreditDebitArray.count>0){
            
            if var creditDebitAmount = CreditDebitArray[indexPath.row].amount as? String {
                cell.lblAmount.text = Utility.formatRupee(amount: Double(creditDebitAmount)!)
            }
            cell.lblReferenceNumber.text = CreditDebitArray[indexPath.row].referenceno ?? "-"
            cell.lblDate.text = CreditDebitArray[indexPath.row].date ?? "-"
            cell.lblType.text = CreditDebitArray[indexPath.row].type?.capitalized ?? "-"
            cell.lblLedgerDesc.text = CreditDebitArray[indexPath.row].ledgerdec?.capitalized ?? "-"
            
            if(selectedTab.isEqual("Credit")){
                cell.vwAdjustment.isHidden = false
                cell.vwDownload.isHidden = false
                // cell.viewHeight.constant = 135
            }else{
                cell.vwAdjustment.isHidden = true
                cell.vwDownload.isHidden = true
                //   cell.viewHeight.constant = 90
            }
            
            if((CreditDebitArray[indexPath.row].url ?? "").isEmpty){
                cell.vwCnBreakup.isHidden = true
            }else{
                cell.vwCnBreakup.isHidden = false
            }
            
            let viewAdj = UITapGestureRecognizer(target: self, action: #selector(CreditDebitViewController.imageTapped))
            cell.imvAdjustment.isUserInteractionEnabled = true
            cell.imvAdjustment.tag = indexPath.row
            cell.imvAdjustment.addGestureRecognizer(viewAdj)
            
            let DownloadCN = UITapGestureRecognizer(target: self, action: #selector(self.DownloadCNClicked))
            cell.imvDownloadCn.isUserInteractionEnabled = true
            cell.imvDownloadCn.tag = indexPath.row
            cell.imvDownloadCn.addGestureRecognizer(DownloadCN)
            
            let CNBreakup = UITapGestureRecognizer(target: self, action: #selector(self.CNBreakupClicked))
            cell.imvCnBreakup.isUserInteractionEnabled = true
            cell.imvCnBreakup.tag = indexPath.row
            cell.imvCnBreakup.addGestureRecognizer(CNBreakup)
        }
        
        
        return cell
    }
    
    func DownloadCNClicked(sender: UITapGestureRecognizer) {
        print("pdf name : \(sender.view?.tag)")
        
        guard let url = URL(string: CreditDebitArray[sender.view!.tag].download ?? "") else {
            var alert = UIAlertView(title: "Error", message: "Invalid Pdf", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
            
            return
        }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
        
    }
    
    func CNBreakupClicked(sender: UITapGestureRecognizer) {
        print("pdf name : \(sender.view?.tag)")
        
        guard let url = URL(string: CreditDebitArray[sender.view!.tag].url ?? "") else {
            var alert = UIAlertView(title: "Error", message: "Invalid Pdf", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
            
            return
        }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
        
    }
    
    
    
    func imageTapped(sender: UITapGestureRecognizer) {
        print("you tap image number : \(sender.view?.tag)")
        let index = sender.view?.tag
        
        let sb = UIStoryboard(name: "AdjustedAmntPopup", bundle: nil)
        
        let popup = sb.instantiateInitialViewController()  as? AdjustedAmntViewController
        popup?.intSlno = CreditDebitArray[index!].slno ?? 0
        popup?.strType = CreditDebitArray[index!].type ?? "-"
        popup?.callFrom = "CreditDebit"
        self.present(popup!, animated: true)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

