//
//  PartyPurchaseController.swift
//  ManagementApp
//
//  Created by Goldmedal on 28/08/20.
//  Copyright © 2020 Goldmedal. All rights reserved.
//

//
//  CatPurchaseController.swift
//  ManagementApp
//
//  Created by Goldmedal on 28/08/20.
//  Copyright © 2020 Goldmedal. All rights reserved.
//

struct PartyPurchase: Codable {
    let result: Bool?
    let message, servertime: String?
    let data: [PartyPurchaseObj]
}

// MARK: - Datum
struct PartyPurchaseObj: Codable {
    let displaynmwitharea, amount, partyId, typeCat: String?
}

import UIKit
class PartyPurchaseController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, PopupDateDelegate {
     
    //Outlets...
    @IBOutlet weak var noDataView: NoDataView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var btnYear: UIButton!
    
    //Declarations...
    var cellContentIdentifier = "\(CollectionViewCell.self)"
    var catPurchaseData = [PartyPurchase]()
    var catPurchaseObj = [PartyPurchaseObj]()
    var filteredItems = [PartyPurchaseObj]()
    var finYear = "2020-2021"
    var opType = 3
    var opValue = 0
    var callFrom = 0
    var catId = ""
    var total = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.noDataView.hideView(view: self.noDataView)
        self.title = "Partywise Amount"
        btnYear.setTitle("\(finYear) ▼", for: .normal)
        if (Utility.isConnectedToNetwork()) {
            ViewControllerUtils.sharedInstance.showLoader()
            apiLastDispatchedMaterial()
        }
        else{
            self.noDataView.showView(view: self.noDataView, from: "NET")
        }
 
    }
    
    @IBAction func clickedYear(_ sender: Any) {
         let sb = UIStoryboard(name: "CustomYearPicker", bundle: nil)
         let popup = sb.instantiateInitialViewController()! as! CustomYearPickerController
         popup.modalPresentationStyle = .overFullScreen
         popup.delegate = self
         popup.showPicker = 3
         parent!.present(popup, animated: true)
         callFrom = 0
         opType = 3
         opValue = 0
    }
    
    func updatePositionValue(value: String, position: Int, from: String) {
        ViewControllerUtils.sharedInstance.showLoader()
        switch callFrom {
        case 0:
            btnYear.setTitle("\(value) ▼", for: .normal)
            finYear = value
            apiLastDispatchedMaterial()
        default:
            print("Error")
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return  (self.filteredItems.count + 2)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // swiftlint:disable force_cast
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellContentIdentifier,
        for: indexPath) as! CollectionViewCell
        
        if indexPath.section == 0 {
            if #available(iOS 11.0, *) {
                cell.backgroundColor = UIColor.init(named: "Primary")
            } else {
                cell.backgroundColor = UIColor.gray
            }
        } else {
            if #available(iOS 11.0, *) {
                cell.backgroundColor = UIColor.init(named: "primaryLight")
            } else {
                cell.backgroundColor = UIColor.lightGray
            }
        }
        
        cell.layer.borderWidth = 1
        cell.layer.borderColor = UIColor.white.cgColor
        
        if indexPath.section == 0 {
            if indexPath.row == 1 {
                cell.contentLabel.text = "Amount"
            } else if indexPath.row == 0 {
                cell.contentLabel.text = "Party Name"
            }
        }
        
        if indexPath.section == self.filteredItems.count + 1 {
            if #available(iOS 11.0, *) {
                cell.backgroundColor = UIColor.init(named: "Primary")
            } else {
                cell.backgroundColor = UIColor.gray
            }
            if indexPath.row == 0 {
                cell.contentLabel.text = "Total"
            } else if indexPath.row == 1 {
                cell.contentLabel.text = Utility.formatRupee(amount: (total))
            }
        }else if indexPath.section != 0 {
            if(self.catPurchaseObj.count > 0)
            {
                if indexPath.row == 0 {
                    cell.contentLabel.text = self.filteredItems[indexPath.section-1].displaynmwitharea ?? "-"
                } else if indexPath.row == 1 {
                    let currentYear = Double(filteredItems[indexPath.section-1].amount!)!
                    let prevYear = Double(total)
                    let temp = (currentYear*100)/prevYear
                    cell.contentLabel.attributedText = Utility.calculatePercentage(currentYear: currentYear, prevYear: prevYear, temp: temp)
//                    if let finalAmt = filteredItems[indexPath.section-1].amount {
//                        cell.contentLabel.text = Utility.formatRupee(amount: Double(finalAmt)!)
//                    }
                }
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == 0 && indexPath.section == 0{
            let sb = UIStoryboard(name: "PartyStoryboard", bundle: nil)
            let popup = sb.instantiateInitialViewController()! as! PartySearchController
            popup.modalPresentationStyle = .overFullScreen
            popup.delegate = self
            popup.fromPage = "PartyPurchase"
            popup.partyPurchase = catPurchaseObj
            popup.tempPartyPurchaseObj = catPurchaseObj
            self.present(popup, animated: true)
        }else if indexPath.section != 0{
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.sendCin = filteredItems[indexPath.section-1].partyId!
            appDelegate.partyName = filteredItems[indexPath.section-1].displaynmwitharea!
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let destViewController : UIViewController = storyboard.instantiateViewController(withIdentifier: "NewDashBoard")
            self.navigationController!.pushViewController(destViewController, animated: true)
        }
    }
    
    func showParty(value: String,cin: String) {
        if value == "All" {
            filteredItems = self.catPurchaseObj
            self.collectionView.reloadData()
            self.collectionView.collectionViewLayout.invalidateLayout()
            return
        }
        filteredItems = self.catPurchaseObj.filter { $0.displaynmwitharea == value }
        self.collectionView.reloadData()
        self.collectionView.collectionViewLayout.invalidateLayout()
    }
     
    
    
    func apiLastDispatchedMaterial(){
            self.noDataView.showView(view: self.noDataView, from: "LOADER")
            //self.collectionView.showNoData = true
    
        let json: [String: Any] =  ["CIN":UserDefaults.standard.value(forKey: "userCIN") as! String, "Category":UserDefaults.standard.value(forKey: "userCategory") as! String,"ClientSecret":"ohdashfl","Finyear":finYear,"CatId":catId]
            print("Vendor Invoice Params powise \(json)")
            DataManager.shared.makeAPICall(url: "https://test2.goldmedalindia.in/api/getpartywisepurchase", params: json, method: .POST, success: { (response) in
                let data = response as? Data
    
                DispatchQueue.main.async {
                    do {
                        self.catPurchaseData = try JSONDecoder().decode([PartyPurchase].self, from: data!)
                        self.catPurchaseObj = self.catPurchaseData[0].data
                        self.filteredItems = self.catPurchaseData[0].data
                        self.total = self.filteredItems.reduce(0, { $0 + Double($1.amount!)! })
                        print("Cat Purchase Obj  Data \(self.catPurchaseObj)")
    
                    } catch let errorData {
                        ViewControllerUtils.sharedInstance.removeLoader()
                        print(errorData.localizedDescription)
                    }
                    ViewControllerUtils.sharedInstance.removeLoader()
                    if(self.collectionView != nil)
                    {
                        self.collectionView.reloadData()
                    }
    
                    if(self.catPurchaseObj.count > 0)
                    {
                        self.noDataView.hideView(view: self.noDataView)
                        //self.collectionView.showNoData = false
                    }
                    else
                    {
                        self.noDataView.showView(view: self.noDataView, from: "NDA")
                        //self.collectionView.showNoData = true
                    }
                }
            }) { (Error) in
                ViewControllerUtils.sharedInstance.removeLoader()
                self.noDataView.showView(view: self.noDataView, from: "ERR")
                //self.collectionView.showNoData = true
                print(Error?.localizedDescription)
            }
        }
     
}
