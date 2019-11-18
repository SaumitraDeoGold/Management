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
    
    //Declarations...
    var delegate: PopupDateDelegate?
    var limitDetailsApiUrl = ""
    var limitDetails = [LimitDetails]()
    var limitDetailsObj = [LimitDetailsObj]()
    var tempDealersArr = [LimitDetailsObj]()
    var divisionNameApiUrl = ""
    var divisionName = [DivisionName]()
    var divisionNameObj = [DivisionNameObj]()
    var tempDivNames = [DivisionNameObj]()
    var fromPage = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        blurBackground()
        limitDetailsApiUrl = "https://test2.goldmedalindia.in/api/GetDealerListManagment"
        divisionNameApiUrl = "https://test2.goldmedalindia.in/api/GetDivisionListManagement"
        ViewControllerUtils.sharedInstance.showLoader()
        if fromPage == "Limits"{
            apiLimitDetails()
        }else{
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
        dismiss(animated: true)
    }
    
    //TableView Functions...
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if fromPage == "Limits"{
            return limitDetailsObj.count
        }else{
            return divisionNameObj.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchCell", for: indexPath)
        cell.textLabel?.text = fromPage == "Limits" ? limitDetailsObj[indexPath.row].displaynm : divisionNameObj[indexPath.row].divisionnm
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if fromPage == "Limits"{
            delegate?.showParty!(value: limitDetailsObj[indexPath.row].displaynm!,cin : limitDetailsObj[indexPath.row].cin!)
        }
        else{
            delegate?.showParty!(value: divisionNameObj[indexPath.row].divisionnm!,cin : (divisionNameObj[indexPath.row].divisioncode!))
        }
        dismiss(animated: true)
    }
    
    func apiLimitDetails(){
        
        let json: [String: Any] = ["CIN":UserDefaults.standard.value(forKey: "userCIN") as! String,"Category":UserDefaults.standard.value(forKey: "userCategory") as! String,"ClientSecret":"ClientSecret"]
        print("NDA DETAILS : \(json)")
        let manager =  DataManager.shared
        
        manager.makeAPICall(url: limitDetailsApiUrl, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            
            do {
                self.limitDetails = try JSONDecoder().decode([LimitDetails].self, from: data!)
                self.limitDetailsObj = self.limitDetails[0].data
                self.tempDealersArr = self.limitDetails[0].data
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
    
    
}
