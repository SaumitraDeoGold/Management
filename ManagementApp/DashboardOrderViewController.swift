//
//  DashboardOrderViewController.swift
//  ManagementApp
//
//  Created by Goldmedal on 18/04/19.
//  Copyright © 2019 Goldmedal. All rights reserved.
//

import UIKit

class DashboardOrderViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, PopupDateDelegate {
    
    //Outlets...
    @IBOutlet weak var CollectionView: UICollectionView!
    @IBOutlet weak var CollectionViewTwo: UICollectionView!
    @IBOutlet weak var noDataView: NoDataView!
    @IBOutlet weak var sort: UIImageView!
    
    //Declarations...
    var cellContentIdentifier = "\(CollectionViewCell.self)"
    var pendingApiUrl = ""
    var pendingOrder = [PendingOrder]()
    var pendingOrderObj = [PendingOrderObj]()
    var filteredItems = [PendingOrderObj]()
    var totalSales = 0.0
    var totalTransfer = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pendingApiUrl = "https://api.goldmedalindia.in/api/GetPendingBranchWise"
        self.noDataView.hideView(view: self.noDataView)
        ViewControllerUtils.sharedInstance.showLoader()
        apiGetPendingOrders()
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        sort.isUserInteractionEnabled = true
        sort.addGestureRecognizer(tapGestureRecognizer)
        
    }
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        let sb = UIStoryboard(name: "Sorting", bundle: nil)
        let popup = sb.instantiateInitialViewController()! as! SortViewController
        popup.modalPresentationStyle = .overFullScreen
        popup.delegate = self
        popup.showPicker = 1
        popup.pickerDataSource = ["A-Z","Z-A","low to high Sales PO","high to low Sales PO","low to high Transfer PO","high to low Transfer PO"]
        self.present(popup, animated: true)
    }
    
    func sortBy(value: String, position: Int) {
        switch position {
        case 0:
            self.filteredItems = self.pendingOrderObj.sorted{($0.branchnm)!.localizedCaseInsensitiveCompare($1.branchnm!) == .orderedAscending}
        case 1:
            self.filteredItems = self.pendingOrderObj.sorted{($0.branchnm)!.localizedCaseInsensitiveCompare($1.branchnm!) == .orderedDescending}
        case 2:
            self.filteredItems = self.pendingOrderObj.sorted(by: {Double($0.salependingamt!)! < Double($1.salependingamt!)!})
        case 3:
            self.filteredItems = self.pendingOrderObj.sorted(by: {Double($0.salependingamt!)! > Double($1.salependingamt!)!})
        case 4:
            self.filteredItems = self.pendingOrderObj.sorted(by: {Double($0.transferpendingamt!)! < Double($1.transferpendingamt!)!})
        case 5:
            self.filteredItems = self.pendingOrderObj.sorted(by: {Double($0.transferpendingamt!)! > Double($1.transferpendingamt!)!})
        default:
            break
        }
        self.CollectionView.reloadData()
        self.CollectionView.collectionViewLayout.invalidateLayout()
    }
    
    //Collection View......
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if collectionView == self.CollectionView{
            return self.filteredItems.count + 2
        }else{
            return 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
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
                cell.contentLabel.text = "Branch Name"
            case 1:
                cell.contentLabel.text = "Sales PO"
            case 2:
                cell.contentLabel.text = "Transfer PO"
            default:
                break
            }
            //cell.backgroundColor = UIColor.lightGray
        }else if indexPath.section == self.filteredItems.count + 1 {
            cell.contentLabel.font = UIFont(name: "Roboto-Medium", size: 16)
            if #available(iOS 11.0, *) {
                cell.backgroundColor = UIColor.init(named: "Primary")
            } else {
                cell.backgroundColor = UIColor.gray
            }
            switch indexPath.row{
            case 0:
                cell.contentLabel.text = "SUM"
            case 1:
                cell.contentLabel.text = Utility.formatRupee(amount: Double(totalSales ))
            case 2:
                cell.contentLabel.text = Utility.formatRupee(amount: Double(totalTransfer ))
                
            default:
                break
            }
            //cell.backgroundColor = UIColor.lightGray
        } else {
            cell.contentLabel.font = UIFont(name: "Roboto-Regular", size: 14)
            if #available(iOS 11.0, *) {
                cell.backgroundColor = UIColor.init(named: "primaryLight")
            } else {
                cell.backgroundColor = UIColor.lightGray
            }
            switch indexPath.row{
            case 0:
                cell.contentLabel.text = filteredItems[indexPath.section - 1].branchnm
            case 1:
                if let salependingamt = filteredItems[indexPath.section - 1].salependingamt
                {
                    cell.contentLabel.text = Utility.formatRupee(amount: Double(salependingamt )!)
                }
            case 2:
                if let transferpendingamt = filteredItems[indexPath.section - 1].transferpendingamt
                {
                    cell.contentLabel.text = Utility.formatRupee(amount: Double(transferpendingamt )!)
                }
            default:
                break
            }
            //cell.backgroundColor = UIColor.groupTableViewBackground
        }
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == self.CollectionView {
            if(indexPath.row == 0){
                let sb = UIStoryboard(name: "Search", bundle: nil)
                let popup = sb.instantiateInitialViewController()! as! SearchViewController
                popup.modalPresentationStyle = .overFullScreen
                popup.delegate = self
                popup.from = "branch"
                self.present(popup, animated: true)
//                let sb = UIStoryboard(name: "BranchPicker", bundle: nil)
//                let popup = sb.instantiateInitialViewController()! as! BranchPickerController
//                popup.modalPresentationStyle = .overFullScreen
//                popup.delegate = self
//                popup.showPicker = 1
//                self.present(popup, animated: true)
            }
        }
    }
    
    func showSearchValue(value: String) {
        if value == "ALL" {
            filteredItems = self.pendingOrderObj
            self.CollectionView.reloadData()
            self.CollectionView.collectionViewLayout.invalidateLayout()
            return
        }
        filteredItems = self.pendingOrderObj.filter { $0.branchnm == value }
        self.CollectionView.reloadData()
        self.CollectionView.collectionViewLayout.invalidateLayout()
    }
    
