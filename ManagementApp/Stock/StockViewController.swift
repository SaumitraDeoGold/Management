//
//  StockViewController.swift
//  ManagementApp
//
//  Created by Goldmedal on 12/04/19.
//  Copyright © 2019 Goldmedal. All rights reserved.
//

import UIKit

class StockViewController: BaseViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    //Outlets..
    @IBOutlet weak var CollectionView: UICollectionView!
    @IBOutlet weak var CollectionViewTwo: UICollectionView!
    @IBOutlet weak var header: UILabel!
    @IBOutlet weak var noDataView: NoDataView!
    @IBOutlet weak var sort: UIImageView!
    
    //Declarations...
    var showSales = true
    var cellContentIdentifier = "\(CollectionViewCell.self)"
    var stockData = [Stock]()
    var stockObj = [StockObj]()
    var filteredItems = [StockObj]()
    var stockApiUrl = ""
    var totalStock = ["above30":0.0,"above60":0.0,"above90":0.0,"above120":0.0,"above150":0.0,"above180":0.0,"above200":0.0,"actualStock":0.0]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.noDataView.hideView(view: self.noDataView)
        ViewControllerUtils.sharedInstance.showLoader()
        stockApiUrl = "https://api.goldmedalindia.in/api/GetBranchNonMovementStockValuation"
        apiGetStock()
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
        popup.pickerDataSource = ["A-Z","Z-A","low to high Stock Value","high to low Stock Value"]
        self.present(popup, animated: true)
    }
    
    func sortBy(value: String, position: Int) {
        switch position {
        case 0:
            self.filteredItems = self.stockObj.sorted{($0.branchnm)!.localizedCaseInsensitiveCompare($1.branchnm!) == .orderedAscending}
        case 1:
            self.filteredItems = self.stockObj.sorted{($0.branchnm)!.localizedCaseInsensitiveCompare($1.branchnm!) == .orderedDescending}
        case 2:
            self.filteredItems = self.stockObj.sorted(by: {Double($0.stockamt!)! < Double($1.stockamt!)!})
        case 3:
            self.filteredItems = self.stockObj.sorted(by: {Double($0.stockamt!)! > Double($1.stockamt!)!})
        default:
            break
        }
        
        self.CollectionView.reloadData()
        self.CollectionView.collectionViewLayout.invalidateLayout()
    }
    
    //CollectionView Functions...
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if collectionView == self.CollectionView {
            return self.filteredItems.count + 2
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
        //CollectionView Header...
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
                cell.contentLabel.text = "Stock Value"
            case 2:
                cell.contentLabel.text = "Above 30"
            case 3:
                cell.contentLabel.text = "Above 60"
            case 4:
                cell.contentLabel.text = "Above 90"
            case 5:
                cell.contentLabel.text = "Above 120"
            case 6:
                cell.contentLabel.text = "Above 150"
            case 7:
                cell.contentLabel.text = "Above 180"
            case 8:
                cell.contentLabel.text = "Above 200"
            default:
                break
            }
            
        }//CollectionView Footer...
        else if indexPath.section == filteredItems.count + 1{
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
                cell.contentLabel.text = Utility.formatRupee(amount: (totalStock["actualStock"]! ))
            case 2:
                cell.contentLabel.text = Utility.formatRupee(amount: (totalStock["above30"]! ))
            case 3:
                cell.contentLabel.text = Utility.formatRupee(amount: (totalStock["above60"]! ))
            case 4:
                cell.contentLabel.text = Utility.formatRupee(amount: (totalStock["above90"]! ))
            case 5:
                cell.contentLabel.text = Utility.formatRupee(amount: (totalStock["above120"]! ))
            case 6:
                cell.contentLabel.text = Utility.formatRupee(amount: (totalStock["above150"]! ))
            case 7:
                cell.contentLabel.text = Utility.formatRupee(amount: (totalStock["above180"]! ))
            case 8:
                cell.contentLabel.text = Utility.formatRupee(amount: (totalStock["above200"]! ))
            default:
                break
            }
        }//CollectionView items...
        else {
            cell.contentLabel.font = UIFont(name: "Roboto-Regular", size: 14)
            if #available(iOS 11.0, *) {
                cell.backgroundColor = UIColor.init(named: "primaryLight")
            } else {
                cell.backgroundColor = UIColor.lightGray
            }
            
            switch indexPath.row{
            case 0:
                cell.contentLabel.text = self.filteredItems[indexPath.section-1].branchnm
            case 1:
                if let stockamt = self.filteredItems[indexPath.section-1].stockamt
                {
                    cell.contentLabel.text = Utility.formatRupee(amount: Double(stockamt )!)
                }
            case 2:
                if let slab30 = self.filteredItems[indexPath.section-1].slab30
                {
                    cell.contentLabel.text = Utility.formatRupee(amount: Double(slab30 )!)
                }
            case 3:
                if let slab60 = self.filteredItems[indexPath.section-1].slab60
                {
                    cell.contentLabel.text = Utility.formatRupee(amount: Double(slab60 )!)
                }
            case 4:
                if let slab90 = self.filteredItems[indexPath.section-1].slab90
                {
                    cell.contentLabel.text = Utility.formatRupee(amount: Double(slab90 )!)
                }
            case 5:
                if let slab120 = self.filteredItems[indexPath.section-1].slab120
                {
                    cell.contentLabel.text = Utility.formatRupee(amount: Double(slab120 )!)
                }
            case 6:
                if let slab150 = self.filteredItems[indexPath.section-1].slab150
                {
                    cell.contentLabel.text = Utility.formatRupee(amount: Double(slab150 )!)
                }
            case 7:
                if let slab180 = self.filteredItems[indexPath.section-1].slab180
                {
                    cell.contentLabel.text = Utility.formatRupee(amount: Double(slab180 )!)
                }
            case 8:
                if let slab200 = self.filteredItems[indexPath.section-1].slab200
                {
                    cell.contentLabel.text = Utility.formatRupee(amount: Double(slab200 )!)
                }
            default:
                break
            }
            
        }
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == self.CollectionView {
            //Open All Branches Popup
            if(indexPath.row == 0 && indexPath.section == 0){
                let sb = UIStoryboard(name: "BranchPicker", bundle: nil)
                let popup = sb.instantiateInitialViewController()! as! BranchPickerController
                popup.modalPresentationStyle = .overFullScreen
                popup.delegate = self
                popup.showPicker = 1
                self.present(popup, animated: true)
            }
        }
        
    }
    
    //PopUp Click Function...
    func updateBranch(value: String, position: Int) {
        if position == 0 {
            filteredItems = self.stockObj
            self.CollectionView.reloadData()
            self.CollectionView.collectionViewLayout.invalidateLayout()
            return
        }
        filteredItems = self.stockObj.filter { $0.branchnm == value }
        self.CollectionView.reloadData()
        self.CollectionView.collectionViewLayout.invalidateLayout()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //If item other than BranchName clicked then open next page...
        if let destination = segue.destination as? StockDetailController,
            let index = CollectionView.indexPathsForSelectedItems?.first{
            if index.section > 1{
                destination.dataToRecieve = [stockObj[index.section-1]]
                destination.type = index.row - 1
            }
            else{
                return
            }
        } 
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        //Block Segue if branchname is clicked...
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
    
    //API Function...
    func apiGetStock(){
        let json: [String: Any] = ["CIN":UserDefaults.standard.value(forKey: "userCIN") as! String,"Category":UserDefaults.standard.value(forKey: "userCategory") as! String,"ClientSecret":"ohdashfl"]
        let manager =  DataManager.shared
        
        manager.makeAPICall(url: stockApiUrl, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            
            do {
                self.stockData = try JSONDecoder().decode([Stock].self, from: data!)
                self.stockObj  = self.stockData[0].data
                self.filteredItems = self.stockData[0].data
                //Total of All Items...
                self.totalStock["above30"] = self.filteredItems.reduce(0, { $0 + Double($1.slab30!)! })
                self.totalStock["above60"] = self.filteredItems.reduce(0, { $0 + Double($1.slab60!)! })
                self.totalStock["above90"] = self.filteredItems.reduce(0, { $0 + Double($1.slab90!)! })
                self.totalStock["above120"] = self.filteredItems.reduce(0, { $0 + Double($1.slab120!)! })
                self.totalStock["above150"] = self.filteredItems.reduce(0, { $0 + Double($1.slab150!)! })
                self.totalStock["above180"] = self.filteredItems.reduce(0, { $0 + Double($1.slab180!)! })
                self.totalStock["above200"] = self.filteredItems.reduce(0, { $0 + Double($1.slab200!)! })
                self.totalStock["actualStock"] = self.filteredItems.reduce(0, { $0 + Double($1.stockamt!)! })
            
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
