//
//  ComboBookingViewController.swift
//  DealorsApp
//
//  Created by Goldmedal on 11/2/18.
//  Copyright © 2018 Goldmedal. All rights reserved.
//

import UIKit
import FirebaseAnalytics

struct ComboPlaceElement:Codable {
    let result: Bool?
    let message, servertime: String?
}

class ComboBookingViewController: UIViewController, UITableViewDelegate , UITableViewDataSource,CustomCellDelegate {
   
    @IBOutlet weak var imvBack: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noDataView: NoDataView!
    
     @IBOutlet weak var lblTotalQty: UILabel!
     @IBOutlet weak var lblTotalAmount: UILabel!
    
     var ComboSchemeItems = [[ComboSchemeDetail]]()
     var ComboBookingItems = [[ComboSchemeDetail]]()
     var ComboBooking = [ComboSchemeDetail]()
   
    var comboPlaceOrderElement = [ComboPlaceElement]()
    
    var comboQty = 0
    var initComboQty = 0
    var isBookingAllowed = false
    
    var totalQty:Int = 0
    var arrTotalQty = [Int]()
    var totalAmnt:Double = 0
    var arrTotalAmnt = [Double]()
    
    var arrComboId = [String]()
    
    var strCin = ""
    var apiComboPlaceOrder = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.noDataView.hideView(view: self.noDataView)
        
        let initialData =  UserDefaults.standard.value(forKey: "initialData") as? Dictionary ?? [:]
        apiComboPlaceOrder = (initialData["baseApi"] as? String ?? "")+""+(initialData["comboClaim"] as? String ?? "")
        
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        
        if(self.tableView != nil)
        {
            self.tableView.reloadData()
        }
      
        for items in self.ComboSchemeItems{
           self.ComboBooking.removeAll()
            
            for index in 0...(items.count-1) {
                if(Int(items[index].qty!)! > 0){
                    self.ComboBooking.append(items[index])
                    self.arrTotalQty.append(Int(items[index].qty!)!)
                    self.arrTotalAmnt.append(Double(items[index].amount!)! * Double(items[index].qty!)!)
                    self.arrComboId.append(String(describing: items[index].slno ?? 0))
                }
            }
            
            if(self.ComboBooking.count>0){
                self.ComboBookingItems.append(self.ComboBooking)
            }
        }
        
     
        if(self.ComboBookingItems.count>0){
            self.noDataView.hideView(view: self.noDataView)
        }else{
            self.noDataView.showView(view: self.noDataView, from: "NDA")
        }
        
        let tabBack = UITapGestureRecognizer(target: self, action: #selector(ComboBookingViewController.tapFunction))
        imvBack.addGestureRecognizer(tabBack)
        
        Analytics.setScreenName("COMBO BOOKING SCREEN", screenClass: "ComboBookingViewController")
        
        totalQty = self.arrTotalQty.reduce(0, +)
        totalAmnt = self.arrTotalAmnt.reduce(0, +)
        
        lblTotalQty.text = String(totalQty)
        lblTotalAmount.text = String(Utility.formatRupee(amount:totalAmnt))
    }
    
    
    @objc func tapFunction(sender:UITapGestureRecognizer) {
        print("back")
        self.dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.ComboBookingItems[section].count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ComboSchemeViewCell", for: indexPath) as! ComboSchemeViewCell
        
        cell.lblComboName.text = self.ComboBookingItems[indexPath.section][indexPath.row].comboname?.capitalized ?? "-"
        cell.lblQty.text = self.ComboBookingItems[indexPath.section][indexPath.row].qty ?? "0"
        cell.lblAmount.text = String(Utility.formatRupee(amount: Double(self.ComboBookingItems[indexPath.section][indexPath.row].amount ?? "0.0")!))
        cell.lblCalculatedAmount.text = String(Utility.formatRupee(amount: Double(self.ComboBookingItems[indexPath.section][indexPath.row].qty ?? "0.0")! * Double(self.ComboBookingItems[indexPath.section][indexPath.row].amount ?? "0.0")!))
        
        cell.delegate = self
        
        return cell
    }
    
   
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerCell = tableView.dequeueReusableCell(withIdentifier: "ComboSchemeHeaderCell") as! ComboSchemeHeaderCell
        
        headerCell.lblComboGroupName.text = self.ComboBookingItems[section][0].combogrpname?.capitalized
        return headerCell
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.ComboBookingItems.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
    func cellComboDetails(cell: ComboSchemeViewCell) {
        //No use here
    }
    
    func cellAddCombo(cell: ComboSchemeViewCell) {
        let indexPath = self.tableView.indexPath(for: cell)

        comboQty = Int(cell.lblQty.text!)!

        comboQty += 1
        cell.lblQty.text = String(comboQty)
        cell.lblCalculatedAmount.text = String(Utility.formatRupee(amount: Double(self.ComboBookingItems[indexPath!.section][indexPath!.row].amount ?? "0.0")! * Double(cell.lblQty.text!)!))
        
        totalQty+=1
        totalAmnt+=Double(self.ComboBookingItems[indexPath!.section][indexPath!.row].amount ?? "0.0")!
        
        lblTotalQty.text = String(totalQty)
        lblTotalAmount.text = String(Utility.formatRupee(amount:(totalAmnt)))
        
        self.ComboBookingItems[indexPath!.section][indexPath!.row].qty = cell.lblQty.text
        
        self.arrTotalQty.removeAll()
        self.arrTotalAmnt.removeAll()
       
        for combo in self.ComboBookingItems{
            for index in 0...(combo.count-1) {
                self.arrTotalQty.append(Int(combo[index].qty!)!)
                self.arrTotalAmnt.append(Double(combo[index].amount!)! * Double(combo[index].qty!)!)
            }
        }
        
        print("COMBO BOOKING ADD  - - - - ",self.arrTotalQty,"- - --  - -- - - - ",self.arrTotalAmnt)
        
   
    }
    