//    func updateBranch(value: String, position: Int) {
//        if position == 0 {
//            filteredItems = self.pendingOrderObj
//            self.CollectionView.reloadData()
//            self.CollectionView.collectionViewLayout.invalidateLayout()
//            return
//        }
//        filteredItems = self.pendingOrderObj.filter { $0.branchnm == value }
//        self.CollectionView.reloadData()
//        self.CollectionView.collectionViewLayout.invalidateLayout()
//    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? BranchwiseOrderController,
            let index = CollectionView.indexPathsForSelectedItems?.first{
            destination.dataToRecieve = [pendingOrderObj[index.section-1]]
            destination.type = index.row == 2 ? "transfer" : "trade"
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if let index = CollectionView.indexPathsForSelectedItems?.first{
            if((index.section) > 0){
                if index.section == self.filteredItems.count + 1{
                    return false
                }else{
                    return true
                }
            }else{
                return false
            }
        }else{
            return false
        }
        
        
    }
    
    //API CALLS...
    func apiGetPendingOrders(){
        
        let json: [String: Any] = ["CIN":UserDefaults.standard.value(forKey: "userCIN") as! String,"Category":UserDefaults.standard.value(forKey: "userCategory") as! String,"ClientSecret":"ohdashfl"]
        
        let manager =  DataManager.shared
        
        manager.makeAPICall(url: pendingApiUrl, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            
            do {
                self.pendingOrder = try JSONDecoder().decode([PendingOrder].self, from: data!)
                self.pendingOrderObj  = self.pendingOrder[0].data
                self.filteredItems = self.pendingOrder[0].data
                self.totalSales = self.filteredItems.reduce(0, { $0 + Double($1.salependingamt!)! })
                self.totalTransfer = self.filteredItems.reduce(0, { $0 + Double($1.transferpendingamt!)! })
//                for index in 0...(self.filteredItems.count-1) {
//                    self.totalSales =  self.totalSales + Int(self.filteredItems[index].salependingamt!)!
//                    self.totalTransfer =  self.totalTransfer + Int(self.filteredItems[index].transferpendingamt!)!
//                }
                self.CollectionView.reloadData()
                self.CollectionView.collectionViewLayout.invalidateLayout()
                ViewControllerUtils.sharedInstance.removeLoader()
                self.noDataView.hideView(view: self.noDataView)
            } catch let errorData {
                print(errorData.localizedDescription)
                self.noDataView.showView(view: self.noDataView, from: "NDA")
                ViewControllerUtils.sharedInstance.removeLoader()
            }
        }) { (Error) in
            print(Error?.localizedDescription as Any)
            self.noDataView.showView(view: self.noDataView, from: "NDA")
            ViewControllerUtils.sharedInstance.removeLoader()
        }
        
    }
    
}
