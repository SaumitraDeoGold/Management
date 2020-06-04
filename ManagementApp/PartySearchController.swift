//
//  PartySearchController.swift
//  ManagementApp
//
//  Created by Goldmedal on 17/10/19.
//  Copyright © 2019 Goldmedal. All rights reserved.
//

import UIKit

class PartySearchController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    //Outlets...
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var btnCancel: RoundButton!
    
    //Declarations...
    var delegate: PopupDateDelegate?
    var limitDetailsApiUrl = ""
    //var limitDetails = [LimitDetails]()
    var limitDetailsObj = [LimitDetailsObj]()
    var tempDealersArr = [LimitDetailsObj]()
    var divisionNameApiUrl = ""
    var divisionName = [DivisionName]()
    var divisionNameObj = [DivisionNameObj]()
    var tempDivNames = [DivisionNameObj]()
    var fromPage = ""
    var categoryApiUrl = ""
    var dateTo = ""
    var dateFrom = ""
    var prevDateTo = ""
    var prevDateFrom = ""
    var divCode = ""
    //var categorywiseComp = [Categorywise]()
    var categorywiseCompObj = [CategorywiseObj]()
    var tempCategory = [CategorywiseObj]()
    var supplierArray = [SearchVendorObj]()
    var tempSupplierArr = [SearchVendorObj]()
    
    var subCatObj = [SubCategoryObj]()
    var tempSubCatObj = [SubCategoryObj]()
    var multipleSelector = false
    var divSelected = [String]()
    
    var subCatItems = [SubCatItemListObj]()
    var tempSubCatItemsObj = [SubCatItemListObj]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        blurBackground()
        limitDetailsApiUrl = "https://api.goldmedalindia.in/api/GetDealerListManagment"
        divisionNameApiUrl = "https://api.goldmedalindia.in/api/GetDivisionListManagement"
        categoryApiUrl = "https://api.goldmedalindia.in/api/GetCategoryWiseSalesCompare"
        ViewControllerUtils.sharedInstance.showLoader()
        if fromPage == "Limits"{
            tempDealersArr = limitDetailsObj
            self.textField.addTarget(self, action: #selector(self.searchRecords(_ :)), for: .editingChanged)
            self.tableView.reloadData()
            ViewControllerUtils.sharedInstance.removeLoader()
            //apiLimitDetails()
        }else if fromPage == "Catchild"{
            tempCategory = categorywiseCompObj
            self.textField.addTarget(self, action: #selector(self.searchRecords(_ :)), for: .editingChanged)
            self.tableView.reloadData()
            ViewControllerUtils.sharedInstance.removeLoader()
            //apiCompare()
        }else if fromPage == "Vendors"{
            self.textField.addTarget(self, action: #selector(self.searchRecords(_ :)), for: .editingChanged)
            self.tableView.reloadData()
            ViewControllerUtils.sharedInstance.removeLoader()
            //apiCompare()
        }else if fromPage == "SubCat"{
            self.textField.addTarget(self, action: #selector(self.searchRecords(_ :)), for: .editingChanged)
            self.tableView.reloadData()
            ViewControllerUtils.sharedInstance.removeLoader()
            //apiCompare()
        }else if fromPage == "Items"{
            self.textField.addTarget(self, action: #selector(self.searchRecords(_ :)), for: .editingChanged)
            self.tableView.reloadData()
            ViewControllerUtils.sharedInstance.removeLoader()
            //apiCompare()
        }else{
            if multipleSelector{
                btnCancel.setTitle("Submit", for: .normal)
            }
            apiDivisionNames()
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
    
    //Auto-Complete Function...
    @objc func searchRecords(_ textfield: UITextField){
        if fromPage == "Limits"{
            self.limitDetailsObj.removeAll()
            if textfield.text?.count != 0{
                for dealers in tempDealersArr{
                    let range = dealers.displaynm!.lowercased().range(of: textfield.text!, options: .caseInsensitive, range: nil, locale: nil)
                    if range != nil{
                        limitDetailsObj.append(dealers)
                    }
                }
            }else{
                for dealers in tempDealersArr{
                    limitDetailsObj.append(dealers)
                }
            }
        }else if fromPage == "Catchild"{
            self.categorywiseCompObj.removeAll()
            if textfield.text?.count != 0{
                for dealers in tempCategory{
                    let range = dealers.categorynm!.lowercased().range(of: textfield.text!, options: .caseInsensitive, range: nil, locale: nil)
                    if range != nil{
                        categorywiseCompObj.append(dealers)
                    }
                }
            }else{
                for dealers in tempCategory{
                    categorywiseCompObj.append(dealers)
                }
            }
        }else if fromPage == "Vendors"{
            self.supplierArray.removeAll()
            if textfield.text?.count != 0{
                for dealers in tempSupplierArr{
                    let range = dealers.vendornm!.lowercased().range(of: textfield.text!, options: .caseInsensitive, range: nil, locale: nil)
                    if range != nil{
                        supplierArray.append(dealers)
                    }
                }
            }else{
                for dealers in tempSupplierArr{
                    supplierArray.append(dealers)
                }
            }
        }else if fromPage == "SubCat"{
            self.subCatObj.removeAll()
            if textfield.text?.count != 0{
                for dealers in tempSubCatObj{
                    let range = dealers.subcatnm!.lowercased().range(of: textfield.text!, options: .caseInsensitive, range: nil, locale: nil)
                    if range != nil{
                        subCatObj.append(dealers)
                    }
                }
            }else{
                for dealers in tempSubCatObj{
                    subCatObj.append(dealers)
                }
            }
        }else if fromPage == "Items"{
            self.subCatItems.removeAll()
            if textfield.text?.count != 0{
                for dealers in tempSubCatItemsObj{
                    let range = dealers.item!.lowercased().range(of: textfield.text!, options: .caseInsensitive, range: nil, locale: nil)
                    if range != nil{
                        subCatItems.append(dealers)
                    }
                }
            }else{
                for dealers in tempSubCatItemsObj{
                    subCatItems.append(dealers)
                }
            }
        }else{
            self.divisionNameObj.removeAll()
            if textfield.text?.count != 0{
                for dealers in tempDivNames{
                    let range = dealers.divisionnm!.lowercased().range(of: textfield.text!, options: .caseInsensitive, range: nil, locale: nil)
                    if range != nil{
                        divisionNameObj.append(dealers)
                    }
                }
            }else{
                for dealers in tempDivNames{
                    divisionNameObj.append(dealers)
                }
            }
        }
        tableView.reloadData()
    }
    
    //Button...
    @IBAction func cancelPopup(_ sender: Any) {
        if multipleSelector{
            let tempString = divSelected.joined(separator: ",")
            delegate?.showParty!(value: tempString,cin : tempString)
        }
        dismiss(animated: true)
    }
    
    //TableView Functions...
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if fromPage == "Limits"{
            return limitDetailsObj.count
        }else if fromPage == "Catchild"{
            return categorywiseCompObj.count
        }else if fromPage == "Vendors"{
            return supplierArray.count
        }else if fromPage == "SubCat"{
            return subCatObj.count
        }else if fromPage == "Items"{
            return subCatItems.count
        }else{
            return divisionNameObj.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchCell", for: indexPath)
        if fromPage == "Limits"{
            cell.textLabel?.text = limitDetailsObj[indexPath.row].displaynm
        }else if fromPage == "Catchild"{
            cell.textLabel?.text = categorywiseCompObj[indexPath.row].categorynm
        }else if fromPage == "Vendors"{
            cell.textLabel?.text = supplierArray[indexPath.row].vendornm
        }else if fromPage == "SubCat"{
            cell.textLabel?.text = subCatObj[indexPath.row].subcatnm
        }else if fromPage == "Items"{
            cell.textLabel?.text = subCatItems[indexPath.row].item
        }else{
            cell.textLabel?.text = divSelected.contains(String(divisionNameObj[indexPath.row].slno!)) ? " ✅ \(divisionNameObj[indexPath.row].divisionnm ?? "N/A")" : divisionNameObj[indexPath.row].divisionnm
        }
//        cell.textLabel?.text = fromPage == "Limits" ? limitDetailsObj[indexPath.row].displaynm : divisionNameObj[indexPath.row].divisionnm
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if fromPage == "Limits"{
            delegate?.showParty!(value: limitDetailsObj[indexPath.row].displaynm!,cin : limitDetailsObj[indexPath.row].cin!)
        }else if fromPage == "Catchild"{
            delegate?.showParty!(value: categorywiseCompObj[indexPath.row].categorynm!,cin : String(categorywiseCompObj[indexPath.row].slno!))
        }else if fromPage == "Vendors"{
            delegate?.showParty!(value: supplierArray[indexPath.row].vendornm!,cin : String(supplierArray[indexPath.row].slno!))
        }else if fromPage == "SubCat"{
            delegate?.showParty!(value: subCatObj[indexPath.row].subcatnm!,cin : String(subCatObj[indexPath.row].subcatid!))
        }else if fromPage == "Items"{
            delegate?.showParty!(value: subCatItems[indexPath.row].item!,cin : String(subCatItems[indexPath.row].slno!))
        } else{
            if multipleSelector{
                if divSelected.count > 0 && divSelected.contains(String(divisionNameObj[indexPath.row].slno!)){
                    divSelected.remove(at: divSelected.index(of: String(divisionNameObj[indexPath.row].slno!))!)
                }else{
                  divSelected.append(String(divisionNameObj[indexPath.row].slno!))
                }
                tableView.reloadData()
                return
            }else{
              delegate?.showParty!(value: divisionNameObj[indexPath.row].divisionnm!,cin : String(divisionNameObj[indexPath.row].slno!))
            }
            
        }
        dismiss(animated: true)
    }
    
//    func apiLimitDetails(){
//
//        let json: [String: Any] = ["CIN":UserDefaults.standard.value(forKey: "userCIN") as! String,"Category":UserDefaults.standard.value(forKey: "userCategory") as! String,"ClientSecret":"ClientSecret"]
//        print("NDA DETAILS : \(json)")
//        let manager =  DataManager.shared
//
//        manager.makeAPICall(url: limitDetailsApiUrl, params: json, method: .POST, success: { (response) in
//            let data = response as? Data
//
//            do {
//                self.limitDetails = try JSONDecoder().decode([LimitDetails].self, from: data!)
//                self.limitDetailsObj = self.limitDetails[0].data
//                self.tempDealersArr = self.limitDetails[0].data
//                self.textField.addTarget(self, action: #selector(self.searchRecords(_ :)), for: .editingChanged)
//                self.tableView.reloadData()
//                ViewControllerUtils.sharedInstance.removeLoader()
//            } catch let errorData {
//                print(errorData.localizedDescription)
//                ViewControllerUtils.sharedInstance.removeLoader()
//            }
//        }) { (Error) in
//            print(Error?.localizedDescription as Any)
//            ViewControllerUtils.sharedInstance.removeLoader()
//        }
//
//    }
    
    func apiDivisionNames(){
        
        let json: [String: Any] = ["CIN":UserDefaults.standard.value(forKey: "userCIN") as! String,"Category":UserDefaults.standard.value(forKey: "userCategory") as! String,"ClientSecret":"ClientSecret"]
        print("NDA DETAILS : \(json)")
        let manager =  DataManager.shared
        
        manager.makeAPICall(url: divisionNameApiUrl, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            
            do {
                self.divisionName = try JSONDecoder().decode([DivisionName].self, from: data!)
                self.divisionNameObj = self.divisionName[0].data
                self.tempDivNames = self.divisionName[0].data
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
    
//    func apiCompare(){
//        let json: [String: Any] = ["CurFromDate":dateFrom,"CurToDate":dateTo,"ClientSecret":"ClientSecret","CIN":UserDefaults.standard.value(forKey: "userCIN") as! String,"Category":UserDefaults.standard.value(forKey: "userCategory") as! String,"LastFromDate":prevDateFrom,"LastToDate":prevDateTo,"divisionid":self.divCode]
//        let manager =  DataManager.shared
//        print("Params Sent : \(json)")
//        manager.makeAPICall(url: categoryApiUrl, params: json, method: .POST, success: { (response) in
//            let data = response as? Data
//
//            do {
//                //self.dashDivObj.removeAll()
//                self.categorywiseComp = try JSONDecoder().decode([Categorywise].self, from: data!)
//                self.categorywiseCompObj  = self.categorywiseComp[0].data
//                self.tempCategory = self.categorywiseComp[0].data
//                self.textField.addTarget(self, action: #selector(self.searchRecords(_ :)), for: .editingChanged)
//                self.tableView.reloadData()
//                ViewControllerUtils.sharedInstance.removeLoader()
//            } catch let errorData {
//                print(errorData.localizedDescription)
//                ViewControllerUtils.sharedInstance.removeLoader()
//            }
//        }) { (Error) in
//            print(Error?.localizedDescription as Any)
//            ViewControllerUtils.sharedInstance.removeLoader()
//        }
//    }
    
    
}