    func cellSubCombo(cell: ComboSchemeViewCell) {
        let indexPath = self.tableView.indexPath(for: cell)

        comboQty = Int(cell.lblQty.text!)!
        initComboQty = Int(ComboBookingItems[indexPath!.section][indexPath!.row].initQty!)!
        
        if(self.ComboBookingItems[indexPath!.section][indexPath!.row].isAdded)!{
            if(comboQty > 0){
            comboQty -= 1
            
            cell.lblQty.text = String(comboQty)
            cell.lblCalculatedAmount.text = String(Utility.formatRupee(amount: Double(self.ComboBookingItems[indexPath!.section][indexPath!.row].amount ?? "0.0")! * Double(cell.lblQty.text!)!))
                
                totalQty-=1
                totalAmnt-=Double(self.ComboBookingItems[indexPath!.section][indexPath!.row].amount ?? "0.0")!
                
                lblTotalQty.text = String(totalQty)
                lblTotalAmount.text = String(Utility.formatRupee(amount:totalAmnt))
            
        }else{
            var alert = UIAlertView(title: "Cant decrease  more", message: "Make sure your device is connected to the internet.", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
        }
        }else{
            if(initComboQty < comboQty){
                comboQty -= 1
                
                cell.lblQty.text = String(comboQty)
                cell.lblCalculatedAmount.text = String(Utility.formatRupee(amount: Double(self.ComboBookingItems[indexPath!.section][indexPath!.row].amount ?? "0.0")! * Double(cell.lblQty.text!)!))
                
                totalQty-=1
                totalAmnt-=Double(self.ComboBookingItems[indexPath!.section][indexPath!.row].amount ?? "0.0")!
                
                lblTotalQty.text = String(totalQty)
                lblTotalAmount.text = String(Utility.formatRupee(amount:totalAmnt))
                
            }else{
                var alert = UIAlertView(title: "Cant decrease  more", message: "Make sure your device is connected to the internet.", delegate: nil, cancelButtonTitle: "OK")
                alert.show()
            }
        }
      
         self.ComboBookingItems[indexPath!.section][indexPath!.row].qty = cell.lblQty.text
        
        self.arrTotalQty.removeAll()
        self.arrTotalAmnt.removeAll()
        
        for combo in self.ComboBookingItems{
            for index in 0...(combo.count-1) {
                self.arrTotalQty.append(Int(combo[index].qty!)!)
                self.arrTotalAmnt.append(Double(combo[index].amount!)! * Double(combo[index].qty!)!)
            }
        }
        
         print("COMBO BOOKING SUB  - - - - ",self.arrTotalQty,"- - --  - -- - - - ",self.arrTotalAmnt)
    }
    
    @IBAction  func clicked_reviewQuantity(sender: UIButton){
         let vcComboReview = self.storyboard?.instantiateViewController(withIdentifier: "ComboReview") as! ComboReviewViewController
        vcComboReview.strCin = strCin
        vcComboReview.strComboId = (arrComboId.map{String($0)}).joined(separator: ",")
        vcComboReview.strComboQty = (arrTotalQty.map{String($0)}).joined(separator: ",")
        self.present(vcComboReview, animated: true, completion: nil)
    }
    
    @IBAction  func clicked_placeOrder(sender: UIButton){
        
        if (Utility.isConnectedToNetwork()) {
            self.apiPlaceOrder()
        }
        else {
            var alert = UIAlertView(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
        }
    }
    
    func apiPlaceOrder(){
      
            let json: [String: Any] =
                ["ClientSecret":"1170004","CIN":strCin,"ComboId":(arrComboId.map{String($0)}).joined(separator: ","),"ComboQty":(arrTotalQty.map{String($0)}).joined(separator: ","),"ComboAmount":(arrTotalAmnt.map{String($0)}).joined(separator: ",")]
            
            print("PLACE ORDER COMBO ------ ",json)
            
            DataManager.shared.makeAPICall(url: apiComboPlaceOrder, params: json, method: .POST, success: { (response) in
                let data = response as? Data
                
                DispatchQueue.main.async {
                    do {
                        self.comboPlaceOrderElement = try JSONDecoder().decode([ComboPlaceElement].self, from: data!)
                   
                        if (self.comboPlaceOrderElement[0].result ?? false){
                            var alert = UIAlertView(title: "Success!!!", message: "Combo Placed Successfully", delegate: nil, cancelButtonTitle: "OK")
                            alert.show()
                        }else{
                            var alert = UIAlertView(title: "Failed!!!", message: self.comboPlaceOrderElement[0].message, delegate: nil, cancelButtonTitle: "OK")
                            alert.show()
                        }
                         
                    } catch let errorData {
                        print(errorData.localizedDescription)
                    }
                
                }
            }) { (Error) in
                print(Error?.localizedDescription)
            }
        }
   
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   

}
