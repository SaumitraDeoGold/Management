//
//  AddComboViewController.swift
//  DealorsApp
//
//  Created by Goldmedal on 10/29/18.
//  Copyright © 2018 Goldmedal. All rights reserved.
//

import UIKit

protocol AddComboDelegate {
    func addComboPopup(strComboQty:String,cell:ComboSchemeViewCell)
}

class AddComboViewController: UIViewController , UITableViewDelegate , UITableViewDataSource{
    
    @IBOutlet weak var viewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var imvClose: UIImageView!
    @IBOutlet weak var vwClose: UIView!
    @IBOutlet weak var btnAdd: UIButton!
    @IBOutlet weak var lblTotalAmount: UILabel!
    @IBOutlet weak var lblCount: UILabel!
    @IBOutlet weak var lblBenefits: UILabel!
    @IBOutlet weak var btnSub: UIButton!
    @IBOutlet weak var lblComboName: UILabel!
    var ComboNameSplit = [String]()
    
    var comboCell = ComboSchemeViewCell()
    
    var ComboDetailElement = [ComboDetailsAddElement]()
    var ComboArr = [ComboDetailArr]()
    
    var strCin = String()
    var strComboName = String()
    var strComboId = String()
    
    var totalQty = 0
    
    var strComboDetailApi = ""
    
     var delegate: AddComboDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let initialData =  UserDefaults.standard.value(forKey: "initialData") as? Dictionary ?? [:]
        strComboDetailApi = (initialData["baseApi"] as? String ?? "")+""+(initialData["comboDetails"] as? String ?? "")
        
        // Do any additional setup after loading the view.
        if (Utility.isConnectedToNetwork()) {
            print("Internet connection available")
            OperationQueue.main.addOperation {
                self.apiComboDetails()
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
    
    
    func apiComboDetails(){
        ViewControllerUtils.sharedInstance.showLoader()
        
        let json: [String: Any] = ["ClientSecret":"1170004","CIN":strCin,"ComboId":strComboId]
        
        DataManager.shared.makeAPICall(url: strComboDetailApi, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            DispatchQueue.main.async {
                do {
                    self.ComboDetailElement = try JSONDecoder().decode([ComboDetailsAddElement].self, from: data!)
                    self.ComboArr = self.ComboDetailElement[0].data
                    
                } catch let errorData {
                    print(errorData.localizedDescription)
                }
                
                if(self.tableView != nil)
                {
                    self.tableView.reloadData()
                    self.viewHeight.constant = CGFloat((self.ComboArr.count*60)+290)
                }
                
            }
            ViewControllerUtils.sharedInstance.removeLoader()
        }) { (Error) in
            ViewControllerUtils.sharedInstance.removeLoader()
            print(Error?.localizedDescription)
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ComboDetailCell", for: indexPath) as! ComboDetailCell
        
        cell.lblDlp.text = ComboArr[indexPath.row].dlp ?? "-"
        cell.lblQty.text = ComboArr[indexPath.row].qty ?? "-"
        
        if(!(self.ComboArr[indexPath.row].itemname ?? "").isEmpty){
            self.ComboNameSplit = (self.ComboArr[indexPath.row].itemname?.components(separatedBy: " - "))!
        }else{
            self.ComboNameSplit = ["-","-"]
        }
        
        cell.lblName.text = ComboNameSplit[1]
        cell.lblComboNumber.text = ComboNameSplit[0]
        cell.lblAmount.text = ComboArr[indexPath.row].amount ?? "-"
        
        return cell
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return ComboArr.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    @IBAction func clicked_cancel(_ sender: UIButton) {
         dismiss(animated: true)
    }
    
    @IBAction func clicked_submit(_ sender: UIButton) {
        delegate?.addComboPopup(strComboQty:String(totalQty),cell:comboCell)
        dismiss(animated: true)
    }
    
    @IBAction func clicked_add(_ sender: UIButton) {
        totalQty+=1
        if(totalQty<10){
            lblCount.text = "0"+String(totalQty)
        }else{
            lblCount.text = String(totalQty)
        }
    }
    
    @IBAction func clicked_sub(_ sender: UIButton) {
        if(totalQty>0){
            totalQty-=1
            if(totalQty<10){
                lblCount.text = "0"+String(totalQty)
            }else{
                lblCount.text = String(totalQty)
            }
            
        }
    }
    
}
