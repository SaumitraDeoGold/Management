//
//  DRPChildController.swift
//  ManagementApp
//
//  Created by Goldmedal on 21/04/20.
//  Copyright © 2020 Goldmedal. All rights reserved.
//

import UIKit

class DRPChildController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, PopupDateDelegate {
    
    //Outlets...
    @IBOutlet weak var CollectionView: UICollectionView!
    @IBOutlet weak var noDataView: NoDataView!
    
    //Declarations
    var cellContentIdentifier = "\(CollectionViewCell.self)"
    var rRPData = [RRPData]()
    var rRPDataObj = [RRPDataObj]()
    var filteredItems = [RRPDataObj]()
    var apiRRP = ""
    var totalSales = ["drp":0.0,"rrp":0.0]
    var dataToRecieve = [DRPDataObj]()
    var type = ""
    var statename = [[String : String]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "\(dataToRecieve[0].statenm) -> \(type)"
        apiRRP = "https://test2.goldmedalindia.in/api/statewisepointschild"
        self.noDataView.hideView(view: self.noDataView)
        ViewControllerUtils.sharedInstance.showLoader()
        apiGetDRPChildData()
    }
    
    //CollectionView Layout...
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return filteredItems.count + 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 6
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = CollectionView.dequeueReusableCell(withReuseIdentifier: cellContentIdentifier,
                                                      for: indexPath) as! CollectionViewCell
        cell.layer.borderWidth = 1
        cell.layer.borderColor = UIColor.white.cgColor
        //Header of CollectionView...
        if filteredItems.count > 0{
            if indexPath.section == 0 {
                cell.contentLabel.font = UIFont(name: "Roboto-Medium", size: 16)
                if #available(iOS 11.0, *) {
                    cell.backgroundColor = UIColor.init(named: "Primary")
                } else {
                    cell.backgroundColor = UIColor.gray
                }
                switch indexPath.row{
                case 0:
                    cell.contentLabel.text = "Name"
                case 1:
                    cell.contentLabel.text = "Category"
                case 2:
                    cell.contentLabel.text = "Bal Pnts"
                case 3:
                    cell.contentLabel.text = "Shop Name"
                case 4:
                    cell.contentLabel.text = "Email"
                case 5:
                    cell.contentLabel.text = "Mobile"
                default:
                    break
                }
                
            }  else if indexPath.section == filteredItems.count+1 {
                            cell.contentLabel.font = UIFont(name: "Roboto-Medium", size: 16)
                            if #available(iOS 11.0, *) {
                                cell.backgroundColor = UIColor.init(named: "Primary")
                            } else {
                                cell.backgroundColor = UIColor.gray
                            }
                            cell.contentLabel.lineBreakMode = .byWordWrapping
                            cell.contentLabel.numberOfLines = 0
                
                            switch indexPath.row{
                            case 0:
                                cell.contentLabel.text = "SUM"
                            case 1:
                                cell.contentLabel.text = "Category"
                            case 2:
                                cell.contentLabel.text = String(Int(totalSales["drp"]! ))
                            case 3:
                                cell.contentLabel.text = ""
                                case 4:
                                    cell.contentLabel.text = ""
                                case 5:
                                    cell.contentLabel.text = ""
                            default:
                                break
                            }
                
                        }
            else {
                cell.contentLabel.font = UIFont(name: "Roboto-Regular", size: 14)
                if #available(iOS 11.0, *) {
                    cell.backgroundColor = UIColor.init(named: "primaryLight")
                } else {
                    cell.backgroundColor = UIColor.lightGray
                }
                
                switch indexPath.row{
                case 0:
                    cell.contentLabel.text = filteredItems[indexPath.section-1].fullName 
                case 1:
                    cell.contentLabel.text = filteredItems[indexPath.section-1].categorynm
                case 2:
                    let currentYear = Double(filteredItems[indexPath.section - 1].balancePoints)
                    let prevYear = Double(totalSales["drp"]! )
                    let temp = Double(currentYear!*100)/prevYear
                    cell.contentLabel.attributedText = calculatePercentage(currentYear: Int(currentYear ?? 0.0), prevYear: Int(prevYear), temp: Int(temp))
                case 3:
                    cell.contentLabel.text = filteredItems[indexPath.section-1].shopName
                case 4:
                    cell.contentLabel.text = filteredItems[indexPath.section-1].email
                case 5:
                    cell.contentLabel.text = filteredItems[indexPath.section-1].mobileNo
                default:
                    break
                }
                
            }
        }
        
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 0 && indexPath.row == 0{
            let sb = UIStoryboard(name: "Search", bundle: nil)
            let popup = sb.instantiateInitialViewController()! as! SearchViewController
            popup.modalPresentationStyle = .overFullScreen
            popup.delegate = self
            popup.alltype = statename
            popup.from = "all"
            self.present(popup, animated: true)
        }
    }
    
    func showSearchValue(value: String) {
        if value == "ALL" {
            filteredItems = self.rRPDataObj
            self.CollectionView.reloadData()
            self.CollectionView.collectionViewLayout.invalidateLayout()
            return
        }
        filteredItems = self.rRPDataObj.filter { $0.fullName == value }
        self.CollectionView.reloadData()
        self.CollectionView.collectionViewLayout.invalidateLayout()
        
    }
    
     //Calculate percentage func...
       func calculatePercentage(currentYear: Int, prevYear: Int, temp: Int) -> NSAttributedString{
           let sale = String(currentYear)//Utility.formatRupee(amount: Double(currentYear ))
           let tempVar = String(format: "%.2f", Double(temp))
           var formattedPerc = ""
           if (Double(tempVar)!.isNaN){
               formattedPerc = ""
           }else{
               formattedPerc = " (\(String(format: "%.2f", Double(temp))))%"
           }
           let strNumber: NSString = sale + formattedPerc as NSString // you must set your
           let range = (strNumber).range(of: String(tempVar))
           let attribute = NSMutableAttributedString.init(string: strNumber as String)
           if Double(temp) > 0.0{
               attribute.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor(named: "ColorGreen") as Any , range: range)
           }else{
               attribute.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.red as Any , range: range)
           }
           return attribute
       }
    
    //API CALL...
    func apiGetDRPChildData(){
        let json: [String: Any] = ["ClientSecret":"ClientSecret","CIN":UserDefaults.standard.value(forKey: "userCIN") as! String,"Category":"Management","State":dataToRecieve[0].stateid,"Type":type]
        let manager =  DataManager.shared
        print("Params Sent : \(json)")
        manager.makeAPICall(url: apiRRP, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            
            do {
                self.rRPData = try JSONDecoder().decode([RRPData].self, from: data!)
                self.rRPDataObj  = self.rRPData[0].data
                self.filteredItems  = self.rRPData[0].data
                self.totalSales["drp"] = self.filteredItems.reduce(0, { $0 + Double($1.balancePoints)! })
                for index in 0...(self.filteredItems.count-1) {
                    self.statename.append(["name":self.filteredItems[index].fullName])
                }
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
