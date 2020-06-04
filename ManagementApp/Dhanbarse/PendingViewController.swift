//
//  PendingViewController.swift
//  ManagementApp
//
//  Created by Goldmedal on 27/04/20.
//  Copyright © 2020 Goldmedal. All rights reserved.
//

import UIKit

class PendingViewController: BaseViewController, UITableViewDelegate , UITableViewDataSource {

    //Outlet...
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btnPayment: RoundButton!
    @IBOutlet weak var btnSales: RoundButton!
    @IBOutlet weak var noDataView: NoDataView!
    @IBOutlet weak var textField: UITextField!
    
    //Declarations...
    var cellContentIdentifier = "\(CounterBoyApprovalCell.self)"
    var mrpListApiUrl = ""
    var apiClosedMpr = ""
    var mrpData = [MRPData]()
    var mRPDataObj = [MRPDataObj]()
    var filteredItems = [MRPDataObj]()
    var tempDataItems = [MRPDataObj]()
    var showClosed = false
    var nameOfMonth = ""
    var nameOfDay = ""
    var nameOfYear = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addSlideMenuButton()
        let now = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM"
        let dateFormatter1 = DateFormatter()
        dateFormatter1.dateFormat = "dd"
        let dateFormatter2 = DateFormatter()
        dateFormatter2.dateFormat = "yyyy"
        nameOfMonth = dateFormatter.string(from: now)
        nameOfDay = dateFormatter1.string(from: now)
        nameOfYear = dateFormatter2.string(from: now)
        self.noDataView.hideView(view: self.noDataView)
        ViewControllerUtils.sharedInstance.showLoader()
        mrpListApiUrl = "https://test2.goldmedalindia.in/api/getmprlist"
        apiClosedMpr = "https://test2.goldmedalindia.in/api/getmprcloselist"
        apiGetMRPList()
        tableView.separatorStyle = .none
    }
    
    //Buttons...
    @IBAction func clickedSales(_ sender: Any) {
        showClosed = false
        btnSales.backgroundColor = UIColor.darkGray
        btnSales.setTitleColor(UIColor.white, for: .normal)
        btnPayment.backgroundColor = UIColor.white
        btnPayment.setTitleColor(UIColor.black, for: .normal)
        ViewControllerUtils.sharedInstance.showLoader()
        tableView.reloadData()
        apiGetMRPList()
    }
    
    @IBAction func clickedPayment(_ sender: Any) {
        showClosed = true
        btnSales.backgroundColor = UIColor.white
        btnSales.setTitleColor(UIColor.black, for: .normal)
        btnPayment.backgroundColor = UIColor.darkGray
        btnPayment.setTitleColor(UIColor.white, for: .normal)
        ViewControllerUtils.sharedInstance.showLoader()
        tableView.reloadData()
        apiGetClosedList()
    }
    
    //Tableview Functions...
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 290
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredItems.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CounterBoyApprovalCell", for: indexPath) as! CounterBoyApprovalCell
        cell.contentLabel.text = "Req no/Req Date : \(filteredItems[indexPath.item].mprRequestNO ?? "0") / \(filteredItems[indexPath.item].requestedDate ?? "0")"
        cell.contentLabel1.text = "Postion/No Of Pos  : \(filteredItems[indexPath.item].positionTitle ?? "-")/\(filteredItems[indexPath.item].noPosition ?? "0")"
        //cell.contentLabel2.text = "Employee Type : \(filteredItems[indexPath.item].employeeType ?? "-")"
        cell.contentLabel2.text = "Location : \(filteredItems[indexPath.item].location ?? "-")"
        cell.contentLabel3.text = "Dept/Sub Dept : \(filteredItems[indexPath.item].department ?? "-")/\(filteredItems[indexPath.item].subDaeprtment ?? "-")"
        cell.contentLabel4.text = "Budget/ Experience : \(filteredItems[indexPath.item].budget ?? "-") lacs/\(filteredItems[indexPath.item].preferedQualificationExprienece ?? "-")yrs "
        cell.contentLabel5.text = "E.Type/N Req : \(filteredItems[indexPath.item].employeeType ?? "-")/\(filteredItems[indexPath.item].natureOfRequest ?? "-")"
        if !showClosed {
            cell.contentLabel6.text = "Pending Since : \(dateDifference(value: filteredItems[indexPath.item].requestedDate!)) days"
        }
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        return cell
    }
    
    func dateDifference(value: String) -> String{
        let inFormatDate = value.split{$0 == "-"}.map(String.init)
        //let temp = "\(inFormatDate[1])/\(inFormatDate[0])/\(inFormatDate[2])"
        let date1 = DateComponents(calendar: .current, year: Int(nameOfYear), month: Int(nameOfMonth), day: Int(nameOfDay), hour: 5, minute: 9).date!
        let date2 = DateComponents(calendar: .current, year: Int(inFormatDate[2]), month: Int(inFormatDate[1]), day: Int(inFormatDate[0]), hour: 5, minute: 9).date!
        let days = date2.days(from: date1) * -1
        return String(days)
    }
    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        //Set Global Cin Number and send to next page[Old Dashboard]...
