//
//  EmploeeSearchController.swift
//  ManagementApp
//
//  Created by Goldmedal on 27/02/20.
//  Copyright © 2020 Goldmedal. All rights reserved.
//

import UIKit

class EmploeeSearchController: BaseViewController, UITableViewDataSource, UITableViewDelegate  {
    
    //Outlets...
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textField: UITextField!
    
    //Declarations...
    var apiSearchEmp = ""
    var empSearch = [EmpSearch]()
    var empSearchObj = [EmpSearchObj]()
    var filteredItems = [EmpSearchObj]()

    override func viewDidLoad() {
        super.viewDidLoad()
        addSlideMenuButton()
        ViewControllerUtils.sharedInstance.showLoader()
        apiSearchEmp = "https://test2.goldmedalindia.in/api/getemployeeallList"
        apiGetAllEmployees()
    }
    
    //Auto-Complete Function...
    @objc func searchRecords(_ textfield: UITextField){
        self.filteredItems.removeAll()
        if textfield.text?.count != 0{
            for dealers in empSearchObj{
                let range = dealers.name!.lowercased().range(of: textfield.text!, options: .caseInsensitive, range: nil, locale: nil)
                if range != nil{
                    filteredItems.append(dealers)
                }
            }
        }else{
            for dealers in empSearchObj{
                filteredItems.append(dealers)
            }
        }
        tableView.reloadData()
    }
    
    //TableView Functions...
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchCell", for: indexPath)
        cell.textLabel?.text = filteredItems[indexPath.row].name
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //appDelegate.sendCin = supplierArray[indexPath.item].slno!
        //        weak var pvc = self.presentingViewController
        //        self.dismiss(animated: false, completion: {
        //            let OldDashboard =  self.storyboard?.instantiateViewController(withIdentifier: "OldDashboard") as! OldDashboardController
        //            let navVc = UINavigationController(rootViewController: OldDashboard)
        //            pvc?.present(navVc, animated: true, completion: nil)
        //        })
        //self.navigationController?.popViewController(animated: true)
    }
    
    //API Function...
    func apiGetAllEmployees(){
        let json: [String: Any] = ["Cin":UserDefaults.standard.value(forKey: "userCIN") as! String,"Cat":UserDefaults.standard.value(forKey: "userCategory") as! String,"ClientSecret":"ClientSecret"]
        let manager =  DataManager.shared
        print("vendorArray Params \(json)")
        manager.makeAPICall(url: apiSearchEmp, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            
            do {
                self.empSearch = try JSONDecoder().decode([EmpSearch].self, from: data!)
                self.empSearchObj  = self.empSearch[0].data
                self.filteredItems  = self.empSearch[0].data
                print("empSearchObj Result \(self.empSearch[0].data)")
                for dealers in self.empSearchObj{
                    self.filteredItems.append(dealers)
                }
                self.textField.addTarget(self, action: #selector(self.searchRecords(_ :)), for: .editingChanged)
                self.tableView.reloadData()
                ViewControllerUtils.sharedInstance.removeLoader()
                
            } catch let errorData {
                print("Caught Error ------>\(errorData.localizedDescription)")
                ViewControllerUtils.sharedInstance.removeLoader()
            }
        }) { (Error) in
            print("Error -------> \(Error?.localizedDescription as Any)")
            ViewControllerUtils.sharedInstance.removeLoader()
        }
        
    }
 
}
