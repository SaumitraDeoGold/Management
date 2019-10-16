//
//  ComboSchemeViewController.swift
//  DealorsApp
//
//  Created by Goldmedal on 10/18/18.
//  Copyright © 2018 Goldmedal. All rights reserved.
//

import UIKit
import FirebaseAnalytics

class ComboSchemeViewController: BaseViewController , UITableViewDelegate , UITableViewDataSource, CustomCellDelegate, AddComboDelegate {
    
    @IBOutlet weak var tableViewCombo: UITableView!
    @IBOutlet weak var btnCategory: UIButton!
    @IBOutlet weak var btnViewInfo: UIButton!
    @IBOutlet weak var btnViewOrder: UIButton!
    @IBOutlet weak var noDataView: NoDataView!
    
    var ComboSchemeElementMain = [ComboSchemeElement]()
    var ComboSchemeObjMain = [ComboSchemeObj]()
    var ComboSchemeArray = [ComboSchemeDetail]()
    var ComboOldSchemeItems = [[ComboSchemeDetail]]()
    var ComboSchemeItems = [[ComboSchemeDetail]]()
    var ComboSchemeSection = [String]()
   
    var strCin = ""
    var isBookingAllowed = false
  
    var ComboSchemeApi=""
    
    var comboQty = 0
    var initComboQty = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addSlideMenuButton()
        
        self.noDataView.hideView(view: self.noDataView)
        
        Analytics.setScreenName("VIEW COMBO SCREEN", screenClass: "ComboSchemeViewController")
        
        let loginData =  UserDefaults.standard.value(forKey: "loginData") as? Dictionary ?? [:]
        strCin = loginData["userlogid"] as? String ?? ""
        
        let initialData =  UserDefaults.standard.value(forKey: "initialData") as? Dictionary ?? [:]
        ComboSchemeApi = (initialData["baseApi"] as? String ?? "")+""+(initialData["comboSchemes"] as? String ?? "")
        
