//
//  StockDetailController.swift
//  ManagementApp
//
//  Created by Goldmedal on 25/04/19.
//  Copyright © 2019 Goldmedal. All rights reserved.
//

import UIKit

class StockDetailController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    //Outlets...
    @IBOutlet weak var CollectionView: UICollectionView!
    @IBOutlet weak var total: UILabel!
    
    //Declarations...
    var cellContentIdentifier = "\(StockCell.self)"
    var stockApiUrl = ""
    var stockDetail = [StockDetails]()
    var stockObj = [StockDetailsObj]()
    var dataToRecieve = [StockObj]()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        stockApiUrl = "https://api.goldmedalindia.in/api/GetBranchNonMovementStockValuationDetails"
        ViewControllerUtils.sharedInstance.showLoader()
        apiGetStock()
    }

    //CollectionView related...
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.stockObj.count+1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = CollectionView.dequeueReusableCell(withReuseIdentifier: cellContentIdentifier,
                                                      for: indexPath) as! StockCell
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
                cell.contentLabel.text = "Item Name"
            case 1:
                cell.contentLabel.text = "Stock Amount"
            case 2:
                cell.contentLabel.text = "Stock Quantity"
             
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
                cell.contentLabel.text = stockObj[indexPath.section-1].itemnm 
            case 1:
                if let stockamt = stockObj[indexPath.section - 1].stockamt
                {
                    cell.contentLabel.text = Utility.formatRupee(amount: Double(stockamt )!)
                } 
            case 2:
                cell.contentLabel.text = stockObj[indexPath.section-1].stockqty
                
            default:
                break
            }
            
        }
        
        return cell
    }
    
    //API CALLS...
    func apiGetStock(){
        
        let json: [String: Any] = ["CIN":UserDefaults.standard.value(forKey: "userCIN") as! String,"Category":UserDefaults.standard.value(forKey: "userCategory") as! String,"ClientSecret":"ohdashfl","branchid":dataToRecieve[0].branchid as Any,"type":1]
        
        let manager = DataManager.shared
        
        manager.makeAPICall(url: stockApiUrl, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            do {
                self.stockDetail = try JSONDecoder().decode([StockDetails].self, from: data!)
                self.stockObj  = self.stockDetail[0].data
                let temp = self.stockObj.reduce(0, { $0 + Double($1.stockamt!)! })
                self.total.text = Utility.formatRupee(amount: Double(temp ))
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
