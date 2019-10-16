//
//  ExpenseHeadChildController.swift
//  ManagementApp
//
//  Created by Goldmedal on 31/08/19.
//  Copyright © 2019 Goldmedal. All rights reserved.
//

import UIKit

class ExpenseHeadChildController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    //Outlets...
    @IBOutlet weak var CollectionView: UICollectionView!
    @IBOutlet weak var noDataView: NoDataView!
    
    //Declarations...
    var cellContentIdentifier = "\(CollectionViewCell.self)"
    var partywiseApiUrl = ""
    var partwiseComp = [ExpenseHead]()
    var partwiseCompObj = [ExpenseHeadObj]()
    var dataToRecieve = [PartwiseCompObj]()
    var total = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        partywiseApiUrl = "https://test2.goldmedalindia.in/api/getManagementHeadwiseExpenseChild"
        self.noDataView.hideView(view: self.noDataView)
        ViewControllerUtils.sharedInstance.showLoader()
        self.title = "Expense Head PartyWise"
        apiGetPranchwiseComp()
        
    }
    
    //Collection View......
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.partwiseCompObj.count + 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
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
            case 1:
                cell.contentLabel.text = "Amount"
            case 2:
                cell.contentLabel.text = "Date"
                
            default:
                break
            }
            //cell.backgroundColor = UIColor.lightGray
        }else if indexPath.section == partwiseCompObj.count{
            cell.contentLabel.font = UIFont(name: "Roboto-Medium", size: 16)
            if #available(iOS 11.0, *) {
                cell.backgroundColor = UIColor.init(named: "Primary")
            } else {
                cell.backgroundColor = UIColor.gray
            }
            switch indexPath.row{
            case 0:
                cell.contentLabel.text = "SUM"
            case 1:
                cell.contentLabel.text = Utility.formatRupee(amount: Double(total))
                cell.contentLabel.textColor = UIColor.black
            case 2:
                cell.contentLabel.text = "DATE"
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
                cell.contentLabel.text = partwiseCompObj[indexPath.section - 1].partynm
            case 1:
                if let amount = partwiseCompObj[indexPath.section - 1].amount
                {
                    cell.contentLabel.text = Utility.formatRupee(amount: Double(amount )!)
                }
            case 2:
                cell.contentLabel.text = partwiseCompObj[indexPath.section - 1].date
            default:
                break
            }
            //cell.backgroundColor = UIColor.groupTableViewBackground
        }
        return cell
    }
    
    //API CALLS...
    func apiGetPranchwiseComp(){
        
        let json: [String: Any] = ["CIN":UserDefaults.standard.value(forKey: "userCIN") as! String,"Category":UserDefaults.standard.value(forKey: "userCategory") as! String,"ClientSecret":"ClientSecret","BranchId":dataToRecieve[0].branchid!,"fromdate":"04/01/2018","todate":"03/31/2019","headnm":dataToRecieve[0].headnm!]
        
        let manager =  DataManager.shared
        
        manager.makeAPICall(url: partywiseApiUrl, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            
            do {
                self.partwiseComp = try JSONDecoder().decode([ExpenseHead].self, from: data!)
                self.partwiseCompObj  = self.partwiseComp[0].data
                self.total = self.partwiseCompObj.reduce(0, { $0 + Double($1.amount!)! })//Utility.formatRupee(amount: Double(temp ))
                self.CollectionView.reloadData()
                self.CollectionView.collectionViewLayout.invalidateLayout()
                self.noDataView.hideView(view: self.noDataView)
                ViewControllerUtils.sharedInstance.removeLoader()
            } catch let errorData {
                print(errorData.localizedDescription)
                ViewControllerUtils.sharedInstance.removeLoader()
                self.noDataView.showView(view: self.noDataView, from: "NDA")
            }
        }) { (Error) in
            print(Error?.localizedDescription as Any)
            ViewControllerUtils.sharedInstance.removeLoader()
            self.noDataView.showView(view: self.noDataView, from: "NDA")
        }
        
    }
    
}
