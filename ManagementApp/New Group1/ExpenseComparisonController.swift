
//  ExpenseComparisonController.swift
//  ManagementApp
//
//  Created by Goldmedal on 28/06/19.
//  Copyright © 2019 Goldmedal. All rights reserved.
//

import UIKit

class ExpenseComparisonController: UIViewController, PopupDateDelegate, UICollectionViewDataSource, UICollectionViewDelegate {
    
    
    //Outlets...
    @IBOutlet weak var CollectionView: UICollectionView!
    @IBOutlet weak var sort: UIImageView!
    
    //Declarations...
    var expenseComparisonUrl = ""
    var expCompare = [ExpenseComparison]()
    var expCompareObj = [ExpenseComparisonObj]()
    var filteredItems = [ExpenseComparisonObj]()
    var cellContentIdentifier = "\(CollectionViewCell.self)"
    var totalSal = 0.0
    var totalExp = 0.0
    var totalSale = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        expenseComparisonUrl = "https://test2.goldmedalindia.in/api/getManagementBranchwiseExpense"
        ViewControllerUtils.sharedInstance.showLoader()
        apiExpComparison()
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        sort.isUserInteractionEnabled = true
        sort.addGestureRecognizer(tapGestureRecognizer)
    }
    
    //Sort Related...
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        let sb = UIStoryboard(name: "Sorting", bundle: nil)
        let popup = sb.instantiateInitialViewController()! as! SortViewController
        popup.modalPresentationStyle = .overFullScreen
        popup.delegate = self
        popup.showPicker = 1
        popup.pickerDataSource = ["A-Z","Z-A","low to high Sales","high to low Sales"]
        self.present(popup, animated: true)
    }
    
    func sortBy(value: String, position: Int) {
        switch position {
        case 0:
            self.filteredItems = self.expCompareObj.sorted{($0.branchnm)!.localizedCaseInsensitiveCompare($1.branchnm!) == .orderedAscending}
        case 1:
            self.filteredItems = self.expCompareObj.sorted{($0.branchnm)!.localizedCaseInsensitiveCompare($1.branchnm!) == .orderedDescending}
        case 2:
            self.filteredItems = self.expCompareObj.sorted(by: {Double($0.sale!)! < Double($1.sale!)!})
        case 3:
            self.filteredItems = self.expCompareObj.sorted(by: {Double($0.sale!)! > Double($1.sale!)!})
        default:
            break
        }
        
        self.CollectionView.reloadData()
        self.CollectionView.collectionViewLayout.invalidateLayout()
    }
    
    //CollectionView Functions...
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return expCompareObj.count + 2
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
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
                cell.contentLabel.text = "Branch Name"
            case 1:
                cell.contentLabel.text = "Sale"
                cell.contentLabel.textColor = UIColor.black
            case 2:
                cell.contentLabel.text = "Expense"
            case 3:
                cell.contentLabel.text = "Salary"
            default:
                break
            }
            cell.backgroundColor = UIColor.lightGray
        }else if indexPath.section == expCompareObj.count + 1{
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
                cell.contentLabel.text = Utility.formatRupee(amount: Double(totalSale))
                cell.contentLabel.textColor = UIColor.black
            case 3:
                cell.contentLabel.text = Utility.formatRupee(amount: Double(totalSal))
                cell.contentLabel.textColor = UIColor.black
            case 2:
                cell.contentLabel.text = Utility.formatRupee(amount: Double(totalExp))
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
                cell.contentLabel.text = filteredItems[indexPath.section - 1].branchnm
            case 1:
                if let otherespenses = filteredItems[indexPath.section - 1].sale
                {
                    cell.contentLabel.text = Utility.formatRupee(amount: Double(otherespenses )!)
                }
            case 2:
                let percentage = ((Double(self.filteredItems[indexPath.section - 1].otherespenses!)! / (Double(filteredItems[indexPath.section - 1].sale!)!))*100)
                if let otherespenses = filteredItems[indexPath.section - 1].otherespenses
                {
                    cell.contentLabel.text = "\(Utility.formatRupee(amount: Double(otherespenses )!)) (\(String(format: "%.2f", percentage))%)"
                }
            case 3:
                let percentage = ((Double(self.filteredItems[indexPath.section - 1].salary!)! / (Double(filteredItems[indexPath.section - 1].sale!)!))*100)
                if let salary = self.filteredItems[indexPath.section - 1].salary
                {
                    cell.contentLabel.text = "\(Utility.formatRupee(amount: Double(salary )!)) (\(String(format: "%.2f", percentage))%)"
                }
            default:
                break
            }
            cell.backgroundColor = UIColor.groupTableViewBackground
        }
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? PartywiseComparisonController,
            let index = CollectionView.indexPathsForSelectedItems?.first{
            destination.dataToRecieve = [filteredItems[index.section-1]]
            //destination.type = index.row == 2 ? "2" : "1"
        }
    }

    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if let index = CollectionView.indexPathsForSelectedItems?.first{
            if((index.section) > 0){
                if index.section == self.filteredItems.count + 1{
                    return false
                }else{
                    return true}
            }else{
                return false
            }
        }else{
            return false
        }
    }
    
    //API CALLS..............
    func apiExpComparison(){
        
        let json: [String: Any] = ["ClientSecret":"jgsfhfdk", "fromdate":"12/31/2018", "todate":"12/31/2019","CIN":UserDefaults.standard.value(forKey: "userCIN") as! String,"Category":UserDefaults.standard.value(forKey: "userCategory") as! String,]
        
        let manager =  DataManager.shared
        print("Accounts exp comp params \(json)")
        manager.makeAPICall(url: expenseComparisonUrl, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            print("Accounts exp comp result \(data)")
            do {
                self.expCompare = try JSONDecoder().decode([ExpenseComparison].self, from: data!)
                self.expCompareObj = self.expCompare[0].data
                self.filteredItems = self.expCompare[0].data
                self.totalSal = self.expCompareObj.reduce(0, { $0 + Double($1.salary!)! })
                self.totalExp = self.expCompareObj.reduce(0, { $0 + Double($1.otherespenses!)! })
                self.totalSale = self.expCompareObj.reduce(0, { $0 + Double($1.sale!)! })
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