        // Do any additional setup after loading the view.
        if (Utility.isConnectedToNetwork()) {
            print("Internet connection available")
            self.apiComboSchemeList()
            self.noDataView.hideView(view: self.noDataView)
        }
        else{
            print("No internet connection available")
            
            var alert = UIAlertView(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
            self.noDataView.showView(view: self.noDataView, from: "NET")
        }
        
        
        self.tableViewCombo.delegate = self;
        self.tableViewCombo.dataSource = self;
    }
    
    
    func apiComboSchemeList(){
        ViewControllerUtils.sharedInstance.showLoader()
        
        let json: [String: Any] = ["CIN":strCin,"ClientSecret":"ClientSecret"]
        
        DataManager.shared.makeAPICall(url: ComboSchemeApi, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            
            DispatchQueue.main.async {
                do {
                    self.ComboSchemeElementMain = try JSONDecoder().decode([ComboSchemeElement].self, from: data!)
                    self.ComboSchemeObjMain = self.ComboSchemeElementMain[0].data
                    self.ComboSchemeArray = self.ComboSchemeObjMain[0].comboSchemeDetails
                    self.isBookingAllowed = self.ComboSchemeObjMain[0].comboSchemeBooking ?? false
                    
                    for i in 0...(self.ComboSchemeArray.count-1){
                        self.ComboSchemeArray[i].isAdded = false
                        self.ComboSchemeArray[i].initQty = self.ComboSchemeArray[i].qty
                    }
                    
                    let groupedDictionary = Dictionary(grouping: self.ComboSchemeArray, by: { (combo) -> String in
                        return combo.combogrpname!
                    })
                    
                    let keys = groupedDictionary.keys.sorted()
                    
                    self.ComboSchemeSection.append(contentsOf: keys)
                    
                    keys.forEach({ (key) in
                        self.ComboSchemeItems.append(groupedDictionary[key]!)
                    })
                    
                    
                    self.ComboOldSchemeItems.append(contentsOf: self.ComboSchemeItems)
                 
                
                } catch let errorData {
                    print(errorData.localizedDescription)
                }
                
                if(self.ComboSchemeArray.count>0){
                    if(self.tableViewCombo != nil)
                    {
                        self.tableViewCombo.reloadData()
                    }
                    self.noDataView.hideView(view: self.noDataView)
                }else{
                    self.noDataView.showView(view: self.noDataView, from: "NDA")
                }
                
                ViewControllerUtils.sharedInstance.removeLoader()
                
            }
        }) { (Error) in
            ViewControllerUtils.sharedInstance.removeLoader()
            print(Error?.localizedDescription)
            self.noDataView.showView(view: self.noDataView, from: "ERR")
        }
        
    }
   
   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ComboSchemeItems[section].count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
  
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ComboSchemeViewCell", for: indexPath) as! ComboSchemeViewCell
     
        cell.lblComboName.text = ComboSchemeItems[indexPath.section][indexPath.row].comboname?.capitalized ?? "-"
        cell.lblQty.text = ComboSchemeItems[indexPath.section][indexPath.row].qty ?? "0"
        cell.lblAmount.text = String(Utility.formatRupee(amount: Double(ComboSchemeItems[indexPath.section][indexPath.row].amount ?? "0.0")!))
        cell.lblCalculatedAmount.text = String(Utility.formatRupee(amount: Double(ComboSchemeItems[indexPath.section][indexPath.row].qty ?? "0.0")! * Double(ComboSchemeItems[indexPath.section][indexPath.row].amount ?? "0.0")!))
            
        cell.delegate = self
    
        if(Int(ComboSchemeItems[indexPath.section][indexPath.row].qty!) == 0){
            cell.vwComboAdd.isHidden = false
            cell.vwCalculateAdd.isHidden = true
            cell.lblCalculatedAmount.isHidden = true
        }else{
            cell.vwComboAdd.isHidden = true
            cell.vwCalculateAdd.isHidden = false
            cell.lblCalculatedAmount.isHidden = false
        }
        
       
        return cell
    }
    
    func addComboPopup(strComboQty: String,cell:ComboSchemeViewCell) {
        let indexPath = self.tableViewCombo.indexPath(for: cell)
        comboQty = Int(strComboQty)!
        
        cell.lblQty.text = String(comboQty)
        cell.lblCalculatedAmount.text = String(Utility.formatRupee(amount: Double(ComboSchemeItems[indexPath!.section][indexPath!.row].amount ?? "0.0")! * Double(cell.lblQty.text!)!))
        
        if(comboQty == 0){
            cell.vwComboAdd.isHidden = false
            cell.vwCalculateAdd.isHidden = true
            cell.lblCalculatedAmount.isHidden = true
            self.ComboSchemeItems[indexPath!.section][indexPath!.row].isAdded = false
        }else{
            cell.vwComboAdd.isHidden = true
            cell.vwCalculateAdd.isHidden = false
            cell.lblCalculatedAmount.isHidden = false
            self.ComboSchemeItems[indexPath!.section][indexPath!.row].isAdded = true
        }
        
        self.ComboSchemeItems[indexPath!.section][indexPath!.row].qty = cell.lblQty.text
    }
    
    
    func cellComboDetails(cell: ComboSchemeViewCell) {
        let indexPath = self.tableViewCombo.indexPath(for: cell)
        
        let sb = UIStoryboard(name: "AddComboPopup", bundle: nil)
        let popup = sb.instantiateInitialViewController()  as? AddComboViewController
        popup?.strCin = strCin
        popup?.strComboName = ComboSchemeItems[indexPath!.section][indexPath!.row].comboname?.capitalized ?? "-"
        popup?.strComboId = String(ComboSchemeItems[indexPath!.section][indexPath!.row].slno!)
        popup?.comboCell = cell
        popup?.delegate = self
        self.present(popup!, animated: true)
    }
    
    func cellAddCombo(cell: ComboSchemeViewCell) {
        let indexPath = self.tableViewCombo.indexPath(for: cell)

        comboQty = Int(cell.lblQty.text!)!
     
        comboQty += 1
        
        cell.lblQty.text = String(comboQty)
        cell.lblCalculatedAmount.text = String(Utility.formatRupee(amount: Double(ComboSchemeItems[indexPath!.section][indexPath!.row].amount ?? "0.0")! * Double(cell.lblQty.text!)!))
      
        if(comboQty == 0){
            cell.vwComboAdd.isHidden = false
            cell.vwCalculateAdd.isHidden = true
            cell.lblCalculatedAmount.isHidden = true
        }else{
            cell.vwComboAdd.isHidden = true
            cell.vwCalculateAdd.isHidden = false
            cell.lblCalculatedAmount.isHidden = false
        }
        
         self.ComboSchemeItems[indexPath!.section][indexPath!.row].qty = cell.lblQty.text
        
    }
    
    

    
    func cellSubCombo(cell: ComboSchemeViewCell) {
        let indexPath = self.tableViewCombo.indexPath(for: cell)
        
        initComboQty = Int(ComboOldSchemeItems[indexPath!.section][indexPath!.row].qty!)!
        comboQty = Int(cell.lblQty.text!)!
        
        if(initComboQty < comboQty)
        {
            comboQty -= 1
            
             cell.lblQty.text = String(comboQty)
             cell.lblCalculatedAmount.text = String(Utility.formatRupee(amount: Double(ComboSchemeItems[indexPath!.section][indexPath!.row].amount ?? "0.0")! * Double(cell.lblQty.text!)!))
            
            if(comboQty == 0){
                cell.vwComboAdd.isHidden = false
                cell.vwCalculateAdd.isHidden = true
                cell.lblCalculatedAmount.isHidden = true
            }else{
                cell.vwComboAdd.isHidden = true
                cell.vwCalculateAdd.isHidden = false
                cell.lblCalculatedAmount.isHidden = false
            }
            
        }else{
            var alert = UIAlertView(title: "Cant decrease  more", message: "-----", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
        }
        
         self.ComboSchemeItems[indexPath!.section][indexPath!.row].qty = cell.lblQty.text
    }
    
    
   
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerCell = tableView.dequeueReusableCell(withIdentifier: "ComboSchemeHeaderCell") as! ComboSchemeHeaderCell
        
        headerCell.lblComboGroupName.text = ComboSchemeSection[section].capitalized
        headerCell.btnCompare.addTarget(self, action: #selector(ComboSchemeViewController.clicked_compare(sender:)), for: .touchUpInside)
        headerCell.btnCompare.tag = section
   
        return headerCell
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return ComboSchemeSection.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
  
    @IBAction func clicked_category(_ sender: UIButton) {
        let sb = UIStoryboard(name: "ComboCategoryPopup", bundle: nil)
        let popup = sb.instantiateInitialViewController()  as? ComboCategoryViewController
        popup?.ComboCategoryItems = ComboSchemeItems
        self.present(popup!, animated: true)
    }
    
    @IBAction func clicked_viewInfo(_ sender: UIButton) {
        //show pdf here - - - - - -
        guard let url = URL(string: ComboSchemeObjMain[0].comboSchemeURL ?? "") else {
            var alert = UIAlertView(title: "Error", message: "Invalid Pdf", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
            
            return
        }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    @IBAction func clicked_viewOrder(_ sender: UIButton) {
        let vcComboBooking = self.storyboard?.instantiateViewController(withIdentifier: "ComboBooking") as! ComboBookingViewController
        
        vcComboBooking.ComboSchemeItems = ComboSchemeItems
        vcComboBooking.isBookingAllowed = isBookingAllowed
        vcComboBooking.strCin = strCin
       
       self.present(vcComboBooking, animated: true, completion: nil)
    }
    
   @objc func clicked_compare(sender: UIButton){
    let buttonTag = sender.tag
  
    let sb = UIStoryboard(name: "ComboComparePopup", bundle: nil)
    let popup = sb.instantiateInitialViewController()  as? ComboCompareViewController
    popup?.strComboSection =  ComboSchemeSection[buttonTag].capitalized
    popup?.intComboId =  ComboSchemeItems[buttonTag][0].slno ?? 0
    popup?.strCin =  strCin
    self.present(popup!, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
