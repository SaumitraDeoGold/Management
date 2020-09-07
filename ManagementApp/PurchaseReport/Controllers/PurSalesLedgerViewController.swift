//
//  PurSalesLedgerViewController.swift
//  ManagementApp
//
//  Created by Goldmedal on 19/05/20.
//  Copyright © 2020 Goldmedal. All rights reserved.
//

import UIKit

class PurSalesLedgerViewController: BaseViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    
    //Outlets...
    @IBOutlet weak var CollectionView: UICollectionView!
    
    //Declarations...
    var apiLedger = ""
    var purSalesLedger = [PurSalesLedger]()
    var purSalesLedgerObj = [PurSalesLedgerObj]()
    var filteredItems = [PurSalesLedgerObj]()
    var cellContentIdentifier = "\(CollectionViewCell.self)"
    var totalSal = 0.0
    var totalPur = 0.0
    var totalDif = 0.0
    var statename = [[String : String]]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        apiLedger = "https://test2.goldmedalindia.in/api/Getpurandsalepartyledger"
        ViewControllerUtils.sharedInstance.showLoader()
        addSlideMenuButton()
        apiPurchaseSales()
    }
    
    //CollectionView Functions...
    func numberOfSections(in collectionView: UICollectionView) -> Int {
      return filteredItems.count + 2
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = CollectionView.dequeueReusableCell(withReuseIdentifier: cellContentIdentifier,
                                                      for: indexPath) as! CollectionViewCell
        cell.layer.borderWidth = 1
        cell.layer.borderColor = UIColor.white.cgColor
            if indexPath.section == 0{
                cell.contentLabel.font = UIFont(name: "Roboto-Medium", size: 16)
                if #available(iOS 11.0, *) {
                    cell.backgroundColor = UIColor.init(named: "Primary")
                } else {
                    cell.backgroundColor = UIColor.gray
                }
                 
                switch indexPath.row{
                case 0:
                    cell.contentLabel.text = "Party Name"
                case 1:
                    cell.contentLabel.text = "Difference"
                case 2:
                    cell.contentLabel.text = "Purchase"
                case 3:
                    cell.contentLabel.text = "Sales"
                default:
                    break
                }
                //cell.backgroundColor = UIColor.lightGray
            }else if indexPath.section == filteredItems.count + 1{
                cell.contentLabel.font = UIFont(name: "Roboto-Medium", size: 16)
                if #available(iOS 11.0, *) {
                    cell.backgroundColor = UIColor.init(named: "Primary")
                } else {
                    cell.backgroundColor = UIColor.gray
                }
                switch indexPath.row{
                case 0:
                    cell.contentLabel.text = "SUM"
                case 2:
                    cell.contentLabel.text = Utility.formatRupee(amount: Double(totalPur))
                    cell.contentLabel.textColor = UIColor.black
                case 3:
                    cell.contentLabel.text = Utility.formatRupee(amount: Double(totalSal))
                    cell.contentLabel.textColor = UIColor.black
                case 1:
                    cell.contentLabel.text = Utility.formatRupee(amount: Double(totalDif))
                    cell.contentLabel.textColor = UIColor.black
                default:
                    break
                }
            } else {
                cell.contentLabel.font = UIFont(name: "Roboto-Regular", size: 14)
                if #available(iOS 11.0, *) {
                    cell.backgroundColor = UIColor.init(named: "primaryLight")
                } else {
                    cell.backgroundColor = UIColor.lightGray
                }
                switch indexPath.row{
                case 0:
                    cell.contentLabel.text = filteredItems[indexPath.section - 1].purchasePartyName
                case 2:
                    if let purchaseLedger = filteredItems[indexPath.section - 1].purchaseLedgerAmt
                    {
                        cell.contentLabel.text = Utility.formatRupee(amount: Double(purchaseLedger )!)
                    }
                case 3:
                    if let salesLedger = filteredItems[indexPath.section - 1].saleLedgerAmt
                    {
                        cell.contentLabel.text = Utility.formatRupee(amount: Double(salesLedger )!)
                    }
                case 1:
                    if let diffrence = filteredItems[indexPath.section - 1].diffrence
                    {
                        cell.contentLabel.text = Utility.formatRupee(amount: Double(diffrence )!)
                    }
                default:
                    break
                }
                //cell.backgroundColor = UIColor.groupTableViewBackground
            }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 0 && indexPath.row == 0 {
           let sb = UIStoryboard(name: "Search", bundle: nil)
            let popup = sb.instantiateInitialViewController()! as! SearchViewController
            popup.modalPresentationStyle = .overFullScreen
            popup.delegate = self
            popup.alltype = statename
            popup.from = "all"
            self.present(popup, animated: true)
        }else if indexPath.section != 0 && indexPath.section != filteredItems.count + 1{
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.sendCin = filteredItems[indexPath.section-1].purchasePartyId!
            appDelegate.partyName = filteredItems[indexPath.section-1].purchasePartyName!
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let destViewController : UIViewController = storyboard.instantiateViewController(withIdentifier: "NewDashBoard")
            let topViewController : UIViewController = self.navigationController!.topViewController!
            self.navigationController!.pushViewController(destViewController, animated: true)
        }
    }
    
    func showSearchValue(value: String) {
        if value == "ALL" {
            filteredItems = self.purSalesLedgerObj
            self.CollectionView.reloadData()
            self.CollectionView.collectionViewLayout.invalidateLayout()
            return
        }
        filteredItems = self.purSalesLedgerObj.filter { $0.purchasePartyName == value }
        self.CollectionView.reloadData()
        self.CollectionView.collectionViewLayout.invalidateLayout()
        
    }
    
    //API CALLS..............
    func apiPurchaseSales(){
        
        let json: [String: Any] = ["ClientSecret":"jgsfhfdk","CIN":UserDefaults.standard.value(forKey: "userCIN") as! String,"Category":UserDefaults.standard.value(forKey: "userCategory") as! String]
        
        let manager =  DataManager.shared
        print("apiPurchaseSales params \(json)")
        manager.makeAPICall(url: apiLedger, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            
            do {
                self.purSalesLedger = try JSONDecoder().decode([PurSalesLedger].self, from: data!)
                print("Accounts Ledgerwise result \(self.purSalesLedger[0].data)")
                self.purSalesLedgerObj = self.purSalesLedger[0].data
                self.filteredItems = self.purSalesLedger[0].data
                for index in 0...(self.filteredItems.count-1) {
                    self.statename.append(["name":self.filteredItems[index].purchasePartyName!])
                }
                self.totalSal = self.filteredItems.reduce(0, { $0 + Double($1.saleLedgerAmt!)! })
                self.totalPur = self.filteredItems.reduce(0, { $0 + Double($1.purchaseLedgerAmt!)! })
                self.totalDif = self.filteredItems.reduce(0, { $0 + Double($1.diffrence!)! })
                self.CollectionView.reloadData()
                self.CollectionView.collectionViewLayout.invalidateLayout()
                //self.CollectionView.setContentOffset(CGPoint.zero, animated: true)
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
