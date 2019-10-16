//
//  NDADetailViewController.swift
//  ManagementApp
//
//  Created by Goldmedal on 26/03/19.
//  Copyright © 2019 Goldmedal. All rights reserved.
//

import UIKit

class NDADetailViewController: UIViewController, UITableViewDelegate , UITableViewDataSource {
 
    //Outlet...
    @IBOutlet weak var tableView: UITableView!
    
    //Declarations...
    var cellContentIdentifier = "\(NDADetailCell.self)"
    var NDATransferArray = [[NDAObj]]()
    var ndaDetailsApiUrl = ""
    var ndaDetail = [NDADetail]()
    var ndaDetailArray = [NDADetailObj]()
    let gradientLayer = CAGradientLayer()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ViewControllerUtils.sharedInstance.showLoader()
        ndaDetailsApiUrl = "https://api.goldmedalindia.in/api/GetNDAReportAll"
        apiNDADetails()
        tableView.separatorStyle = .none
        
    }
    
    //Tableview Functions...
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 160
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ndaDetailArray.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NDADetailCell", for: indexPath) as! NDADetailCell
        //_ = self.ndaDetailArray[indexPath.row].name!.characters.split{$0 == "-"}.map(String.init)
        cell.lblName.text = self.ndaDetailArray[indexPath.row].name
        if let amount = self.ndaDetailArray[indexPath.row].amount {
            cell.lblAmount.text = Utility.formatRupee(amount: Double(amount)!)
        }
        cell.lblSalesEx.text = self.ndaDetailArray[indexPath.row].salesExecutive
        cell.lblJoiningDate.text = self.ndaDetailArray[indexPath.row].joinDate
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //Set Global Cin Number and send to next page[Old Dashboard]...
        appDelegate.sendCin = ndaDetailArray[indexPath.item].cin!
    }
    
    //API Function...
    func apiNDADetails(){
        
        let json: [String: Any] = ["CIN":UserDefaults.standard.value(forKey: "userCIN") as! String,"Category":UserDefaults.standard.value(forKey: "userCategory") as! String,"month":NDATransferArray[0][0].month as Any,"ClientSecret":"54656","year":NDATransferArray[0][0].year as Any,"BranchId":NDATransferArray[0][0].branchid as Any]
        print("NDA DETAILS : \(json)")
        let manager =  DataManager.shared
        
        manager.makeAPICall(url: ndaDetailsApiUrl, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            
            do {
                self.ndaDetail = try JSONDecoder().decode([NDADetail].self, from: data!)
                self.ndaDetailArray = self.ndaDetail[0].data
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
