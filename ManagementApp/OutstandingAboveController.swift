//
//  OutstandingAboveController.swift
//  ManagementApp
//
//  Created by Goldmedal on 28/03/19.
//  Copyright © 2019 Goldmedal. All rights reserved.
//

import UIKit

class OutstandingAboveController: BaseViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
        
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewSum: UICollectionView!
    @IBOutlet weak var lblDays: RoundButton!
    @IBOutlet weak var lblTotal: UILabel!
    @IBOutlet weak var sort: UIImageView!
 
    var outStandingAbove = [OutstandingAbove]()
    var outStandingObj = [OutstandingAboveObj]()
    var filteredItems = [OutstandingAboveObj]()
    var cellContentIdentifier = "\(OutstandingAbvCell.self)"
    var apiGetOutstandingUrl = ""
    let noOfDays = [150,180,210,270]
    var daysSelected = 150
    var totalOs = 0
    var totalOSAbove = 0
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        addSlideMenuButton()
        //addSortButton()
        super.viewDidLoad()
        apiGetOutstandingUrl = "https://api.goldmedalindia.in/api/GetOutstandingbyDays"
        ViewControllerUtils.sharedInstance.showLoader()
        apiGetOutstandingByDays()
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
        popup.pickerDataSource = ["A-Z","Z-A","low to high Outstanding","high to low Outstanding"]
        self.present(popup, animated: true)
    }
    
    func sortBy(value: String, position: Int) {
        switch position {
        case 0:
            self.filteredItems = self.outStandingObj.sorted{($0.partynm)!.localizedCaseInsensitiveCompare($1.partynm!) == .orderedAscending}
        case 1:
            self.filteredItems = self.outStandingObj.sorted{($0.partynm)!.localizedCaseInsensitiveCompare($1.partynm!) == .orderedDescending}
        case 2:
            self.filteredItems = self.outStandingObj.sorted(by: {Double($0.totalbalance!)! < Double($1.totalbalance!)!})
        case 3:
            self.filteredItems = self.outStandingObj.sorted(by: {Double($0.totalbalance!)! > Double($1.totalbalance!)!})
        default:
            break
        }
        
        self.collectionView.reloadData()
        self.collectionView.collectionViewLayout.invalidateLayout()
    }
    
    //Button...
    @IBAction func clickedDays(_ sender: Any) {
        let sb = UIStoryboard(name: "DaysPicker", bundle: nil)
        let popup = sb.instantiateInitialViewController()! as! DaysPickerController
        popup.modalPresentationStyle = .overFullScreen
        popup.delegate = self
        popup.showPicker = 1
        self.present(popup, animated: true)
    }
 
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if collectionView == self.collectionView{
            return self.filteredItems.count+1
        }else{
            return 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.collectionView{
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellContentIdentifier,
                                                                for: indexPath) as! OutstandingAbvCell
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
                cell.contentLabel.text = "Party Name"
            case 1:
                cell.contentLabel.text = "Home Branch"
            case 2:
                cell.contentLabel.text = "Total Outsts"
            case 3:
                cell.contentLabel.text =   "Days"
            case 4:
                cell.contentLabel.text =  "Total Outstanding above \(daysSelected)"
            default:
                break
            }
            
        }else{
            cell.contentLabel.font = UIFont(name: "Roboto-Regular", size: 14)
            if #available(iOS 11.0, *) {
                cell.backgroundColor = UIColor.init(named: "primaryLight")
            } else {
                cell.backgroundColor = UIColor.lightGray
            }
            switch indexPath.row{
            case 0:
                if filteredItems[indexPath.section - 1].partystatus != "Active"{
                    cell.contentLabel.textColor = UIColor(named: "ColorRed")
                }else{
                    cell.contentLabel.textColor = UIColor.black
                }
                cell.contentLabel.text = self.filteredItems[indexPath.section-1].partynm!
            case 1:
                cell.contentLabel.textColor = UIColor.black
                cell.contentLabel.text =  self.filteredItems[indexPath.section-1].locnm
            case 2:
                cell.contentLabel.textColor = UIColor.black
                if let totalOuts = self.filteredItems[indexPath.section-1].totalbalance
                {
                    cell.contentLabel.text = Utility.formatRupee(amount: Double(totalOuts )!)
                }
            case 3:
                cell.contentLabel.textColor = UIColor.black
                cell.contentLabel.text = self.filteredItems[indexPath.section-1].historydays
            case 4:
                cell.contentLabel.textColor = UIColor.black
                if let totalOutAbv = self.filteredItems[indexPath.section-1].totaloutstanding
                {
                    cell.contentLabel.text = Utility.formatRupee(amount: Double(totalOutAbv )!)
                }
            default:
                break
            }
        }
        return cell
        }
        else{
            let cell = collectionViewSum.dequeueReusableCell(withReuseIdentifier: cellContentIdentifier,
                                                          for: indexPath) as! OutstandingAbvCell
            cell.layer.borderWidth = 1
            cell.layer.borderColor = UIColor.white.cgColor
            
            if indexPath.section == 0 {
                cell.contentLabel.font = UIFont(name: "Roboto-Medium", size: 14)
                if #available(iOS 11.0, *) {
                    cell.backgroundColor = UIColor.init(named: "Primary")
                } else {
                    cell.backgroundColor = UIColor.gray
                }
                switch indexPath.row{
                case 0:
                    cell.contentLabel.text = "SUM"
                case 1:
                    cell.contentLabel.text =   "All Branches"
                case 2:
                    cell.contentLabel.text = "OS - " + Utility.formatRupee(amount: Double(totalOs ))
                case 3:
                    cell.contentLabel.text =   "Highest Days"
                case 4:
                    cell.contentLabel.text = "OS above \(daysSelected) - " + Utility.formatRupee(amount: Double(totalOSAbove ))
                default:
                    break
                }
                
            }else{}
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if(indexPath.row == 1){
        let sb = UIStoryboard(name: "BranchPicker", bundle: nil)
        let popup = sb.instantiateInitialViewController()! as! BranchPickerController
        popup.modalPresentationStyle = .overFullScreen
        popup.delegate = self
        popup.showPicker = 1
        self.present(popup, animated: true)
        }else if indexPath.section == 0{
            
        }else{
            appDelegate.sendCin = filteredItems[indexPath.section-1].cin!
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if let index = collectionView.indexPathsForSelectedItems?.first{
            if((index.row) == 1){
                return false
            }else{
                if index.section == 0{
                    return false
                }else if index.section == self.filteredItems.count + 1{
                    return false
                }else{
                    return true}
            }
        }else{
            return false
        }
    }
    
    func updateOutsDaysValue(value: String, position: Int) {
        daysSelected = noOfDays[position]
        lblDays.setTitle(value, for: .normal)
        ViewControllerUtils.sharedInstance.showLoader()
        apiGetOutstandingByDays()
    }
    
    func updateBranch(value: String, position: Int) {
        if position == 0 {
            filteredItems = self.outStandingObj
            self.totalOs = Int(self.filteredItems.reduce(0, { $0 + Double($1.totalbalance!)! }))
            self.totalOSAbove = Int(self.filteredItems.reduce(0, { $0 + Double($1.totaloutstanding!)! }))
            self.collectionView.reloadData()
            self.collectionView.collectionViewLayout.invalidateLayout()
            self.collectionViewSum.reloadData()
            self.collectionViewSum.collectionViewLayout.invalidateLayout()
            return
        }
        filteredItems = self.outStandingObj.filter { $0.locnm == value }
        self.totalOs = Int(self.filteredItems.reduce(0, { $0 + Double($1.totalbalance!)! }))
        self.totalOSAbove = Int(self.filteredItems.reduce(0, { $0 + Double($1.totaloutstanding!)! }))
        self.collectionView.reloadData()
        self.collectionView.collectionViewLayout.invalidateLayout()
        self.collectionViewSum.reloadData()
        self.collectionViewSum.collectionViewLayout.invalidateLayout()
    }
    
    func apiGetOutstandingByDays(){
        
        let json: [String: Any] = ["ClientSecret":"Client Secret","CIN":UserDefaults.standard.value(forKey: "userCIN") as! String,"Days":daysSelected,"Category":UserDefaults.standard.value(forKey: "userCategory") as! String]
        
        let manager =  DataManager.shared
        
        manager.makeAPICall(url: apiGetOutstandingUrl, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            do {
                self.outStandingAbove = try JSONDecoder().decode([OutstandingAbove].self, from: data!)
                self.outStandingObj  = self.outStandingAbove[0].data
                self.filteredItems = self.outStandingAbove[0].data
                self.totalOs = Int(self.filteredItems.reduce(0, { $0 + Double($1.totalbalance!)! }))
                self.totalOSAbove = Int(self.filteredItems.reduce(0, { $0 + Double($1.totaloutstanding!)! }))
                self.collectionView.reloadData()
                self.collectionView.collectionViewLayout.invalidateLayout()
                self.collectionViewSum.reloadData()
                self.collectionViewSum.collectionViewLayout.invalidateLayout()
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
