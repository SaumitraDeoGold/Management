//
//  AccountsDetailsController.swift
//  ManagementApp
//
//  Created by Goldmedal on 21/05/19.
//  Copyright © 2019 Goldmedal. All rights reserved.
//

import UIKit

class AccountsDetailsController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    //OUTLETS...
    @IBOutlet weak var CollectionView: UICollectionView!
    
    //DECLARATIONS...
    var accDetails = [AccountDetails]()
    var accDetailsObj = [AccountDetailsObj]()
    var AccountDetailsApiUrl = ""
    var cellContentIdentifier = "\(CollectionViewCell.self)"
    var filteredItems = [AccountDetailsObj]()
    var dataToRecieve = [AccountsOutstandingObj]()
    var total = 0.0
    var totalAmtPaid = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        AccountDetailsApiUrl = "https://api.goldmedalindia.in/api/GetManagementBranchwiseOutstandingChild"
        ViewControllerUtils.sharedInstance.showLoader()
        apiAccDetails()
    }
    
    //Collection View......
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if collectionView == self.CollectionView{
            return self.filteredItems.count + 2
        }else{
            return 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 6
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        let cell = CollectionView.dequeueReusableCell(withReuseIdentifier: cellContentIdentifier,
                                                      for: indexPath) as! CollectionViewCell
        cell.layer.borderWidth = 1
        cell.layer.borderColor = UIColor.white.cgColor
        if indexPath.section == 0 {
            cell.contentLabel.font = UIFont(name: "Roboto-Medium", size: 16)
            if #available(iOS 11.0, *) {
                cell.backgroundColor = UIColor.init(named: "Primary")
            } else {
                cell.backgroundColor = UIColor.gray
            }
            switch indexPath.row{
            case 0:
                cell.contentLabel.text = "Party Name"
            case 4:
                cell.contentLabel.text = "Last Invoice Date"
            case 5:
                cell.contentLabel.text = "Last Payment Date"
            case 1:
                cell.contentLabel.text = "Last Payment Amt"
            case 2:
                cell.contentLabel.text = "OS Amount"
            case 3:
                cell.contentLabel.text = "OS %"
            default:
                break
            }
        }else if indexPath.section == self.filteredItems.count + 1 {
            cell.contentLabel.font = UIFont(name: "Roboto-Medium", size: 16)
            if #available(iOS 11.0, *) {
                cell.backgroundColor = UIColor.init(named: "Primary")
            } else {
                cell.backgroundColor = UIColor.gray
            }
            switch indexPath.row{
            case 0:
                cell.contentLabel.text = "SUM"
            case 4:
                cell.contentLabel.text = "Date"
            case 5:
                let now = Date()
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd/MM/YYYY"
                cell.contentLabel.text = dateFormatter.string(from: now)
            case 1:
                cell.contentLabel.text = Utility.formatRupee(amount: Double(totalAmtPaid ))
            case 2:
                cell.contentLabel.text = Utility.formatRupee(amount: Double(total ))
            case 3:
                cell.contentLabel.text = "100%"
            default:
                break
            }
        } else {
            cell.contentLabel.font = UIFont(name: "Roboto-Regular", size: 14)
            if #available(iOS 11.0, *) {
                cell.backgroundColor = UIColor.init(named: "primaryLight")
            } else {
                cell.backgroundColor = UIColor.lightGray
            }
            switch indexPath.row{
            case 0:
                cell.contentLabel.text = filteredItems[indexPath.section - 1].partynm
                if filteredItems[indexPath.section - 1].partystatus != "Active"{
                    cell.contentLabel.textColor = UIColor(named: "ColorRed")
                }else{
                    cell.contentLabel.textColor = UIColor.black
                }
            case 4:
                cell.contentLabel.textColor = UIColor.black
                cell.contentLabel.text = filteredItems[indexPath.section - 1].lstinvoicedt
            case 5:
                cell.contentLabel.textColor = UIColor.black
                    cell.contentLabel.text = filteredItems[indexPath.section - 1].lstpaymentdt
            case 1:
                cell.contentLabel.textColor = UIColor.black
                if let lstpaymentamt = filteredItems[indexPath.section - 1].lstpaymentamt
                {
                    cell.contentLabel.text = Utility.formatRupee(amount: Double(lstpaymentamt ) ?? 0)
                }
            case 2:
                cell.contentLabel.textColor = UIColor.black
                if let salependingamt = filteredItems[indexPath.section - 1].outstandingamt
                {
                    cell.contentLabel.text = Utility.formatRupee(amount: Double(salependingamt )!)
                }
            case 3:
                let percentage = ((Double(self.filteredItems[indexPath.section - 1].outstandingamt!)! / total)*100)
                cell.contentLabel.text = "\(String(format: "%.2f", percentage))%"
            default:
                break
            }
        }
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == self.filteredItems.count + 1{
            
        }else{
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.sendCin = filteredItems[indexPath.section-1].cin!
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if let index = CollectionView.indexPathsForSelectedItems?.first{
            if index.section == self.filteredItems.count + 1{
                return false
            }else{
                return true 
            }
        }else{
            return false
        }
    }
    
    //API Function...
    func apiAccDetails(){
        
        let json: [String: Any] = ["CIN":UserDefaults.standard.value(forKey: "userCIN") as! String,"Category":UserDefaults.standard.value(forKey: "userCategory") as! String,"ClientSecret":"ClientSecret","branchid":dataToRecieve[0].branchid!]
        
        let manager =  DataManager.shared
        
        manager.makeAPICall(url: AccountDetailsApiUrl, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            
            do {
                self.accDetails = try JSONDecoder().decode([AccountDetails].self, from: data!)
                self.accDetailsObj = self.accDetails[0].data
                self.filteredItems = self.accDetails[0].data
                //Store Total of Outstanding amount...
                self.total = self.filteredItems.reduce(0, { $0 + Double($1.outstandingamt!)! })
                self.totalAmtPaid = self.filteredItems.reduce(0, { $0 + Double($1.lstpaymentamt!)! })
                self.CollectionView.reloadData()
                self.CollectionView.collectionViewLayout.invalidateLayout()
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
