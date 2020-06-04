//
//  DistWiseChildController.swift
//  ManagementApp
//
//  Created by Goldmedal on 30/07/19.
//  Copyright © 2019 Goldmedal. All rights reserved.
//

import UIKit

class DistWiseChildController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    //Outlets...
    @IBOutlet weak var CollectionView: UICollectionView!
    @IBOutlet weak var noDataView: NoDataView!
    
    //Declarations...
    var distWiseChild = [DistWiseChild]()
    var distWiseChildObj = [DistWiseChildObj]()
    var cellContentIdentifier = "\(CollectionViewCell.self)"
    var apiDistWiseParty = ""
    var dataToReceive = [DistWiseCompareObj]()
    var totalCurrSale = ["currSale":0.0,"lastSale":0.0,"yearBeforeLast":0.0]

    override func viewDidLoad() {
        super.viewDidLoad()
        apiDistWiseParty = "https://api.goldmedalindia.in/api/getDistrictwiseSaleComparechild"
        apiGetDistChild()
    }
    
    //Button Functions...
    @IBAction func backBtnClick(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //CollectionView Functions...
    func numberOfSections(in collectionView: UICollectionView) -> Int {
            return distWiseChildObj.count + 2
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
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
                cell.contentLabel.text = "Party Name"
            case 1:
                cell.contentLabel.text = "CY Sale 20-21"
                cell.contentLabel.textColor = UIColor.black
            case 2:
                cell.contentLabel.text = "LY Sale 19-20"
            case 3:
                cell.contentLabel.text = "2018-2019"
                cell.contentLabel.textColor = UIColor.black
            default:
                break
            }
            //cell.backgroundColor = UIColor.lightGray
        }else if indexPath.section == distWiseChildObj.count + 1{
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
                cell.contentLabel.text = Utility.formatRupee(amount: Double(totalCurrSale["currSale"]! ))
                cell.contentLabel.textColor = UIColor.black
            case 2:
                cell.contentLabel.text = Utility.formatRupee(amount: Double(totalCurrSale["lastSale"]! ))
            case 3:
                cell.contentLabel.text = Utility.formatRupee(amount: Double(totalCurrSale["yearBeforeLast"]! ))
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
                if distWiseChildObj[indexPath.section - 1].partystatus != "Active"{
                    cell.contentLabel.textColor = UIColor(named: "ColorRed")
                }else{
                    cell.contentLabel.textColor = UIColor.black
                }
                cell.contentLabel.text = distWiseChildObj[indexPath.section - 1].name
            case 1:
                cell.contentLabel.textColor = UIColor.black
                let currentYear = Double(distWiseChildObj[indexPath.section - 1].currentyearsale!)!
                let prevYear = Double(distWiseChildObj[indexPath.section - 1].previousyearsale!)!
                let temp = ((currentYear - prevYear)/prevYear)*100
                if let currentyearsale = Double(distWiseChildObj[indexPath.section - 1].currentyearsale!)
                {
                    cell.contentLabel.text = Utility.formatRupee(amount: Double(currentyearsale ))
                    let sale = Utility.formatRupee(amount: Double(currentyearsale ))
                    let tempVar = String(format: "%.2f", temp)
                    var formattedPerc = ""
                    if (Double(tempVar)!.isInfinite) || (Double(tempVar)!.isNaN){
                        formattedPerc = ""
                    }else{
                        formattedPerc = " (\(String(format: "%.2f", temp)))%"
                    }
                    let strNumber: NSString = sale + formattedPerc as NSString // you must set your
                    let range = (strNumber).range(of: String(tempVar))
                    let attribute = NSMutableAttributedString.init(string: strNumber as String)
                    if temp > 0{
                        attribute.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor(named: "ColorGreen") as Any , range: range)
                    }else{
                        attribute.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.red as Any , range: range)
                    }
                    cell.contentLabel.attributedText = attribute
                }
            case 2:
                cell.contentLabel.textColor = UIColor.black
                let currentYear = Double(distWiseChildObj[indexPath.section - 1].previousyearsale!)
                let prevYear = Double(distWiseChildObj[indexPath.section - 1].previoustwoyearsale!)
                let temp = ((currentYear! - prevYear!)/prevYear!)*100
                if let previousyearsale = Double(distWiseChildObj[indexPath.section - 1].previousyearsale!)
                {
                    let sale = Utility.formatRupee(amount: Double(previousyearsale ))
                    let tempVar = String(format: "%.2f", temp)
                    var formattedPerc = ""
                    if (Double(tempVar)!.isInfinite) || (Double(tempVar)!.isNaN){
                        formattedPerc = ""
                    }else{
                        formattedPerc = " (\(String(format: "%.2f", temp)))%"
                    }
                    let strNumber: NSString = sale + formattedPerc as NSString // you must set your
                    let range = (strNumber).range(of: String(tempVar))
                    let attribute = NSMutableAttributedString.init(string: strNumber as String)
                    if temp > 0{
                        attribute.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor(named: "ColorGreen") as Any , range: range)
                    }else{
                        attribute.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.red as Any , range: range)
                    }
                    cell.contentLabel.attributedText = attribute
                }
            case 3:
                if let previoustwoyearsale = Double(distWiseChildObj[indexPath.section - 1].previoustwoyearsale!)
                {
                    cell.contentLabel.text = Utility.formatRupee(amount: Double(previoustwoyearsale ))
                    cell.contentLabel.textColor = UIColor.black
                }
            default:
                break
            }
            //cell.backgroundColor = UIColor.groupTableViewBackground
        }
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.sendCin = distWiseChildObj[indexPath.section-1].cin!
    }
    
    //API Functions...
    func apiGetDistChild(){
        
        let json: [String: Any] = ["CIN":UserDefaults.standard.value(forKey: "userCIN") as! String,"Category":UserDefaults.standard.value(forKey: "userCategory") as! String,"ClientSecret":"ohdashfl","distid":dataToReceive[0].distid!]
        
        let manager =  DataManager.shared
        
        manager.makeAPICall(url: apiDistWiseParty, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            do {
                self.distWiseChild = try JSONDecoder().decode([DistWiseChild].self, from: data!)
                self.distWiseChildObj = self.distWiseChild[0].data
                self.totalCurrSale["currSale"] = self.distWiseChildObj.reduce(0, { $0 + Double($1.currentyearsale!)! })
                self.totalCurrSale["lastSale"] = self.distWiseChildObj.reduce(0, { $0 + Double($1.previousyearsale!)! })
                self.totalCurrSale["yearBeforeLast"] = self.distWiseChildObj.reduce(0, { $0 + Double($1.previoustwoyearsale!)! })
                self.CollectionView.reloadData()
                self.CollectionView.collectionViewLayout.invalidateLayout()
                self.noDataView.hideView(view: self.noDataView)
            } catch let errorData {
                print(errorData.localizedDescription)
                self.noDataView.hideView(view: self.noDataView)
            }
        }) { (Error) in
            print(Error?.localizedDescription as Any)
            self.noDataView.hideView(view: self.noDataView)
        }
        
    }
    
    
}
