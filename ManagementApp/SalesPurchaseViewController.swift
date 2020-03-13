//
//  SalesPurchaseViewController.swift
//  ManagementApp
//
//  Created by Goldmedal on 11/04/19.
//  Copyright © 2019 Goldmedal. All rights reserved.
//

import UIKit

class SalesPurchaseViewController: BaseViewController, UICollectionViewDataSource, UICollectionViewDelegate, UITableViewDelegate , UITableViewDataSource {
    
    //Outlets...
    @IBOutlet weak var CollectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    
    //Declarations
    var showSales = true
    var cellContentIdentifier = "\(CollectionViewCell.self)"
    var salesPurchase = [SalesPurchase]()
    var salesPurchaseObj = [SalesPurchaseObj]()
    var filteredItems = [SalesPurchaseObj]()
    var apiSalesnPurchase = ""
    var totalSales = ["withTax":0.0,"withoutTax":0.0,"payment":0.0,"creditNote":0.0,"debitNote":0.0,"outAmount":0.0,"stockAmount":0.0,"purchaseAmount":0.0]
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var isagent = false
    
    override func viewDidLoad() {
        addSlideMenuButton()
        if UserDefaults.standard.value(forKey: "userCategory") as! String == "Agent"{
            isagent = true
            CollectionView.isHidden = true
        }else{
            tableView.isHidden = true
        }
        super.viewDidLoad()
        apiSalesnPurchase = "https://api.goldmedalindia.in/api/GetBranchwiseAllTransaction"
        apiGetSalesPurchase()
        ViewControllerUtils.sharedInstance.showLoader()
    }
    
    //Sort Related...
    @IBAction func clicked_sort(_ sender: Any) {
        let sb = UIStoryboard(name: "Sorting", bundle: nil)
        let popup = sb.instantiateInitialViewController()! as! SortViewController
        popup.modalPresentationStyle = .overFullScreen
        popup.delegate = self
        popup.showPicker = 1
        popup.pickerDataSource = ["A-Z","Z-A","low to high Payment","high to low Payment"]
        self.present(popup, animated: true)
    }
    
    func sortBy(value: String, position: Int) {
        switch position {
        case 0:
            self.filteredItems = self.salesPurchaseObj.sorted{($0.branchnm)!.localizedCaseInsensitiveCompare($1.branchnm!) == .orderedAscending}
        case 1:
            self.filteredItems = self.salesPurchaseObj.sorted{($0.branchnm)!.localizedCaseInsensitiveCompare($1.branchnm!) == .orderedDescending}
        case 2:
            self.filteredItems = self.salesPurchaseObj.sorted(by: {Double($0.payment!)! < Double($1.payment!)!})
        case 3:
            self.filteredItems = self.salesPurchaseObj.sorted(by: {Double($0.payment!)! > Double($1.payment!)!})
        default:
            break
        }
        
        self.CollectionView.reloadData()
        self.CollectionView.collectionViewLayout.invalidateLayout()
    }
    
