//
//  BranchwiseOrderController.swift
//  ManagementApp
//
//  Created by Goldmedal on 27/04/19.
//  Copyright © 2019 Goldmedal. All rights reserved.
//

import UIKit

class BranchwiseOrderController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, PopupDateDelegate  {
    
    //Outlets...
    @IBOutlet weak var CollectionView: UICollectionView!
    @IBOutlet weak var total: UILabel!
    @IBOutlet weak var totalQuantity: UILabel!
    @IBOutlet weak var backButton: UIImageView!
    @IBOutlet weak var sort: UIImageView!
    
    //Declarations...
    var cellContentIdentifier = "\(CollectionViewCell.self)"
    var branchwiseApiUrl = ""
    var branchwiseOrder = [BranchwiseOrders]()
    var branchwiseOrdersObj = [BranchwiseOrdersObj]()
    var filterOrdersObj = [BranchwiseOrdersObj]()
    var dataToRecieve = [PendingOrderObj]()
    var type = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        branchwiseApiUrl = "https://api.goldmedalindia.in/api/GetPendingBranchWiseChild"
        apiGetBranchwiseOrders()
        ViewControllerUtils.sharedInstance.showLoader()
        if type == "transfer"{
            self.title = "Transfer Pending"
        }else{
            self.title = "Sales Pending"
        }
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(backClicked(tapGestureRecognizer:)))
        backButton.isUserInteractionEnabled = true
        backButton.addGestureRecognizer(tapGestureRecognizer)
        //Sort
        let tapSortRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapSortRecognizer:)))
        sort.isUserInteractionEnabled = true
        sort.addGestureRecognizer(tapSortRecognizer)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        //navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    @objc func backClicked(tapGestureRecognizer: UITapGestureRecognizer)
    {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func imageTapped(tapSortRecognizer: UITapGestureRecognizer)
    {
        let sb = UIStoryboard(name: "Sorting", bundle: nil)
        let popup = sb.instantiateInitialViewController()! as! SortViewController
        popup.modalPresentationStyle = .overFullScreen
        popup.delegate = self
        popup.showPicker = 1
        popup.pickerDataSource = ["A-Z","Z-A","low to high Amount","high to low Amount"]
        self.present(popup, animated: true)
    }
    
    func sortBy(value: String, position: Int) {
            switch position {
            case 0:
                self.filterOrdersObj = self.branchwiseOrdersObj.sorted{($0.itemnm)!.localizedCaseInsensitiveCompare($1.itemnm!) == .orderedAscending}
            case 1:
                self.filterOrdersObj = self.branchwiseOrdersObj.sorted{($0.itemnm)!.localizedCaseInsensitiveCompare($1.itemnm!) == .orderedDescending}
            case 2:
                self.filterOrdersObj = self.branchwiseOrdersObj.sorted(by: {Double($0.amount!)! < Double($1.amount!)!})
            case 3:
                self.filterOrdersObj = self.branchwiseOrdersObj.sorted(by: {Double($0.amount!)! > Double($1.amount!)!})
            default:
                break
            }
        
        self.CollectionView.reloadData()
        self.CollectionView.collectionViewLayout.invalidateLayout()
    }
    
    //Collection View......
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.filterOrdersObj.count + 1
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
                cell.contentLabel.text = "Item Name"
            case 1:
                cell.contentLabel.text = "Amount"
            case 2:
                cell.contentLabel.text = "Quantity"
                
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
                cell.contentLabel.text = filterOrdersObj[indexPath.section - 1].itemnm
            case 1:
                if let amount = filterOrdersObj[indexPath.section - 1].amount
                {
                    cell.contentLabel.text = Utility.formatRupee(amount: Double(amount )!)
                }
            case 2:
                cell.contentLabel.text = filterOrdersObj[indexPath.section - 1].qty
            default:
                break
            }
            //cell.backgroundColor = UIColor.groupTableViewBackground
        }
        return cell
    }
    
    //API CALLS...
    func apiGetBranchwiseOrders(){
        
        let json: [String: Any] = ["CIN":UserDefaults.standard.value(forKey: "userCIN") as! String,"Category":UserDefaults.standard.value(forKey: "userCategory") as! String,"ClientSecret":"ClientSecret", "branchid":dataToRecieve[0].branchid!,"type":type]
        
        let manager =  DataManager.shared
        
        manager.makeAPICall(url: branchwiseApiUrl, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            
            do {
                self.branchwiseOrder = try JSONDecoder().decode([BranchwiseOrders].self, from: data!)
                self.branchwiseOrdersObj  = self.branchwiseOrder[0].data
                self.filterOrdersObj  = self.branchwiseOrder[0].data
                let temp = self.branchwiseOrdersObj.reduce(0, { $0 + Double($1.amount!)! })
                self.total.text = Utility.formatRupee(amount: Double(temp ))
                let tempQuantity = self.branchwiseOrdersObj.reduce(0, { $0 + Double($1.qty!)! })
                self.totalQuantity.text = Utility.formatRupee(amount: Double(tempQuantity ))
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
