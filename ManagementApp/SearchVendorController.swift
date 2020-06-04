//
//  SearchVendorController.swift
//  ManagementApp
//
//  Created by Goldmedal on 25/01/20.
//  Copyright © 2020 Goldmedal. All rights reserved.
//

import UIKit

class SearchVendorController: BaseViewController, UITableViewDataSource, UITableViewDelegate {

    //Outlets...
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textField: UITextField!
    
    //Declarations...
    var searchData = [SearchVendor]()
    var supplierArray = [SearchVendorObj]()
    var tempSupplierArr = [SearchVendorObj]()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addSlideMenuButton()
        ViewControllerUtils.sharedInstance.showLoader()
        apiGetAllVendors()
    }
    
    //Auto-Complete Function...
    @objc func searchRecords(_ textfield: UITextField){
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
        tableView.reloadData()
    }
    
    //TableView Functions...
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return supplierArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchCell", for: indexPath)
        cell.textLabel?.text = supplierArray[indexPath.row].vendornm
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        appDelegate.sendCin = supplierArray[indexPath.item].slno!
        appDelegate.partyName = supplierArray[indexPath.item].vendornm!
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let destViewController : UIViewController = storyboard.instantiateViewController(withIdentifier: "NewDashBoard")
        let topViewController : UIViewController = self.navigationController!.topViewController!
        self.navigationController!.pushViewController(destViewController, animated: true)
    }
 
    
    //API Function...
    func apiGetAllVendors(){
        let json: [String: Any] = ["CIN":UserDefaults.standard.value(forKey: "userCIN") as! String,"Category":UserDefaults.standard.value(forKey: "userCategory") as! String,"ClientSecret":"ClientSecret"]
        let manager =  DataManager.shared
        print("vendorArray Params \(json)")
        manager.makeAPICall(url: "https://api.goldmedalindia.in/api/getManagementVendor", params: json, method: .POST, success: { (response) in
            let data = response as? Data
            
            do {
                self.searchData = try JSONDecoder().decode([SearchVendor].self, from: data!)
                self.supplierArray  = self.searchData[0].data!
                print("vendorArray Result \(self.searchData[0].data!)")
                for dealers in self.supplierArray{
                    self.tempSupplierArr.append(dealers)
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
