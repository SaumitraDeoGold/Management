//
//  AgingReportController.swift
//  ManagementApp
//
//  Created by Goldmedal on 26/05/20.
//  Copyright © 2020 Goldmedal. All rights reserved.
//

import UIKit

class AgingReportController: BaseViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    //Outlets...
    @IBOutlet weak var CollectionView: UICollectionView!
    
    //Declarations...
    var thirdParty = [ThirdPartyAging]()
    var thirdPartyObj = [ThirdPartyAgingObj]()
    var filteredItems = [ThirdPartyAgingObj]()
    var cellContentIdentifier = "\(CollectionViewCell.self)"
    var apiThirdPartyAgingUrl = ""
    var total = ["30":0.0,"60":0.0,"90":0.0,"120":0.0,"150":0.0,"abv":0.0]
    var totalSum = 0.0
    var statename = [[String : String]]()

    override func viewDidLoad() {
        super.viewDidLoad()
        addSlideMenuButton()
        ViewControllerUtils.sharedInstance.showLoader()
        apiThirdPartyAgingUrl = "https://test2.goldmedalindia.in/api/getthirdpartyaging"
        apiThirdPartyAging()
    }
    
    //CollectionView Functions...
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return filteredItems.count + 2
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 7
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
                cell.contentLabel.text = "Party Name"
            case 1:
                cell.contentLabel.text = "0-30Days"
            case 2:
                cell.contentLabel.text = "31-60Days"
            case 3:
                cell.contentLabel.text = "61-90Days"
            case 4:
                cell.contentLabel.text = "91-120Days"
            case 5:
                cell.contentLabel.text = "121-150Days"
            case 6:
                cell.contentLabel.text = "Above 150"
            case 7:
                cell.contentLabel.text = "Total"
            default:
                break
            }
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
            case 1:
                cell.contentLabel.text = Utility.formatRupee(amount: Double(total["30"] ?? 0.0))
            case 2:
                cell.contentLabel.text = Utility.formatRupee(amount: Double(total["60"] ?? 0.0))
            case 3:
                cell.contentLabel.text = Utility.formatRupee(amount: Double(total["90"] ?? 0.0))
            case 4:
                cell.contentLabel.text = Utility.formatRupee(amount: Double(total["120"] ?? 0.0))
            case 5:
                cell.contentLabel.text = Utility.formatRupee(amount: Double(total["150"] ?? 0.0))
            case 6:
                cell.contentLabel.text = Utility.formatRupee(amount: Double(total["abv"] ?? 0.0))
            case 7:
//                var totalSum = Double(total["30"]) + Double(total["60"]) + Double(total["90"]) +  Double(total["120"]) + Double(total["150"]) + Double(total["abv"])
                cell.contentLabel.text = Utility.formatRupee(amount: Double(totalSum))
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
            case 1:
                if let to30Days = filteredItems[indexPath.section - 1].to30Days
                {
                    cell.contentLabel.text = Utility.formatRupee(amount: Double(to30Days )!)
                }
            case 2:
                if let to60Days = filteredItems[indexPath.section - 1].to60Days
                {
                    cell.contentLabel.text = Utility.formatRupee(amount: Double(to60Days )!)
                }
            case 3:
                if let to90Days = filteredItems[indexPath.section - 1].to90Days
                {
                    cell.contentLabel.text = Utility.formatRupee(amount: Double(to90Days )!)
                }
            case 4:
                if let to120Days = filteredItems[indexPath.section - 1].to120Days
                {
                    cell.contentLabel.text = Utility.formatRupee(amount: Double(to120Days )!)
                }
            case 5:
                if let to150Days = filteredItems[indexPath.section - 1].to150Days
                {
                    cell.contentLabel.text = Utility.formatRupee(amount: Double(to150Days )!)
                }
            case 6:
                if let ab150Days = filteredItems[indexPath.section - 1].ab150Days
                {
                    cell.contentLabel.text = Utility.formatRupee(amount: Double(ab150Days )!)
                }
//            case 7:
//                let tempTotal = Double(Double(filteredItems[indexPath.section - 1].to30Days!) + Double(filteredItems[indexPath.section - 1].to60Days!) + Double(filteredItems[indexPath.section - 1].to90Days!))
//                let tTotal = Double(Double(filteredItems[indexPath.section - 1].to120Days!) + Double(filteredItems[indexPath.section - 1].to150Days!) + Double(filteredItems[indexPath.section - 1].ab150Days!))
//                cell.contentLabel.text = Utility.formatRupee(amount: Double(tempTotal + tTotal )!)
            case 0:
                cell.contentLabel.text = filteredItems[indexPath.section - 1].party
            default:
                break
            }
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
            appDelegate.sendCin = filteredItems[indexPath.section-1].partyId!
            appDelegate.partyName = filteredItems[indexPath.section-1].party!
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let destViewController : UIViewController = storyboard.instantiateViewController(withIdentifier: "NewDashBoard")
            let topViewController : UIViewController = self.navigationController!.topViewController!
            self.navigationController!.pushViewController(destViewController, animated: true)
        }
    }
    
    func showSearchValue(value: String) {
        if value == "ALL" {
            filteredItems = self.thirdPartyObj
            self.CollectionView.reloadData()
            self.CollectionView.collectionViewLayout.invalidateLayout()
            return
        }
        filteredItems = self.thirdPartyObj.filter { $0.party == value }
        self.CollectionView.reloadData()
        self.CollectionView.collectionViewLayout.invalidateLayout()
        
    }
    
    func getCurrentDate() -> String{
        let now = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy"
        let todayDate = dateFormatter.string(from: now)
        return todayDate
    }
     
    //API Functions
    func apiThirdPartyAging(){
        
        let json: [String: Any] = ["CIN":UserDefaults.standard.value(forKey: "userCIN") as! String,"Category":UserDefaults.standard.value(forKey: "userCategory") as! String,"ClientSecret":"ohdashfl","Date":getCurrentDate()]
        print("Aging DETAILS : \(json)")
        let manager =  DataManager.shared
        
        manager.makeAPICall(url: apiThirdPartyAgingUrl, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            
            do {
                self.thirdParty = try JSONDecoder().decode([ThirdPartyAging].self, from: data!)
                self.thirdPartyObj = self.thirdParty[0].data
                self.filteredItems = self.thirdParty[0].data
                for index in 0...(self.filteredItems.count-1) {
                    self.statename.append(["name":self.filteredItems[index].party!])
                }
                self.total["30"] = self.filteredItems.reduce(0, { $0 + Double($1.to30Days ?? "0.0")! })
                self.total["60"] = self.filteredItems.reduce(0, { $0 + Double($1.to60Days ?? "0.0")! })
                self.total["90"] = self.filteredItems.reduce(0, { $0 + Double($1.to90Days ?? "0.0")! })
                self.total["120"] = self.filteredItems.reduce(0, { $0 + Double($1.to120Days ?? "0.0")! })
                self.total["150"] = self.filteredItems.reduce(0, { $0 + Double($1.to150Days ?? "0.0")! })
                self.total["abv"] = self.filteredItems.reduce(0, { $0 + Double($1.ab150Days ?? "0.0")! })
                self.totalSum = self.total["30"]! + self.total["60"]! + self.total["90"]! + self.total["120"]! + self.total["150"]! + self.total["abv"]!
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