    //Tableview Functions...
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 370
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredItems.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SalePurchaseCell", for: indexPath) as! SalePurchaseCell
        //_ = self.ndaDetailArray[indexPath.row].name!.characters.split{$0 == "-"}.map(String.init)
        cell.lblBranchName.text = self.filteredItems[indexPath.row].branchnm
        if let amount = self.filteredItems[indexPath.row].salewithtaxamt {
            cell.lblWDName.text = Utility.formatRupee(amount: Double(amount)!)
        }
        if let lights = self.filteredItems[indexPath.row].salewithouttaxamt {
            cell.lblLname.text = Utility.formatRupee(amount: Double(lights)!)
        }
        if let wc = self.filteredItems[indexPath.row].payment {
            cell.lblWCName.text = Utility.formatRupee(amount: Double(wc)!)
        }
        if let pf = self.filteredItems[indexPath.row].creditnote {
            cell.lblPFName.text = Utility.formatRupee(amount: Double(pf)!)
        }
        if let md = self.filteredItems[indexPath.row].debitnote {
            cell.lblMDName.text = Utility.formatRupee(amount: Double(md)!)
        }
        if let brC = self.filteredItems[indexPath.row].outstandingamt {
            cell.lblBRCName.text = Utility.formatRupee(amount: Double(brC)!)
        }
        if let contri = self.filteredItems[indexPath.row].stockamt {
            cell.lblContriName.text = Utility.formatRupee(amount: Double(contri)!)
        }
        if let contri = self.filteredItems[indexPath.row].purchaseamt {
            cell.lblPAName.text = Utility.formatRupee(amount: Double(contri)!)
        }
        //        if let amount = self.branchData[indexPath.row].wiringdevices {
        //            cell.lblWD.text = Utility.formatRupee(amount: Double(amount)!)
        //        }
        
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        return cell
    }
    
    //CollectionView Functions...
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if collectionView == self.CollectionView {
            return self.filteredItems.count+2
        }else{
            return 1
        } 
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 9
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = CollectionView.dequeueReusableCell(withReuseIdentifier: cellContentIdentifier,
                                                      for: indexPath) as! CollectionViewCell
        cell.layer.borderWidth = 1
        cell.layer.borderColor = UIColor.white.cgColor
        //Header of CollectionView...
        if indexPath.section == 0 {
            cell.contentLabel.font = UIFont(name: "Roboto-Medium", size: 16)
            if #available(iOS 11.0, *) {
                cell.backgroundColor = UIColor.init(named: "Primary")
            } else {
                cell.backgroundColor = UIColor.gray
            }
            switch indexPath.row{
            case 0:
                cell.contentLabel.text = "Branch Name"
            case 1:
                cell.contentLabel.text = "Sales with Tax"
            case 2:
                cell.contentLabel.text = "Sales w/o Tax"
            case 3:
                cell.contentLabel.text = "Payment"
            case 4:
                cell.contentLabel.text = "Credit Note"
            case 5:
                cell.contentLabel.text = "Debit Note"
            case 6:
                cell.contentLabel.text = "Outsts Amount"
            case 7:
                cell.contentLabel.text = "Stock Amount"
            case 8:
                cell.contentLabel.text = "Purchase Amt"
            default:
                break
            }
            
        }
            //Footer[Total] of CollectionView...
        else if indexPath.section == self.filteredItems.count+1 {
            cell.contentLabel.font = UIFont(name: "Roboto-Medium", size: 16)
            if #available(iOS 11.0, *) {
                cell.backgroundColor = UIColor.init(named: "Primary")
            } else {
                cell.backgroundColor = UIColor.gray
            }
            cell.contentLabel.lineBreakMode = .byWordWrapping
            cell.contentLabel.numberOfLines = 0
            
            switch indexPath.row{
            case 0:
                cell.contentLabel.text = "SUM"
            case 1:
                cell.contentLabel.text = Utility.formatRupee(amount: Double(totalSales["withTax"]! ))
            case 2:
                cell.contentLabel.text = Utility.formatRupee(amount: Double(totalSales["withoutTax"]! ))
            case 3:
                cell.contentLabel.text = Utility.formatRupee(amount: Double(totalSales["payment"]! ))
            case 4:
                cell.contentLabel.text = Utility.formatRupee(amount: Double(totalSales["creditNote"]! ))
            case 5:
                cell.contentLabel.text = Utility.formatRupee(amount: Double(totalSales["debitNote"]! ))
            case 6:
                cell.contentLabel.text = Utility.formatRupee(amount: Double(totalSales["outAmount"]! ))
            case 7:
                cell.contentLabel.text = Utility.formatRupee(amount: Double(totalSales["stockAmount"]! ))
            case 8:
                cell.contentLabel.text = Utility.formatRupee(amount: Double(totalSales["purchaseAmount"]! ))
            default:
                break
            }
            
        }
            //Values of CollectionView...
        else {
            cell.contentLabel.font = UIFont(name: "Roboto-Regular", size: 14)
            if #available(iOS 11.0, *) {
                cell.backgroundColor = UIColor.init(named: "primaryLight")
            } else {
                cell.backgroundColor = UIColor.lightGray
            }
            
            switch indexPath.row{
            case 0:
                cell.contentLabel.text = filteredItems[indexPath.section-1].branchnm
            case 1:
                if let salewithtaxamt = filteredItems[indexPath.section-1].salewithtaxamt
                {
                    cell.contentLabel.text = Utility.formatRupee(amount: Double(salewithtaxamt )!)
                }
            case 2:
                if let salewithouttaxamt = filteredItems[indexPath.section-1].salewithouttaxamt
                {
                    cell.contentLabel.text = Utility.formatRupee(amount: Double(salewithouttaxamt )!)
                }
            case 3:
                if let payment = filteredItems[indexPath.section-1].payment
                {
                    cell.contentLabel.text = Utility.formatRupee(amount: Double(payment )!)
                }
            case 4:
                if let creditnote = filteredItems[indexPath.section-1].creditnote
                {
                    cell.contentLabel.text = Utility.formatRupee(amount: Double(creditnote )!)
                }
            case 5:
                if let debitnote = filteredItems[indexPath.section-1].debitnote
                {
                    cell.contentLabel.text = Utility.formatRupee(amount: Double(debitnote )!)
                }
            case 6:
                if let outstandingamt = filteredItems[indexPath.section-1].outstandingamt
                {
                    cell.contentLabel.text = Utility.formatRupee(amount: Double(outstandingamt )!)
                }
            case 7:
                if let stockamt = filteredItems[indexPath.section-1].stockamt
                {
                    cell.contentLabel.text = Utility.formatRupee(amount: Double(stockamt )!)
                }
            case 8:
                if let purchaseamt = filteredItems[indexPath.section-1].purchaseamt
                {
                    cell.contentLabel.text = Utility.formatRupee(amount: Double(purchaseamt )!)
                }
            default:
                break
            }
            
        }
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == self.CollectionView{
            if(indexPath.row == 0){
                //Open all branches popup
                let sb = UIStoryboard(name: "BranchPicker", bundle: nil)
                let popup = sb.instantiateInitialViewController()! as! BranchPickerController
                popup.modalPresentationStyle = .overFullScreen
                popup.delegate = self
                popup.showPicker = 1
                self.present(popup, animated: true)
            }            
        }
    }
    
    //Picker Function...
    func updateBranch(value: String, position: Int) {
        if position == 0 {
            //Show all branches...
            filteredItems = self.salesPurchaseObj
            self.CollectionView.reloadData()
            self.CollectionView.collectionViewLayout.invalidateLayout()
            return
        }
        //Show selected branch only...
        filteredItems = self.salesPurchaseObj.filter { $0.branchnm == value }
        self.CollectionView.reloadData()
        self.CollectionView.collectionViewLayout.invalidateLayout()
    }
    
    //API Function...
    func apiGetSalesPurchase(){
        
        let json: [String: Any] = ["CIN":UserDefaults.standard.value(forKey: "userCIN") as! String,"Category":UserDefaults.standard.value(forKey: "userCategory") as! String,"ClientSecret":"ohdashfl"]
        
        let manager =  DataManager.shared
        print("SalesP Params \(json)")
        manager.makeAPICall(url: apiSalesnPurchase, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            
            do {
                self.salesPurchase = try JSONDecoder().decode([SalesPurchase].self, from: data!)
                self.salesPurchaseObj  = self.salesPurchase[0].data
                self.filteredItems  = self.salesPurchase[0].data
                //Store Sum of all items...
                self.totalSales["withTax"] = self.filteredItems.reduce(0, { $0 + Double($1.salewithtaxamt!)! })
                self.totalSales["withoutTax"] = self.filteredItems.reduce(0, { $0 + Double($1.salewithouttaxamt!)! })
                self.totalSales["payment"] = self.filteredItems.reduce(0, { $0 + Double($1.payment!)! })
                self.totalSales["creditNote"] = self.filteredItems.reduce(0, { $0 + Double($1.creditnote!)! })
                self.totalSales["debitNote"] = self.filteredItems.reduce(0, { $0 + Double($1.debitnote!)! })
                self.totalSales["outAmount"] = self.filteredItems.reduce(0, { $0 + Double($1.outstandingamt!)! })
                self.totalSales["stockAmount"] = self.filteredItems.reduce(0, { $0 + Double($1.stockamt!)! })
                self.totalSales["purchaseAmount"] = self.filteredItems.reduce(0, { $0 + Double($1.purchaseamt!)! })
                if self.isagent{
                    self.tableView.reloadData()
                }else{
                    self.CollectionView.reloadData()
                    self.CollectionView.collectionViewLayout.invalidateLayout()
                } 
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
