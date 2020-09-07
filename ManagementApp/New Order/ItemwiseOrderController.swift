//
//  ItemwiseOrderController.swift
//  ManagementApp
//
//  Created by Goldmedal on 22/07/20.
//  Copyright © 2020 Goldmedal. All rights reserved.
//

import UIKit

class ItemwiseOrderController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, PopupDateDelegate {
    
    //Outlets...
    @IBOutlet weak var CollectionView: UICollectionView! 
    @IBOutlet weak var sort: UIImageView!
    @IBOutlet weak var lblHeader: UILabel!
    
    //Declarations...
    var cellContentIdentifier = "\(CollectionViewCell.self)"
    var branchwiseApiUrl = ""
    var branchwiseOrder = [MainOrderItemwise]()
    var branchwiseOrdersObj = [MainOrderItemwiseObj]()
    var filterOrdersObj = [MainOrderItemwiseObj]()
    var dataToRecieve = [PendingOrderObj]()
    var poType = ""
    var branchId = ""
    var catId = ""
    var branchName = ""
    var category = ""
    var temp = 0.0
    var tempQuantity = 0.0

    override func viewDidLoad() {
        super.viewDidLoad()
        branchwiseApiUrl = "https://test2.goldmedalindia.in/api/getitemwisependingamount"
        apiGetBranchwiseOrders()
        ViewControllerUtils.sharedInstance.showLoader()
        if poType == "0"{
            self.title = "Transfer Pending Itemwise"
        }else{
            self.title = "Sales Pending Itemwise"
        }
        lblHeader.text = "\(branchName) -> \(category)"
        //Sort
        let tapSortRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapSortRecognizer:)))
        sort.isUserInteractionEnabled = true
        sort.addGestureRecognizer(tapSortRecognizer)
    }
     
    
    @objc func imageTapped(tapSortRecognizer: UITapGestureRecognizer)
    {
        let sb = UIStoryboard(name: "Sorting", bundle: nil)
        let popup = sb.instantiateInitialViewController()! as! SortViewController
        popup.modalPresentationStyle = .overFullScreen
        popup.delegate = self
        popup.showPicker = 1
        popup.pickerDataSource = ["A-Z","Z-A","low to high Amount","high to low Amount","low to high Quantity","high to low Quantity","low to high Pending Days","high to low Pending Days"]
        self.present(popup, animated: true)
    }
    
    func sortBy(value: String, position: Int) {
            switch position {
            case 0:
                self.filterOrdersObj = self.branchwiseOrdersObj.sorted{($0.itemName)!.localizedCaseInsensitiveCompare($1.itemName!) == .orderedAscending}
            case 1:
                self.filterOrdersObj = self.branchwiseOrdersObj.sorted{($0.itemName)!.localizedCaseInsensitiveCompare($1.itemName!) == .orderedDescending}
            case 2:
                self.filterOrdersObj = self.branchwiseOrdersObj.sorted(by: {Double($0.amount!)! < Double($1.amount!)!})
            case 3:
                self.filterOrdersObj = self.branchwiseOrdersObj.sorted(by: {Double($0.amount!)! > Double($1.amount!)!})
            case 4:
                self.filterOrdersObj = self.branchwiseOrdersObj.sorted(by: {Double($0.qty!)! < Double($1.qty!)!})
            case 5:
                self.filterOrdersObj = self.branchwiseOrdersObj.sorted(by: {Double($0.qty!)! > Double($1.qty!)!})
            case 6:
                self.filterOrdersObj = self.branchwiseOrdersObj.sorted(by: {Double($0.pendingsince!)! < Double($1.pendingsince!)!})
            case 7:
                self.filterOrdersObj = self.branchwiseOrdersObj.sorted(by: {Double($0.pendingsince!)! > Double($1.pendingsince!)!})
            default:
                break
            }
        
        self.CollectionView.reloadData()
        self.CollectionView.collectionViewLayout.invalidateLayout()
    }
    
    //Collection View......
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.filterOrdersObj.count + 2
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = CollectionView.dequeueReusableCell(withReuseIdentifier: cellContentIdentifier,
                                                      for: indexPath) as! CollectionViewCell
        cell.layer.borderWidth = 1
        cell.layer.borderColor = UIColor.white.cgColor
        if indexPath.section == 0 {
            cell.contentLabel.font = UIFont(name: "Roboto-Medium", size: 16)
            if #available(iOS 11.0, *) {
                cell.backgroundColor = UIColor.init(named: "Primary")
            } else {
                cell.backgroundColor = UIColor.gray
            }
            switch indexPath.row{
            case 0:
                cell.contentLabel.text = "Item Name/Color"
            case 1:
                cell.contentLabel.text = "Range Name"
            case 2:
                cell.contentLabel.text = "Pending Days"
            case 3:
                cell.contentLabel.text = "Amount"
            case 4:
                cell.contentLabel.text = "Quantity"
//            case 5:
//                cell.contentLabel.text = "Branch"
                
            default:
                break
            }
            //cell.backgroundColor = UIColor.lightGray
        }else if indexPath.section == filterOrdersObj.count + 1{
            cell.contentLabel.font = UIFont(name: "Roboto-Regular", size: 14)
            if #available(iOS 11.0, *) {
                cell.backgroundColor = UIColor.init(named: "Primary")
            } else {
                cell.backgroundColor = UIColor.gray
            }
            switch indexPath.row{
            case 0:
                cell.contentLabel.text = "Item Name"
            case 1:
                cell.contentLabel.text = "Range Name"
            case 2:
                cell.contentLabel.text = "Pending Days"
            case 3:
                cell.contentLabel.text = Utility.formatRupee(amount: Double(temp))
            case 4:
                cell.contentLabel.text = String(tempQuantity)
//            case 5:
//                cell.contentLabel.text = "Branch"
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
                cell.contentLabel.text = "\(filterOrdersObj[indexPath.section - 1].itemName!) / \(filterOrdersObj[indexPath.section - 1].color!)"
            case 1:
                cell.contentLabel.text = filterOrdersObj[indexPath.section - 1].subCat
            case 2:
                cell.contentLabel.text = filterOrdersObj[indexPath.section - 1].pendingsince
            case 3:
                if let amount = filterOrdersObj[indexPath.section - 1].amount
                {
                    cell.contentLabel.text = Utility.formatRupee(amount: Double(amount )!)
                }
            case 4:
                cell.contentLabel.text = filterOrdersObj[indexPath.section - 1].qty
//            case 5:
//                cell.contentLabel.text = filterOrdersObj[indexPath.section - 1].branch
            default:
                break
            }
            //cell.backgroundColor = UIColor.groupTableViewBackground
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if(indexPath.section == 0){
            let sb = UIStoryboard(name: "Search", bundle: nil)
            let popup = sb.instantiateInitialViewController()! as! SearchViewController
            popup.modalPresentationStyle = .overFullScreen
            popup.delegate = self
            popup.tempOrdersObj = filterOrdersObj
            popup.filterOrdersObj = filterOrdersObj
            popup.from = "orderitem"
            self.present(popup, animated: true)
        }
        else if indexPath.section != 0 && indexPath.section != filterOrdersObj.count + 1{
            let storyboard = UIStoryboard(name: "MainDashboard", bundle: nil)
            let destViewController = storyboard.instantiateViewController(withIdentifier: "ItemwisePO") as! ItemwisePOOrderController
            destViewController.itemId = filterOrdersObj[indexPath.section-1].itemId!
            destViewController.itemName = "\(filterOrdersObj[indexPath.section - 1].itemName!) / \(filterOrdersObj[indexPath.section - 1].color!)"
            destViewController.branchId = branchId
            //destViewController.matId = filterOrdersObj[indexPath.section-1].materialissuefrom!
            destViewController.poType = poType
            self.navigationController!.pushViewController(destViewController, animated: true)
        }
    }
    
    //Show Items Func...
    func showSearchValue(value: String) {
        if value == "ALL" {
            filterOrdersObj = self.branchwiseOrdersObj
            self.CollectionView.reloadData()
            self.CollectionView.collectionViewLayout.invalidateLayout()
            return
        }
        filterOrdersObj = self.branchwiseOrdersObj.filter { $0.itemName == value }
        self.CollectionView.reloadData()
        self.CollectionView.collectionViewLayout.invalidateLayout()
    }
    
    //API CALLS...
    func apiGetBranchwiseOrders(){
        
        let json: [String: Any] = ["CIN":UserDefaults.standard.value(forKey: "userCIN") as! String,"Category":UserDefaults.standard.value(forKey: "userCategory") as! String,"ClientSecret":"ClientSecret", "BranchId":branchId,"potype":poType,"Catid":catId]
        
        let manager =  DataManager.shared
        print("Item wise Main Order Param \(json)")
        manager.makeAPICall(url: branchwiseApiUrl, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            
            do {
                self.branchwiseOrder = try JSONDecoder().decode([MainOrderItemwise].self, from: data!)
                self.branchwiseOrdersObj  = self.branchwiseOrder[0].data
                self.filterOrdersObj  = self.branchwiseOrder[0].data
                self.temp = self.branchwiseOrdersObj.reduce(0, { $0 + Double($1.amount!)! })
                //self.total.text = Utility.formatRupee(amount: Double(temp ))
                self.tempQuantity = self.branchwiseOrdersObj.reduce(0, { $0 + Double($1.qty!)! })
                //self.totalQuantity.text = Utility.formatRupee(amount: Double(tempQuantity ))
                self.CollectionView.reloadData()
                self.CollectionView.collectionViewLayout.invalidateLayout()
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
