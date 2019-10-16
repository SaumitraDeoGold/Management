//
//  PartywiseComparisonController.swift
//  ManagementApp
//
//  Created by Goldmedal on 03/07/19.
//  Copyright © 2019 Goldmedal. All rights reserved.
//

import UIKit

class PartywiseComparisonController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate  {

    //Outlets...
    @IBOutlet weak var CollectionView: UICollectionView!
    @IBOutlet weak var noDataView: NoDataView!
    
    //Declarations...
    var cellContentIdentifier = "\(CollectionViewCell.self)"
    var partywiseApiUrl = ""
    var partwiseComp = [PartwiseComp]()
    var partwiseCompObj = [PartwiseCompObj]()
    var dataToRecieve = [ExpenseComparisonObj]()
    var type = ""
    var total = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        partywiseApiUrl = "https://test2.goldmedalindia.in/api/getManagementHeadwiseExpense"
        self.noDataView.hideView(view: self.noDataView)
        ViewControllerUtils.sharedInstance.showLoader()
        self.title = "Expense Head"
        apiGetPranchwiseComp()
    }
 
    //Collection View......
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.partwiseCompObj.count + 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
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
                cell.contentLabel.text = "Exp Header"
            case 1:
                cell.contentLabel.text = "Amount"
                
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
                cell.contentLabel.text = partwiseCompObj[indexPath.section - 1].headnm
            case 1:
                let currentYear = Double(partwiseCompObj[indexPath.section - 1].amount!)!
                let prevYear = Double(total)
                let temp = ((currentYear - prevYear)/prevYear)*100
                cell.contentLabel.attributedText = calculatePercentage(currentYear: currentYear, prevYear: prevYear, temp: temp)
//                if let amount = partwiseCompObj[indexPath.section - 1].amount
//                {
//                    cell.contentLabel.text = Utility.formatRupee(amount: Double(amount )!)
//                }
            default:
                break
            }
            //cell.backgroundColor = UIColor.groupTableViewBackground
        }
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //If item other than BranchName clicked then open next page...
        if let destination = segue.destination as? ExpenseHeadChildController,
            let index = CollectionView.indexPathsForSelectedItems?.first{
            if index.section > 0{
                destination.dataToRecieve = [partwiseCompObj[index.section-1]]
            }
            else{
                return
            }
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        //Block Segue if branchname is clicked...
        if let index = CollectionView.indexPathsForSelectedItems?.first{
            if((index.section) > 0){
                if index.section == self.partwiseCompObj.count + 1{
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
    
    //Calculate percentage func...
    func calculatePercentage(currentYear: Double, prevYear: Double, temp: Double) -> NSAttributedString{
        let sale = Utility.formatRupee(amount: Double(currentYear ))
        let tempVar = String(format: "%.2f", temp)
        var formattedPerc = ""
        if (Double(tempVar)!.isInfinite) || (Double(tempVar)!.isNaN){
            formattedPerc = ""
        }else{
            formattedPerc = " (\(String(format: "%.2f", temp)))%"
        }
        let strNumber: NSString = sale + formattedPerc as NSString // you must set your
        let range = (strNumber).range(of: String(tempVar))
        let attribute = NSMutableAttributedString.init(string: strNumber as String)
        if temp > 0{
            attribute.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor(named: "ColorGreen") as Any , range: range)
        }else{
            attribute.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.red as Any , range: range)
        }
        return attribute
    }
    
    //API CALLS...
    func apiGetPranchwiseComp(){
        
        let json: [String: Any] = ["CIN":UserDefaults.standard.value(forKey: "userCIN") as! String,"Category":UserDefaults.standard.value(forKey: "userCategory") as! String,"ClientSecret":"ClientSecret","BranchId":dataToRecieve[0].branchid!,"fromdate":"04/01/2018","todate":"03/31/2019" ]
        
        let manager =  DataManager.shared
        
        manager.makeAPICall(url: partywiseApiUrl, params: json, method: .POST, success: { (response) in
            let data = response as? Data 
            do {
                self.partwiseComp = try JSONDecoder().decode([PartwiseComp].self, from: data!)
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
