//
//  LimitDetailsController.swift
//  ManagementApp
//
//  Created by Goldmedal on 17/10/19.
//  Copyright © 2019 Goldmedal. All rights reserved.
//

import UIKit

class LimitDetailsController: UIViewController, UITableViewDelegate , UITableViewDataSource {

    //Outlet...
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textField: UITextField!
    
    //Declarations...
    var cellContentIdentifier = "\(LimitDetailsCell.self)"
    var limitDetailsApiUrl = ""
    var incLimitDetails = [IncreasedLimitDetails]()
    var incLimitDetailsObj = [IncreasedLimitDetailsObj]()
    var tempDealersArr = [IncreasedLimitDetailsObj]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorStyle = .none
        limitDetailsApiUrl = "https://api.goldmedalindia.in/api/GetIncreaseLimitPartyDetails"
        ViewControllerUtils.sharedInstance.showLoader()
        apiLimitDetails()
    }
    
    //Auto-Complete Function...
    @objc func searchRecords(_ textfield: UITextField){
        self.incLimitDetailsObj.removeAll()
        if textfield.text?.count != 0{
            for dealers in tempDealersArr{
                let range = dealers.displaynm!.lowercased().range(of: textfield.text!, options: .caseInsensitive, range: nil, locale: nil)
                if range != nil{
                    incLimitDetailsObj.append(dealers)
                }
            }
        }else{
            for dealers in tempDealersArr{
                incLimitDetailsObj.append(dealers)
            }
        }
        tableView.reloadData()
    }
    
    //Tableview Functions...
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return incLimitDetailsObj.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LimitDetailsCell", for: indexPath) as! LimitDetailsCell
        cell.lblPartyName.text = incLimitDetailsObj[indexPath.row].displaynm
        cell.lblCreatedBy.text = incLimitDetailsObj[indexPath.row].usernm
        cell.lblDate.text = incLimitDetailsObj[indexPath.row].creatdt
        cell.lblStatus.text = incLimitDetailsObj[indexPath.row].status
        if let amount = incLimitDetailsObj[indexPath.row].increaselimit
        {
            cell.lblAmount.text = Utility.formatRupee(amount: Double(amount)!)
        }
        if let usedAmount = incLimitDetailsObj[indexPath.row].uselimit
        {
            cell.lblUsedAmt.text = Utility.formatRupee(amount: Double(usedAmount)!)
        }
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        return cell
    }
    
    
    //API Function...
    func apiLimitDetails(){
        
        let json: [String: Any] = ["userid":UserDefaults.standard.value(forKey: "userID") as! Int,"searchtxt":""]
        print("Limit DETAILS : \(json)")
        let manager =  DataManager.shared
        
        manager.makeAPICall(url: limitDetailsApiUrl, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            do {
                self.incLimitDetails = try JSONDecoder().decode([IncreasedLimitDetails].self, from: data!)
                self.incLimitDetailsObj = self.incLimitDetails[0].data
                self.tempDealersArr = self.incLimitDetails[0].data
                self.textField.addTarget(self, action: #selector(self.searchRecords(_ :)), for: .editingChanged)
                self.tableView.reloadData()
                ViewControllerUtils.sharedInstance.removeLoader()
            } catch let errorData {
                print(errorData.localizedDescription)
                ViewControllerUtils.sharedInstance.removeLoader()
            }
        }) { (Error) in
            print(Error?.localizedDescription as Any)
            ViewControllerUtils.sharedInstance.removeLoader()
        }
        
    }

}
