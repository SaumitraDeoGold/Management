//
//  SearchSupplierController.swift
//  ManagementApp
//
//  Created by Goldmedal on 25/01/20.
//  Copyright © 2020 Goldmedal. All rights reserved.
//

import UIKit

class SearchSupplierController: BaseViewController, UITableViewDataSource, UITableViewDelegate {

    //Outlets...
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textField: UITextField!
    
    //Declarations...
    var searchData = [SearchSupplier]()
    var supplierArray = [SearchSupplierObj]()
    var tempSupplierArr = [SearchSupplierObj]()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addSlideMenuButton()
        ViewControllerUtils.sharedInstance.showLoader()
        apiGetAllSuppliers()
    }
    
    //Auto-Complete Function...
    @objc func searchRecords(_ textfield: UITextField){
        self.supplierArray.removeAll()
        if textfield.text?.count != 0{
            for dealers in tempSupplierArr{
                let range = dealers.suppliernm!.lowercased().range(of: textfield.text!, options: .caseInsensitive, range: nil, locale: nil)
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
        cell.textLabel?.text = supplierArray[indexPath.row].suppliernm
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        appDelegate.sendCin = supplierArray[indexPath.item].slno!
        //        weak var pvc = self.presentingViewController
        //        self.dismiss(animated: false, completion: {
        //            let OldDashboard =  self.storyboard?.instantiateViewController(withIdentifier: "OldDashboard") as! OldDashboardController
        //            let navVc = UINavigationController(rootViewController: OldDashboard)
        //            pvc?.present(navVc, animated: true, completion: nil)
        //        })
        //self.navigationController?.popViewController(animated: true)
    }
    
    //API Function...
    func apiGetAllSuppliers(){
        let json: [String: Any] = ["CIN":UserDefaults.standard.value(forKey: "userCIN") as! String,"Category":UserDefaults.standard.value(forKey: "userCategory") as! String,"ClientSecret":"ClientSecret"]
        let manager =  DataManager.shared
        print("supplierArray Params \(json)")
        manager.makeAPICall(url: "https://api.goldmedalindia.in/api/getManagementSupplier", params: json, method: .POST, success: { (response) in
            let data = response as? Data
            
            do {
                self.searchData = try JSONDecoder().decode([SearchSupplier].self, from: data!)
                self.supplierArray  = self.searchData[0].data!
                print("supplierArray Result \(self.searchData[0].data)")
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
