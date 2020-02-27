//
//  InsureViewController.swift
//  ManagementApp
//
//  Created by Goldmedal on 28/01/20.
//  Copyright © 2020 Goldmedal. All rights reserved.
//

import UIKit

class InsureViewController: BaseViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    //Outlets...
    @IBOutlet weak var CollectionView: UICollectionView!
    
    //Declarations
    var cellContentIdentifier = "\(CollectionViewCell.self)"
    var insurance = [Insurance]()
    var insuranceObj = [InsuranceObj]()
    var filteredItems = [InsuranceObj]()
    var apiInsurance = ""
    var totalSales = ["secure":0.0,"unsecure":0.0,"outs":0.0]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addSlideMenuButton()
        apiInsurance = "https://test2.goldmedalindia.in/api/getManagementbranchwisesecuredamt"
        ViewControllerUtils.sharedInstance.showLoader()
        apiGetSecureData()
    }
    
    //Sort Related...
    @IBAction func clicked_sort(_ sender: Any) {
        let sb = UIStoryboard(name: "Sorting", bundle: nil)
        let popup = sb.instantiateInitialViewController()! as! SortViewController
        popup.modalPresentationStyle = .overFullScreen
        popup.delegate = self
        popup.showPicker = 1
        popup.pickerDataSource = ["A-Z","Z-A","low to high Unsecure Amt","high to low Unsecure Amt"]
        self.present(popup, animated: true)
    }
    
    func sortBy(value: String, position: Int) {
        switch position {
        case 0:
            self.filteredItems = self.insuranceObj.sorted{($0.branch)!.localizedCaseInsensitiveCompare($1.branch!) == .orderedAscending}
        case 1:
            self.filteredItems = self.insuranceObj.sorted{($0.branch)!.localizedCaseInsensitiveCompare($1.branch!) == .orderedDescending}
        case 2:
            self.filteredItems = self.insuranceObj.sorted(by: {Double($0.unSecured!) < Double($1.unSecured!)})
        case 3:
            self.filteredItems = self.insuranceObj.sorted(by: {Double($0.unSecured!) > Double($1.unSecured!)})
        default:
            break
        }
        
        self.CollectionView.reloadData()
        self.CollectionView.collectionViewLayout.invalidateLayout()
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
                cell.contentLabel.text = "Branch Name"
            case 1:
                cell.contentLabel.text = "Secure Amt"
            case 2:
                cell.contentLabel.text = "Unsecure Amt"
            case 3:
                cell.contentLabel.text = "Outs. Amt"
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
                cell.contentLabel.text = Utility.formatRupee(amount: Double(totalSales["secure"]! ))
            case 2:
                cell.contentLabel.text = Utility.formatRupee(amount: Double(totalSales["unsecure"]! ))
            case 3:
                cell.contentLabel.text = Utility.formatRupee(amount: Double(totalSales["outs"]! ))
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
                cell.contentLabel.text = filteredItems[indexPath.section-1].branch
            case 1:
                let currentYear = Double(filteredItems[indexPath.section - 1].secured!)
                let prevYear = Double(totalSales["secure"]!)
                let temp = (currentYear*100)/prevYear
                cell.contentLabel.attributedText = calculatePercentage(currentYear: currentYear, prevYear: prevYear, temp: temp)
            case 2:
                let currentYear = Double(filteredItems[indexPath.section - 1].unSecured!)
                let prevYear = Double(totalSales["unsecure"]!)
                let temp = (currentYear*100)/prevYear
                cell.contentLabel.attributedText = calculatePercentage(currentYear: currentYear, prevYear: prevYear, temp: temp)
            case 3:
                let currentYear = Double(filteredItems[indexPath.section - 1].outstanding!)
                let prevYear = Double(totalSales["outs"]!)
                let temp = (currentYear*100)/prevYear
                cell.contentLabel.attributedText = calculatePercentage(currentYear: currentYear, prevYear: prevYear, temp: temp)
            default:
                break
            }
            
        }
        
        return cell
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? PartywiseInsureController,
            let index = CollectionView.indexPathsForSelectedItems?.first{
            if index.section > 0{
                    destination.dataToReceive = [filteredItems[index.section-1]]
            }
            else{
                return
            }
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if let index = CollectionView.indexPathsForSelectedItems?.first{
            if((index.section) > 0){
                    if index.section == self.filteredItems.count + 1{
                        return false
                    }else{
                        return true
                    }
            }else{
                return false
            }
        }else{
            return false
        }
    }
    
    //Calculate percentage func...
    func calculatePercentage(currentYear: Double, prevYear: Double, temp: Double) -> NSAttributedString{
        let sale = Utility.formatRupee(amount: Double(currentYear ))
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
        return attribute
    }
    
    //API CALL...
    func apiGetSecureData(){
        let json: [String: Any] = ["ClientSecret":"ClientSecret","CIN":UserDefaults.standard.value(forKey: "userCIN") as! String,"Category":UserDefaults.standard.value(forKey: "userCategory") as! String]
        let manager =  DataManager.shared
        print("Params Sent : \(json)")
        manager.makeAPICall(url: apiInsurance, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            
            do {
                self.insurance = try JSONDecoder().decode([Insurance].self, from: data!)
                self.insuranceObj  = self.insurance[0].data
                self.filteredItems  = self.insurance[0].data
                self.totalSales["secure"] = self.filteredItems.reduce(0, { $0 + Double($1.secured!) })
                self.totalSales["unsecure"] = self.filteredItems.reduce(0, { $0 + Double($1.unSecured!) })
                self.totalSales["outs"] = self.filteredItems.reduce(0, { $0 + Double($1.outstanding!) })
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
