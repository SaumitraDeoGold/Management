//
//  SpinTotalPopupController.swift
//  DealorsApp
//
//  Created by Goldmedal on 10/17/18.
//  Copyright © 2018 Goldmedal. All rights reserved.
//

import UIKit

class SpinTotalPopupController: UIViewController, UITableViewDelegate , UITableViewDataSource {
        
        @IBOutlet weak var viewHeight: NSLayoutConstraint!
        
        var spinTotalMain = [SpinTotalElement]()
        var spinTotalArr = [SpinTotalObj]()
        
        @IBOutlet weak var tableView: UITableView!
        @IBOutlet weak var imvClose: UIImageView!
        @IBOutlet weak var vwClose: UIView!
        
        var strCin = ""
        var spinTotalApi=""
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            let loginData =  UserDefaults.standard.value(forKey: "loginData") as? Dictionary ?? [:]
            strCin = loginData["userlogid"] as? String ?? ""
            
            let initialData =  UserDefaults.standard.value(forKey: "initialData") as? Dictionary ?? [:]
            spinTotalApi = (initialData["baseApi"] as? String ?? "")+""+(initialData["wheelSpinsDetails"] as? String ?? "")
            
            // Do any additional setup after loading the view.
            if (Utility.isConnectedToNetwork()) {
                print("Internet connection available")
                OperationQueue.main.addOperation {
                    self.apiSpinTotal()
                }
            }
            else{
                print("No internet connection available")
                
                var alert = UIAlertView(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", delegate: nil, cancelButtonTitle: "OK")
                alert.show()
            }
            
            self.tableView.delegate = self;
            self.tableView.dataSource = self;
            
            let tabClose = UITapGestureRecognizer(target: self, action: #selector(self.tapFunction))
            vwClose.addGestureRecognizer(tabClose)
        }
        
        @objc func tapFunction(sender:UITapGestureRecognizer) {
            print("tap working")
            dismiss(animated: true)
        }
        
        
        func apiSpinTotal(){
            ViewControllerUtils.sharedInstance.showLoader()
            
            let json: [String: Any] = ["CIN":strCin,"ClientSecret":"1170004"]
            
            DataManager.shared.makeAPICall(url: spinTotalApi, params: json, method: .POST, success: { (response) in
                let data = response as? Data
                DispatchQueue.main.async {
                    do {
                        self.spinTotalMain = try JSONDecoder().decode([SpinTotalElement].self, from: data!)
                        self.spinTotalArr = self.spinTotalMain[0].data
                        
                    } catch let errorData {
                        print(errorData.localizedDescription)
                    }
                    
                    if(self.tableView != nil)
                    {
                        self.tableView.reloadData()
                        self.viewHeight.constant = CGFloat((self.spinTotalArr.count*40)+80)
                    }
                    
                    
                    if(self.spinTotalArr.count == 0){
                        var alert = UIAlertView(title: "No Data available", message: "No Data available", delegate: nil, cancelButtonTitle: "OK")
                        alert.show()
                        
                        self.dismiss(animated: true)
                    }
                    
                }
                ViewControllerUtils.sharedInstance.removeLoader()
            }) { (Error) in
                ViewControllerUtils.sharedInstance.removeLoader()
                print(Error?.localizedDescription)
            }
            
        }
        
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "SpinTotalCell", for: indexPath) as! SpinTotalCell
            
            cell.lblDate.text = spinTotalArr[indexPath.row].date ?? "-"
            cell.lblAmount.text = String(spinTotalArr[indexPath.row].amount!)
            cell.lblSpinNumber.text=String(indexPath.row+1)
         
            return cell
        }
        
        
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return spinTotalArr.count
        }
        
        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return 40
        }
        
}

