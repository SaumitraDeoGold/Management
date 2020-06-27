//
//  SearchViewController.swift
//  ManagementApp
//
//  Created by Goldmedal on 24/03/20.
//  Copyright © 2020 Goldmedal. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    //Outlets...
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textField: UITextField!
    
    //Declarations...
    var delegate: PopupDateDelegate?
    var apiGetBranchUrl = ""
    var apiSuppliernLedgerUrl = ""
    var supplierLedger = [SupplierLedger]()
    var supplierLedgerObj = [SupplierLedgerObj]()
    //For Supplier...
    var supplier = [Supplier]()
    var tempSupplier = [Supplier]()
    var filteredSupplier = [Supplier]()
    //For Ledger...
    var ledger = [Ledger]()
    var tempLedger = [Ledger]()
    var filteredLedger = [Ledger]()
    var (dateFrom,dateTo) = Utility.yearDate()
    var from = ""
    //For Branch...
    var branchData = [BranchData]()
    var branchObj = [BranchObj]()
    var tempBranchArr = [BranchObj]()
    var filteredItems = [BranchObj]()
    //For Dist...
    var distItems = [DistrictwiseDhanObj]()
    var tempDist = [DistrictwiseDhanObj]()
    //For State...
    var stateItems = [DhanbarseObj]()
    var tempState = [DhanbarseObj]()
    //For City...
    var filteredCity = [DhanCitywiseObj]()
    var tempCity = [DhanCitywiseObj]()
    
    //For ALL...
    var alltype = [[String : String]]()
    var tempAll = [[String : String]]()
    
    //For ALL NEW...
    var commonSearchObj = [CommonSearchObj]()
    var tempCommonObj = [CommonSearchObj]()
    var placeholder = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        blurBackground()
        apiGetBranchUrl = "https://api.goldmedalindia.in/api/getListsofAllBranch"
        apiSuppliernLedgerUrl = "https://test2.goldmedalindia.in/api/getallExpenseChildAllSubChildList"
        tempDist = distItems
        tempState = stateItems
        tempCity = filteredCity
        tempAll = alltype
        if from == "branch"{
            textField.placeholder = "Search Branch"
            ViewControllerUtils.sharedInstance.showLoader()
            apiGetBranch()
        }else if from == "common"{
            textField.placeholder = placeholder
            self.textField.addTarget(self, action: #selector(self.searchRecords(_ :)), for: .editingChanged)
        }else if from == "all"{
            textField.placeholder = "Search..."
            self.textField.addTarget(self, action: #selector(self.searchRecords(_ :)), for: .editingChanged)
        }else if from == "dist"{
            textField.placeholder = "Search District"
            self.textField.addTarget(self, action: #selector(self.searchRecords(_ :)), for: .editingChanged)
        }else if from == "state"{
            textField.placeholder = "Search State"
            self.textField.addTarget(self, action: #selector(self.searchRecords(_ :)), for: .editingChanged)
        }else if from == "city"{
            textField.placeholder = "Search City"
            self.textField.addTarget(self, action: #selector(self.searchRecords(_ :)), for: .editingChanged)
        }else{
            textField.placeholder = from == "supplier" ? "Search Supplier" : "Search Ledger"
            ViewControllerUtils.sharedInstance.showLoader()
            apiSupplierLedger()
        }
        
    }
    
    //Blur Effect...
    func blurBackground() {
        if !UIAccessibility.isReduceTransparencyEnabled {
            mainView.backgroundColor = .clear
            let blurEffect = UIBlurEffect(style: .dark)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            //always fill the view
            blurEffectView.frame = self.view.bounds
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            mainView.addSubview(blurEffectView) //if you have more UIViews, use an insertSubview API to place it where needed
            mainView.sendSubview(toBack: blurEffectView)
        }
    }
    
    //Button...
    @IBAction func cancelPopup(_ sender: Any) {
        dismiss(animated: false)
    }
    
    //Auto-Complete Function...
    @objc func searchRecords(_ textfield: UITextField){
        if from == "branch"{
            self.filteredItems.removeAll()
            if textfield.text?.count != 0{
                for dealers in tempBranchArr{
                    let range = dealers.branchnm!.lowercased().range(of: textfield.text!, options: .caseInsensitive, range: nil, locale: nil)
                    if range != nil{
                        filteredItems.append(dealers)
                    }
                }
            }else{
                for dealers in tempBranchArr{
                    filteredItems.append(dealers)
                }
            }
        }else if from == "common"{
            self.commonSearchObj.removeAll()
            if textfield.text?.count != 0{
                for supps in tempCommonObj{
                    
                    let range = supps.name!.lowercased().range(of: textfield.text!, options: .caseInsensitive, range: nil, locale: nil)
                    if range != nil{
                        commonSearchObj.append(supps)
                    }
                }
            }else{
                for supps in tempCommonObj{
                    commonSearchObj.append(supps)
                }
            }
        }else if from == "supplier"{
            self.filteredSupplier.removeAll()
            if textfield.text?.count != 0{
                for supps in tempSupplier{
                    
                    let range = supps.name!.lowercased().range(of: textfield.text!, options: .caseInsensitive, range: nil, locale: nil)
                    if range != nil{
                        filteredSupplier.append(supps)
                    }
                }
            }else{
                for supps in tempSupplier{
                    filteredSupplier.append(supps)
                }
            }
        }else if from == "all"{
            self.alltype.removeAll()
            if textfield.text?.count != 0{
                for supps in tempAll{
                    let range = supps["name"]!.lowercased().range(of: textfield.text!, options: .caseInsensitive, range: nil, locale: nil)
                    if range != nil{
                        alltype.append(supps)
                    }
                }
            }else{
                for supps in tempAll{
                    alltype.append(supps)
                }
            }
        }else if from == "dist"{
            self.distItems.removeAll()
            if textfield.text?.count != 0{
                for supps in tempDist{
                    
                    let range = supps.district!.lowercased().range(of: textfield.text!, options: .caseInsensitive, range: nil, locale: nil)
                    if range != nil{
                        distItems.append(supps)
                    }
                }
            }else{
                for supps in tempDist{
                    distItems.append(supps)
                }
            }
        }else if from == "state"{
            self.stateItems.removeAll()
            if textfield.text?.count != 0{
                for supps in tempState{
                    
                    let range = supps.stateName!.lowercased().range(of: textfield.text!, options: .caseInsensitive, range: nil, locale: nil)
                    if range != nil{
                        stateItems.append(supps)
                    }
                }
            }else{
                for supps in tempState{
                    stateItems.append(supps)
                }
            }
        }else if from == "city"{
            self.filteredCity.removeAll()
            if textfield.text?.count != 0{
                for supps in tempCity{
                    let range = supps.city!.lowercased().range(of: textfield.text!, options: .caseInsensitive, range: nil, locale: nil)
                    if range != nil{
                        filteredCity.append(supps)
                    }
                }
            }else{
                for supps in tempCity{
                    filteredCity.append(supps)
                }
            }
        }else{
            self.filteredLedger.removeAll()
            if textfield.text?.count != 0{
                for dealers in tempLedger{
                    let range = dealers.name!.lowercased().range(of: textfield.text!, options: .caseInsensitive, range: nil, locale: nil)
                    if range != nil{
                        filteredLedger.append(dealers)
                    }
                }
            }else{
                for dealers in tempLedger{
                    filteredLedger.append(dealers)
                }
            }
        }
        tableView.reloadData()
    }
    
    //TableView Functions...
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if from == "branch"{
            return filteredItems.count + 1
        }else if from == "supplier"{
            return filteredSupplier.count
        }else if from == "dist"{
            return distItems.count + 1
        }else if from == "state"{
            return stateItems.count + 1
        }else if from == "city"{
            return filteredCity.count + 1
        }else if from == "all"{
            return alltype.count + 1
        }else if from == "common"{
            return commonSearchObj.count
        }else{
            return filteredLedger.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchCell", for: indexPath)
        if from == "branch"{
            if(indexPath.row == 0){
                cell.textLabel?.text = "ALL"
            }else{
                cell.textLabel?.text = filteredItems[indexPath.row-1].branchnm
            }
        }else if from == "supplier"{
            cell.textLabel?.text = filteredSupplier[indexPath.row].name
        }else if from == "common"{
            cell.textLabel?.text = commonSearchObj[indexPath.row].name
        }else if from == "dist"{
            if(indexPath.row == 0){
                cell.textLabel?.text = "ALL"
            }else{
                cell.textLabel?.text = distItems[indexPath.row-1].district
            } 
        }else if from == "all"{
            if(indexPath.row == 0){
                cell.textLabel?.text = "ALL"
            }else{
                cell.textLabel?.text = alltype[indexPath.row-1]["name"]
            }
        }else if from == "state"{
            if(indexPath.row == 0){
                cell.textLabel?.text = "ALL"
            }else{
                cell.textLabel?.text = stateItems[indexPath.row-1].stateName
            }
        }else if from == "city"{
            if(indexPath.row == 0){
                cell.textLabel?.text = "ALL"
            }else{
                cell.textLabel?.text = filteredCity[indexPath.row-1].city
            }
        }else{
            cell.textLabel?.text = filteredLedger[indexPath.row].name
        }
        
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if from == "branch"{
            if indexPath.row == 0{
              delegate?.showSearchValue!(value: "ALL")
            }else{
              delegate?.showSearchValue!(value: filteredItems[indexPath.row-1].branchnm!)
            }
        }else if from == "supplier"{
            delegate?.showSearchValue!(value: filteredSupplier[indexPath.row].name!)
        }else if from == "common"{
            delegate?.showParty?(value: commonSearchObj[indexPath.row].name!, cin: commonSearchObj[indexPath.row].slno!)
        }else if from == "dist"{
            if indexPath.row == 0{
                delegate?.showSearchValue!(value: "ALL")
            }else{
                delegate?.showSearchValue!(value: distItems[indexPath.row-1].district!)
            }
            
        }else if from == "all"{
            if indexPath.row == 0{
                delegate?.showSearchValue!(value: "ALL")
            }else{
                delegate?.showSearchValue!(value: alltype[indexPath.row-1]["name"]!)
            }
            
        }else if from == "state"{
            if indexPath.row == 0{
                delegate?.showSearchValue!(value: "ALL")
            }else{
                delegate?.showSearchValue!(value: stateItems[indexPath.row-1].stateName!)
            }
            
        }else if from == "city"{
            if indexPath.row == 0{
                delegate?.showSearchValue!(value: "ALL")
            }else{
                delegate?.showSearchValue!(value: filteredCity[indexPath.row-1].city!)
            }
            
        } else{
            delegate?.showSearchValue!(value: filteredLedger[indexPath.row].name!)
        }
        dismiss(animated: true)
    }
    
    func apiGetBranch(){
        
        let json: [String: Any] = ["ClientSecret":"clientsecret","CIN":UserDefaults.standard.value(forKey: "userCIN") as! String,"Category":UserDefaults.standard.value(forKey: "userCategory") as! String]
        
        let manager =  DataManager.shared
        
        manager.makeAPICall(url: apiGetBranchUrl, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            
            do {
                self.branchData = try JSONDecoder().decode([BranchData].self, from: data!)
                self.branchObj  = self.branchData[0].data
                self.tempBranchArr  = self.branchData[0].data
                self.filteredItems  = self.branchData[0].data
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
    
    
    
    func apiSupplierLedger(){
        
        let json: [String: Any] = ["ClientSecret":"clientsecret","CIN":UserDefaults.standard.value(forKey: "userCIN") as! String,"Cat":UserDefaults.standard.value(forKey: "userCategory") as! String,"Fromdate":dateFrom,"Todate":dateTo]
        
        let manager =  DataManager.shared
        
        manager.makeAPICall(url: apiSuppliernLedgerUrl, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            
            do {
                self.supplierLedger = try JSONDecoder().decode([SupplierLedger].self, from: data!)
                self.supplierLedgerObj  = self.supplierLedger[0].data
                self.supplier  = self.supplierLedgerObj[0].supplier
                self.tempSupplier  = self.supplierLedgerObj[0].supplier
                self.filteredSupplier  = self.supplierLedgerObj[0].supplier
                self.ledger  = self.supplierLedgerObj[0].ledger
                self.tempLedger  = self.supplierLedgerObj[0].ledger
                self.filteredLedger  = self.supplierLedgerObj[0].ledger
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
