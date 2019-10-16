//
//  DispatchedMaterialController.swift
//  DealorsApp
//
//  Created by Goldmedal on 4/3/18.
//  Copyright © 2018 Goldmedal. All rights reserved.
//

import UIKit
import Foundation
import FirebaseAnalytics

class DispatchedMaterialController: BaseViewController , UITableViewDelegate , UITableViewDataSource ,UISearchBarDelegate{
    
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var noDataView: NoDataView!
    @IBOutlet weak var menuDispatchedMaterial: UIBarButtonItem!
    
    var dateFormatter = DateFormatter()
    
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
    var DispatchedMaterialElementMain = [DispatchedMaterialElement]()
    var DispatchedMaterialDataMain = [DispatchedMaterialData]()
    var DispatchedMaterialArray = [DispatchedMaterialObject]()
    
    @IBOutlet weak var btnToDate: UIButton!
    @IBOutlet weak var btnFromDate: UIButton!
    var dispatchedMaterialApi=""
    
    @IBOutlet weak var searchBar: RoundSearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        noDataView.hideView(view: noDataView)
        
        //addSlideMenuButton()
        
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
        dispatchedMaterialApi = (initialData["baseApi"] as? String ?? "")+""+(initialData["dispatchedMaterial"] as? String ?? "")
        
        
        if (Utility.isConnectedToNetwork()) {
            print("Internet connection available")
            OperationQueue.main.addOperation {
                self.apiDispatchedMaterial()
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
        self.searchBar.delegate = self;
        
        Analytics.setScreenName("DISPATCHED MATERIAL SCREEN", screenClass: "DispatchedMaterialController")
        //SQLiteDB.instance.addAnalyticsData(ScreenName: "DISPATCHED MATERIAL SCREEN", ScreenId: Int64(GlobalConstants.init().DISPATCHED_MATERIAL))
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
        self.DispatchedMaterialArray.removeAll()
        apiDispatchedMaterial()
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
    
    
    func apiDispatchedMaterial(){
        ViewControllerUtils.sharedInstance.showLoader()
        
        let json: [String: Any] =
            ["CIN":appDelegate.sendCin,"ClientSecret":"ClientSecret","FromDate":strFromDate,"ToDate":strToDate,"Index":fromIndex,"SearchText":strSearchText,"Count":batchSize]
        
        print(" DISPATCHED MATERIAL ------ ",json)
        
        DataManager.shared.makeAPICall(url: dispatchedMaterialApi, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            
            let isSearch = self.strSearchText.trimmingCharacters(in: NSCharacterSet.whitespaces).count  > 0
            DispatchQueue.main.async {
                do {
                    self.DispatchedMaterialElementMain = try JSONDecoder().decode([DispatchedMaterialElement].self, from: data!)
                    self.DispatchedMaterialDataMain = self.DispatchedMaterialElementMain[0].data
                    
                    if isSearch {
                        self.DispatchedMaterialArray = [DispatchedMaterialObject]()
                    }
                    
                    self.DispatchedMaterialArray.append(contentsOf: self.DispatchedMaterialDataMain[0].dispatchdata)
                    
                    if self.DispatchedMaterialArray.count > 0, isSearch {
                        self.tableview.reloadData()
                        self.tableview.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
                    }
                    
                    self.ismore = (self.DispatchedMaterialDataMain[0].ismore ?? false)!
                    
                    ViewControllerUtils.sharedInstance.removeLoader()
                } catch let errorData {
                    print(errorData.localizedDescription)
                    if self.strSearchText.trimmingCharacters(in: NSCharacterSet.whitespaces).count  > 0 {
                        self.DispatchedMaterialArray = [DispatchedMaterialObject]()
                    }
                    if self.DispatchedMaterialArray.count > 0, isSearch {
                        self.tableview.reloadData()
                        self.tableview.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
                    }
                    
                    ViewControllerUtils.sharedInstance.removeLoader()
                }
                
                
                if(self.tableview != nil)
                {
                    self.tableview.reloadData()
                }
                
                if(self.DispatchedMaterialArray.count > 0)
                {
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
        return DispatchedMaterialArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "DispatchedMaterialCell", for: indexPath) as! DispatchedMaterialCell
        if(DispatchedMaterialArray.count>0){
            
            if let amount = DispatchedMaterialArray[indexPath.row].amount as? String {
                cell.lblAmnt.text = Utility.formatRupee(amount: Double(amount)!)
            }
            cell.lblLrNo.text = DispatchedMaterialArray[indexPath.row].lrNo
            cell.lblDivision.text = DispatchedMaterialArray[indexPath.row].division?.capitalized ?? "-"
            cell.lblInvoiceDate.text = DispatchedMaterialArray[indexPath.row].invoiceDate
            cell.lblTransporter.text = DispatchedMaterialArray[indexPath.row].transporterName?.capitalized ?? "-"
            cell.lblInvoiceNumber.text = DispatchedMaterialArray[indexPath.row].invoiceNo
            
            let imvPdf = UITapGestureRecognizer(target: self, action: #selector(self.pdfTapped))
            cell.imvDownloadPdf.isUserInteractionEnabled = true
            cell.imvDownloadPdf.tag = indexPath.row
            cell.imvDownloadPdf.addGestureRecognizer(imvPdf)
            
        }
        
        print(indexPath.row," --------------------------------------",DispatchedMaterialArray.count)
        
        if indexPath.row == DispatchedMaterialArray.count - 1 {
            
            if self.ismore {
                fromIndex = fromIndex + 10// last cell
                apiDispatchedMaterial()
            }else{
                print("No more items")
            }
        }
        return cell
    }
    
    func pdfTapped(sender: UITapGestureRecognizer) {
        print("pdf name : \(sender.view?.tag)")
        
        guard let url = URL(string: DispatchedMaterialArray[sender.view!.tag].url ?? "") else {
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