//        appDelegate.sendCin = ndaDetailArray[indexPath.item].cin!
//    }
    
    //API Function...
    func apiGetMRPList(){
        
        let json: [String: Any] = ["CIN":UserDefaults.standard.value(forKey: "userCIN") as! String,"Category":UserDefaults.standard.value(forKey: "userCategory") as! String, "ClientSecret":"ohdashfl"]
        print("GET MPR DETAILS : \(json)")
        let manager =  DataManager.shared
        
        manager.makeAPICall(url: mrpListApiUrl, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            print("URL : \(self.mrpListApiUrl)")
            do {
                self.mrpData = try JSONDecoder().decode([MRPData].self, from: data!)
                self.mRPDataObj.removeAll()
                self.filteredItems.removeAll()
                self.mRPDataObj = self.mrpData[0].data
                self.filteredItems = self.mrpData[0].data
                self.tempDataItems = self.mrpData[0].data
                self.textField.addTarget(self, action: #selector(self.searchRecords(_ :)), for: .editingChanged)
                self.tableView.reloadData()
                self.noDataView.hideView(view: self.noDataView)
                ViewControllerUtils.sharedInstance.removeLoader()
            } catch let errorData {
                self.noDataView.showView(view: self.noDataView, from: "NDA")
                print("Caught Error : \(errorData.localizedDescription)")
                ViewControllerUtils.sharedInstance.removeLoader()
            }
        }) { (Error) in
            self.noDataView.showView(view: self.noDataView, from: "NDA")
            print("Caught Error : \(Error?.localizedDescription as Any)" )
            ViewControllerUtils.sharedInstance.removeLoader()
        }
        
    }
    
    func apiGetClosedList(){
        
        let json: [String: Any] = ["CIN":UserDefaults.standard.value(forKey: "userCIN") as! String,"Category":UserDefaults.standard.value(forKey: "userCategory") as! String, "ClientSecret":"ohdashfl"]
        print("GET MPR Closed DETAILS : \(json)")
        let manager =  DataManager.shared
        
        manager.makeAPICall(url: apiClosedMpr, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            print("Closed URL : \(self.mrpListApiUrl)")
            do {
                self.mrpData = try JSONDecoder().decode([MRPData].self, from: data!)
                self.mRPDataObj.removeAll()
                self.filteredItems.removeAll()
                self.mRPDataObj = self.mrpData[0].data
                self.filteredItems = self.mrpData[0].data
                self.tempDataItems = self.mrpData[0].data
                self.textField.addTarget(self, action: #selector(self.searchRecords(_ :)), for: .editingChanged)
                self.tableView.reloadData()
                self.noDataView.hideView(view: self.noDataView)
                ViewControllerUtils.sharedInstance.removeLoader()
            } catch let errorData {
                self.noDataView.showView(view: self.noDataView, from: "NDA")
                print("Caught Error : \(errorData.localizedDescription)")
                ViewControllerUtils.sharedInstance.removeLoader()
            }
        }) { (Error) in
            self.noDataView.showView(view: self.noDataView, from: "NDA")
            print("Caught Error : \(Error?.localizedDescription as Any)" )
            ViewControllerUtils.sharedInstance.removeLoader()
        }
        
    }
    
    //Auto-Complete Function...
    @objc func searchRecords(_ textfield: UITextField){
            self.filteredItems.removeAll()
            if textfield.text?.count != 0{
                for dealers in tempDataItems{
                    let range = dealers.positionTitle!.lowercased().range(of: textfield.text!, options: .caseInsensitive, range: nil, locale: nil)
                    let type = dealers.employeeType!.lowercased().range(of: textfield.text!, options: .caseInsensitive, range: nil, locale: nil)
                    let loc = dealers.location!.lowercased().range(of: textfield.text!, options: .caseInsensitive, range: nil, locale: nil)
                    let dept = dealers.department!.lowercased().range(of: textfield.text!, options: .caseInsensitive, range: nil, locale: nil)
                    let sdept = dealers.subDaeprtment!.lowercased().range(of: textfield.text!, options: .caseInsensitive, range: nil, locale: nil)
                    let nor = dealers.natureOfRequest!.lowercased().range(of: textfield.text!, options: .caseInsensitive, range: nil, locale: nil)
                    if range != nil{
                        filteredItems.append(dealers)
                    }else if type != nil{
                        filteredItems.append(dealers)
                    }else if loc != nil{
                        filteredItems.append(dealers)
                    }else if dept != nil{
                        filteredItems.append(dealers)
                    }else if sdept != nil{
                        filteredItems.append(dealers)
                    }else if nor != nil{
                        filteredItems.append(dealers)
                    }
                }
            }else{
                for dealers in tempDataItems{
                    filteredItems.append(dealers)
                }
            }
        tableView.reloadData()
    }

}

