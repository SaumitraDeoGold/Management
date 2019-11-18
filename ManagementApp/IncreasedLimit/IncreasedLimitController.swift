//
//  IncreasedLimitController.swift
//  ManagementApp
//
//  Created by Goldmedal on 16/10/19.
//  Copyright © 2019 Goldmedal. All rights reserved.
//

import UIKit

class IncreasedLimitController: BaseViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    //Outlets...
    @IBOutlet weak var CollectionView: UICollectionView!
    @IBOutlet weak var lblPartyName: UIButton!
    @IBOutlet weak var txtAmount: UITextField!
    
    //Declarations...
    var cellContentIdentifier = "\(CollectionViewCell.self)"
    var cinSelected = ""
    var apiAgingUrl = ""
    var apiUpdateLimitUrl = ""
    var agingDetails = [AgingReport]()
    var agingData = [AgingData]()
    var agingDataObj = [AgingDetails]()
    var updateLimit = [UpdateLimit]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addSlideMenuButton()
        apiAgingUrl = "https://api.goldmedalindia.in/api/getAging"
        apiUpdateLimitUrl = "https://api.goldmedalindia.in/api/UpdateIncreaseLimitParty"
        CollectionView.isHidden = true
    }
    
    //Button...
    @IBAction func searchParty(_ sender: Any) {
        let sb = UIStoryboard(name: "PartyStoryboard", bundle: nil)
        let popup = sb.instantiateInitialViewController()! as! PartySearchController
        popup.modalPresentationStyle = .overFullScreen
        popup.delegate = self
        popup.fromPage = "Limits"
        self.present(popup, animated: true)
    }
    
    @IBAction func submit(_ sender: Any) {
        if txtAmount.text == "" || cinSelected == "" {
            let alert = UIAlertView(title: "Error", message: "Please fill all values", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
        }else{
            apiUpdateLimit()
        }
        
    }
    
    //Popup Func...
    func showParty(value: String,cin: String) {
        lblPartyName.setTitle("  \(value)", for: .normal)
        cinSelected = cin
        ViewControllerUtils.sharedInstance.showLoader()
        apiAgingReport()
    }
    
    //CollectionView Functions...
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return agingDataObj.count + 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = CollectionView.dequeueReusableCell(withReuseIdentifier: cellContentIdentifier,
                                                      for: indexPath) as! CollectionViewCell
        cell.layer.borderWidth = 3
        cell.layer.borderColor = UIColor.white.cgColor
        cell.layer.masksToBounds = false
        cell.layer.shadowOffset = CGSize(width: 0, height: 0)
        cell.layer.shadowRadius = 2
        cell.layer.shadowOpacity = 1
        cell.layer.shadowColor = UIColor.black.cgColor
        if(indexPath.section % 2 != 0){
            cell.backgroundColor = UIColor.white
        }else{
            cell.backgroundColor = UIColor.init(named: "Primary")
            cell.layer.borderColor = UIColor.init(named: "Primary")!.cgColor
        }
        
        if indexPath.section == 0 {
            cell.contentLabel.font = UIFont(name: "Roboto-Medium", size: 16)
            if #available(iOS 11.0, *) {
                cell.backgroundColor = UIColor.init(named: "Primary")
            } else {
                cell.backgroundColor = UIColor.gray
            }
            switch indexPath.row{
            case 0:
                cell.contentLabel.text = "Period (Days)"
            case 1:
                cell.contentLabel.text = "Amount"
                cell.contentLabel.textColor = UIColor.black
            default:
                break
            } 
        } else {
            cell.contentLabel.font = UIFont(name: "Roboto-Regular", size: 14)
//            if #available(iOS 11.0, *) {
//                cell.backgroundColor = UIColor.init(named: "primaryLight")
//            } else {
//                cell.backgroundColor = UIColor.lightGray
//            }
            switch indexPath.row{
            case 0:
                cell.contentLabel.text = agingDataObj[indexPath.section-1].days
            case 1:
               if let amount = agingDataObj[indexPath.section-1].amount
               {
                cell.contentLabel.text = Utility.formatRupee(amount: Double(amount)!)
                }
            default:
                break
            }
        }
        return cell
    }
    
    //API Functions
    func apiAgingReport(){
        
        let json: [String: Any] = ["CIN":cinSelected,"ClientSecret":"ClientSecret"]
        print("Aging DETAILS : \(json)")
        let manager =  DataManager.shared
        
        manager.makeAPICall(url: apiAgingUrl, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            
            do {
                self.agingDetails = try JSONDecoder().decode([AgingReport].self, from: data!)
                self.agingData = self.agingDetails[0].data
                self.agingDataObj = self.agingData[0].agingDetails
                self.CollectionView.isHidden = false
                self.CollectionView.reloadData()
                self.CollectionView.collectionViewLayout.invalidateLayout()
                ViewControllerUtils.sharedInstance.removeLoader()
            } catch let errorData {
                self.CollectionView.isHidden = true
                print(errorData.localizedDescription)
                ViewControllerUtils.sharedInstance.removeLoader()
            }
        }) { (Error) in
            self.CollectionView.isHidden = true
            print(Error?.localizedDescription as Any)
            ViewControllerUtils.sharedInstance.removeLoader()
        }
        
    }
    
    func apiUpdateLimit(){
        
        let json: [String: Any] = ["CIN":cinSelected,"limitamt": txtAmount.text!,"userid": UserDefaults.standard.value(forKey: "userID") as! Int]
        print("UpdateLimit DETAILS : \(json)")
        let manager =  DataManager.shared
        
        manager.makeAPICall(url: apiUpdateLimitUrl, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            
            do {
                let alert = UIAlertView(title: "Success", message: "Limit Increased Successfully", delegate: nil, cancelButtonTitle: "OK")
                alert.show()
                self.txtAmount.text = "" 
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
