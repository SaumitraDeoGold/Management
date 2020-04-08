//
//  AccountsViewController.swift
//  ManagementApp
//
//  Created by Goldmedal on 09/05/19.
//  Copyright © 2019 Goldmedal. All rights reserved.
//

import UIKit
import Charts

class AccountsViewController: BaseViewController, UICollectionViewDataSource, UICollectionViewDelegate{
    
    //OUTLETS...
    @IBOutlet weak var CollectionView: UICollectionView!
    @IBOutlet weak var noDataView: NoDataView!
    @IBOutlet weak var sort: UIImageView!
    
    //DECLARATIONS...
    var outstandingAcc = [AccountsOutstanding]()
    var outstandingAccObj = [AccountsOutstandingObj]()
    var outstandingAccApiUrl = ""
    var cellContentIdentifier = "\(CollectionViewCell.self)"
    var filteredItems = [AccountsOutstandingObj]()
    var total = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addSlideMenuButton()
        self.noDataView.hideView(view: self.noDataView)
        outstandingAccApiUrl = "https://api.goldmedalindia.in/api/GetManagementBranchwiseOutstanding"
        ViewControllerUtils.sharedInstance.showLoader()
        apiTotalSaleDivisionWise()
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        sort.isUserInteractionEnabled = true
        sort.addGestureRecognizer(tapGestureRecognizer)
    }
    
    //Sort Related...
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        let sb = UIStoryboard(name: "Sorting", bundle: nil)
        let popup = sb.instantiateInitialViewController()! as! SortViewController
        popup.modalPresentationStyle = .overFullScreen
        popup.delegate = self
        popup.showPicker = 1
        popup.pickerDataSource = ["A-Z","Z-A","low to high OS Amount","high to low OS Amount"]
        self.present(popup, animated: true)
    }
    
    func sortBy(value: String, position: Int) {
        switch position {
        case 0:
            self.filteredItems = self.outstandingAccObj.sorted{($0.branchnm)!.localizedCaseInsensitiveCompare($1.branchnm!) == .orderedAscending}
        case 1:
            self.filteredItems = self.outstandingAccObj.sorted{($0.branchnm)!.localizedCaseInsensitiveCompare($1.branchnm!) == .orderedDescending}
        case 2:
            self.filteredItems = self.outstandingAccObj.sorted(by: {Double($0.outstandingamt!)! < Double($1.outstandingamt!)!})
        case 3:
            self.filteredItems = self.outstandingAccObj.sorted(by: {Double($0.outstandingamt!)! > Double($1.outstandingamt!)!})
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
        return 2
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
                cell.contentLabel.text = "OS Amount"
            case 2:
                cell.contentLabel.text = "OS %"
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
                cell.contentLabel.text = Utility.formatRupee(amount: Double(total ))
            case 2:
                cell.contentLabel.text = "100%"
                
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
                if let salependingamt = filteredItems[indexPath.section - 1].outstandingamt
                {
                    let percentage = ((Double(self.outstandingAccObj[indexPath.section - 1].outstandingamt!)! / total)*100)
                    cell.contentLabel.text = Utility.formatRupee(amount: Double(salependingamt )!) + " (\(String(format: "%.2f", percentage))%)"
                }
            case 2:
                let percentage = ((Double(self.outstandingAccObj[indexPath.section - 1].outstandingamt!)! / total)*100)
                cell.contentLabel.text = "\(String(format: "%.2f", percentage))%"
                
            default:
                break
            }
            //cell.backgroundColor = UIColor.groupTableViewBackground
        }
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == self.CollectionView {
            if(indexPath.row == 0 && indexPath.section == 0){
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
            filteredItems = self.outstandingAccObj
            self.CollectionView.reloadData()
            self.CollectionView.collectionViewLayout.invalidateLayout()
            return
        }
        filteredItems = self.outstandingAccObj.filter { $0.branchnm == value }
        self.CollectionView.reloadData()
        self.CollectionView.collectionViewLayout.invalidateLayout()
    }
    
//    func updateBranch(value: String, position: Int) {
//        if position == 0 {
//            filteredItems = self.outstandingAccObj
//            self.CollectionView.reloadData()
//            self.CollectionView.collectionViewLayout.invalidateLayout()
//            return
//        }
//        filteredItems = self.outstandingAccObj.filter { $0.branchnm == value }
//        self.CollectionView.reloadData()
//        self.CollectionView.collectionViewLayout.invalidateLayout()
//    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? AccountsDetailsController,
            let index = CollectionView.indexPathsForSelectedItems?.first{
            destination.dataToRecieve = [filteredItems[index.section-1]]
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if let index = CollectionView.indexPathsForSelectedItems?.first{
            if((index.section) > 0){
                if index.section == self.filteredItems.count + 1{
                    return false
                }else{
                    return true}
            }else{
                return false
            }
        }else{
            return false
        }
        
        
    }
    
    //API...
    func apiTotalSaleDivisionWise(){
        
        let json: [String: Any] = ["CIN":UserDefaults.standard.value(forKey: "userCIN") as! String,"Category":UserDefaults.standard.value(forKey: "userCategory") as! String,"ClientSecret":"ClientSecret"]
        
        let manager =  DataManager.shared
        
        manager.makeAPICall(url: outstandingAccApiUrl, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            
            do {
                self.outstandingAcc = try JSONDecoder().decode([AccountsOutstanding].self, from: data!)
                self.outstandingAccObj  = self.outstandingAcc[0].data
                self.filteredItems  = self.outstandingAcc[0].data
                self.total = self.filteredItems.reduce(0, { $0 + Double($1.outstandingamt!)! })
                self.CollectionView.reloadData()
                self.CollectionView.collectionViewLayout.invalidateLayout()
                self.noDataView.hideView(view: self.noDataView)
                ViewControllerUtils.sharedInstance.removeLoader()
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