//extension Date {
//    /// Returns the amount of years from another date
//    func years(from date: Date) -> Int {
//        return Calendar.current.dateComponents([.year], from: date, to: self).year ?? 0
//    }
//    /// Returns the amount of months from another date
//    func months(from date: Date) -> Int {
//        return Calendar.current.dateComponents([.month], from: date, to: self).month ?? 0
//    }
//    /// Returns the amount of weeks from another date
//    func weeks(from date: Date) -> Int {
//        return Calendar.current.dateComponents([.weekOfMonth], from: date, to: self).weekOfMonth ?? 0
//    }
//    /// Returns the amount of days from another date
//    func days(from date: Date) -> Int {
//        return Calendar.current.dateComponents([.day], from: date, to: self).day ?? 0
//    }
//    /// Returns the amount of hours from another date
//    func hours(from date: Date) -> Int {
//        return Calendar.current.dateComponents([.hour], from: date, to: self).hour ?? 0
//    }
//    /// Returns the amount of minutes from another date
//    func minutes(from date: Date) -> Int {
//        return Calendar.current.dateComponents([.minute], from: date, to: self).minute ?? 0
//    }
//    /// Returns the amount of seconds from another date
//    func seconds(from date: Date) -> Int {
//        return Calendar.current.dateComponents([.second], from: date, to: self).second ?? 0
//    }
//    /// Returns the a custom time interval description from another date
//    func offset(from date: Date) -> String {
//        if years(from: date)   > 0 { return "\(years(from: date))y"   }
//        if months(from: date)  > 0 { return "\(months(from: date))M"  }
//        if weeks(from: date)   > 0 { return "\(weeks(from: date))w"   }
//        if days(from: date)    > 0 { return "\(days(from: date))d"    }
//        if hours(from: date)   > 0 { return "\(hours(from: date))h"   }
//        if minutes(from: date) > 0 { return "\(minutes(from: date))m" }
//        if seconds(from: date) > 0 { return "\(seconds(from: date))s" }
//        return ""
//    }
//}
