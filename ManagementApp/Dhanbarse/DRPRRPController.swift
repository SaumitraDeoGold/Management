//
//  DRPRRPController.swift
//  ManagementApp
//
//  Created by Goldmedal on 21/04/20.
//  Copyright © 2020 Goldmedal. All rights reserved.
//

import UIKit
class DRPRRPController: BaseViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    //Outlets...
    @IBOutlet weak var CollectionView: UICollectionView!
    @IBOutlet weak var noDataView: NoDataView!
    
    //Declarations
    var cellContentIdentifier = "\(CollectionViewCell.self)"
    var dRPData = [DRPData]()
    var dRPDataObj = [DRPDataObj]()
    var filteredItems = [DRPDataObj]()
    var apiDRP = ""
    var totalSales = ["drp":0.0,"rrp":0.0,"crp":0.0]
    var type = ""
    var statename = [[String : String]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addSlideMenuButton()
        apiDRP = "https://test2.goldmedalindia.in/api/getstatewisepoint"
        self.noDataView.hideView(view: self.noDataView)
        ViewControllerUtils.sharedInstance.showLoader()
        apiGetDRPData()
    }
    
    //CollectionView Layout...
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return filteredItems.count + 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
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
                cell.contentLabel.text = "State Name"
            case 1:
                cell.contentLabel.text = "DRP"
            case 2:
                cell.contentLabel.text = "RRP"
            case 3:
                cell.contentLabel.text = "CRP"
            default:
                break
            }
            
        }
            //Footer[Total] of CollectionView...
        else if indexPath.section == filteredItems.count+1 {
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
                cell.contentLabel.text = Utility.formatRupee(amount: Double(totalSales["drp"]! ))
            case 2:
                cell.contentLabel.text = Utility.formatRupee(amount: Double(totalSales["rrp"]! ))
            case 3:
                cell.contentLabel.text = Utility.formatRupee(amount: Double(totalSales["crp"]! ))
            default:
                break
            }
            
        }
            //Values of CollectionView...
        else {
            cell.contentLabel.font = UIFont(name: "Roboto-Regular", size: 14)
            if #available(iOS 11.0, *) {
                cell.backgroundColor = UIColor.init(named: "primaryLight")
            } else {
                cell.backgroundColor = UIColor.lightGray
            }
            
            switch indexPath.row{
            case 0:
                cell.contentLabel.text = filteredItems[indexPath.section-1].statenm
            case 1:
                let currentYear = Double(filteredItems[indexPath.section - 1].drp)
                let prevYear = Double(totalSales["drp"]! )
                let temp = Double(currentYear!*100)/prevYear
                cell.contentLabel.attributedText = calculatePercentage(currentYear: Int(currentYear ?? 0.0), prevYear: Int(prevYear), temp: Int(temp))
            case 2:
                let currentYear = Double(filteredItems[indexPath.section - 1].rrp)
                let prevYear = Double(totalSales["rrp"]! )
                let temp = Double(currentYear!*100)/prevYear
                cell.contentLabel.attributedText = calculatePercentage(currentYear: Int(currentYear ?? 0.0), prevYear: Int(prevYear), temp: Int(temp))
            case 3:
                cell.contentLabel.text = Utility.formatRupee(amount: 0.0)
            default:
                break
            }
            
        }
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Row : \(indexPath.row)")
        if indexPath.section == 0 && indexPath.row == 0{
            let sb = UIStoryboard(name: "Search", bundle: nil)
            let popup = sb.instantiateInitialViewController()! as! SearchViewController
            popup.modalPresentationStyle = .overFullScreen
            popup.delegate = self
            popup.alltype = statename
            popup.from = "all"
            self.present(popup, animated: true)
        }else if(indexPath.row == 1){
            type = "DRP"
        }else if indexPath.row == 2{
            type = "RRP"
        }else if indexPath.row == 3{
            type = "CRP"
        }
        
        if indexPath.row != 0 && indexPath.section != 0{
            self.performSegue(withIdentifier: "seguePoint", sender: self)
        }
        
    }
    
    func showSearchValue(value: String) {
        if value == "ALL" {
            filteredItems = self.dRPDataObj
            self.CollectionView.reloadData()
            self.CollectionView.collectionViewLayout.invalidateLayout()
            return
        }
        filteredItems = self.dRPDataObj.filter { $0.statenm == value }
        self.CollectionView.reloadData()
        self.CollectionView.collectionViewLayout.invalidateLayout()
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "seguePoint") {
           if let destination = segue.destination as? DRPChildController,
                let index = CollectionView.indexPathsForSelectedItems?.first{
                if index.section > 0 && index.row > 0{
                    destination.type = type
                    destination.dataToRecieve = [filteredItems[index.section-1]]
                }
                else{
                    return
                }
            }
        }
        
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if let index = CollectionView.indexPathsForSelectedItems?.first{
            if((index.section) > 0){
                return true
            }else{
                return false
            }
        }else{
            return false
        }
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
    func apiGetDRPData(){
        let json: [String: Any] = ["ClientSecret":"ClientSecret","CIN":UserDefaults.standard.value(forKey: "userCIN") as! String,"Category":UserDefaults.standard.value(forKey: "userCategory") as! String]
        let manager =  DataManager.shared
        print("Params Sent : \(json)")
        manager.makeAPICall(url: apiDRP, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            
            do {
                self.dRPData = try JSONDecoder().decode([DRPData].self, from: data!)
                self.dRPDataObj  = self.dRPData[0].data
                self.filteredItems  = self.dRPData[0].data
                for index in 0...(self.filteredItems.count-1) {
                    self.statename.append(["name":self.filteredItems[index].statenm])
                }
                //self.statenames = self.dRPData[0].data
                self.totalSales["drp"] = self.filteredItems.reduce(0, { $0 + Double($1.drp)!  })
                self.totalSales["rrp"] = self.filteredItems.reduce(0, { $0 + Double($1.rrp)! })
                self.totalSales["crp"] = self.filteredItems.reduce(0, { $0 + Double($1.crp)! })
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
