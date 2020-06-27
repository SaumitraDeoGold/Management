//
//  SearchDhanProfileController.swift
//  ManagementApp
//
//  Created by Goldmedal on 05/04/20.
//  Copyright © 2020 Goldmedal. All rights reserved.
//

import UIKit

class SearchDhanProfileController: BaseViewController, UITableViewDataSource, UITableViewDelegate {
    
    //Outlets...
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var btnSend: RoundButton!
    
    //Declarations...
    var dhanPro = [SearchDhanProfile]()
    var dhanProObj = [SearchDhanProfileObj]()
    var filteredItems = [SearchDhanProfileObj]()
    var apiSearchProfile = ""
    

    override func viewDidLoad() {
        super.viewDidLoad()
        addSlideMenuButton()
        apiSearchProfile = "https://test2.goldmedalindia.in/api/getcustomerdetailbymob"
        self.tableView.separatorColor = UIColor.clear
    }
    
    //Button CLicked...
    @IBAction func sendClicked(_ sender: Any) {
         apiGetProfile()
    }
    
    //TableView Functions...
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchCell", for: indexPath)
        cell.textLabel?.text = filteredItems[indexPath.row].userName
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "segueProfile", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "segueProfile") {
            if let destination = segue.destination as? DhanProfileViewController{
                destination.dataToRecieve = filteredItems
            }
        }else{
            
        }
    }
    
    //API Function...
    func apiGetProfile(){
        let json: [String: Any] = ["Cin":UserDefaults.standard.value(forKey: "userCIN") as! String,"Cat":UserDefaults.standard.value(forKey: "userCategory") as! String,"ClientSecret":"ClientSecret","Mobile":textField.text ?? " "]
        let manager =  DataManager.shared
        print("vendorArray Params \(json)")
        manager.makeAPICall(url: apiSearchProfile, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            
            do {
                self.dhanPro = try JSONDecoder().decode([SearchDhanProfile].self, from: data!)
                self.dhanProObj  = self.dhanPro[0].data
                self.filteredItems  = self.dhanPro[0].data
                print("empSearchObj Result \(self.dhanPro[0].data)")
                //self.tableView.reloadData()
                ViewControllerUtils.sharedInstance.removeLoader()
                self.performSegue(withIdentifier: "segueProfile", sender: self)
                
            } catch let errorData {
                print("Caught Error ------>\(errorData.localizedDescription)")
                self.filteredItems.removeAll()
                self.tableView.reloadData()
                ViewControllerUtils.sharedInstance.removeLoader()
                let alert = UIAlertController(title: "Alert", message: "No Data Found", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                
            }
        }) { (Error) in
            print("Error -------> \(Error?.localizedDescription as Any)")
            self.filteredItems.removeAll()
            self.tableView.reloadData()
            ViewControllerUtils.sharedInstance.removeLoader()
            let alert = UIAlertController(title: "Alert", message: "No Data Found", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
         
        }
        
    }

}
