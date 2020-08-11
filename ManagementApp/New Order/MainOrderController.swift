//
//  MainOrderController.swift
//  ManagementApp
//
//  Created by Goldmedal on 21/07/20.
//  Copyright © 2020 Goldmedal. All rights reserved.
//

import UIKit

class MainOrderController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, PopupDateDelegate {
    
    //Outlets...
    @IBOutlet weak var noDataView: NoDataView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var sort: UIImageView!
    @IBOutlet weak var lblHeader: UILabel!
    
    //Declarations...
    var pendingOrder = [MainOrderPending]()
    var pendingOrderObj = [MainOrderPendingObj]()
    var filteredItems = [MainOrderPendingObj]()
    var pendingApiUrl = ""
    var cellContentIdentifier = "\(CollectionViewCell.self)"
    var total = ["Wd":0.0,"Lights":0.0,"Pf":0.0,"Wc":0.0,"McbDbs":0.0]
    var branchId = "0"
    var poType = "0"
    var index = 0
    var tempTotal = 0.0
    var sendDivCode = "1"
    var header = ""
    
    override func viewDidLoad() {
        super.viewDidLoad() 
        self.noDataView.hideView(view: self.noDataView)
//        dateFormatter.dateFormat = "MM/dd/yyyy"
//        monthFormatter.dateFormat = "MM"
//        yearFormatter.dateFormat = "yyyy"
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(clicked_sort(tapGestureRecognizer:)))
        sort.isUserInteractionEnabled = true
        sort.addGestureRecognizer(tapGestureRecognizer)
        pendingApiUrl = "https://test2.goldmedalindia.in/api/getbranchdivisionwisepending"
        ViewControllerUtils.sharedInstance.showLoader()
        apiCompare()
    }
    
    @objc func clicked_sort(tapGestureRecognizer: UITapGestureRecognizer) {
        let sb = UIStoryboard(name: "Sorting", bundle: nil)
        let popup = sb.instantiateInitialViewController()! as! SortViewController
        popup.modalPresentationStyle = .overFullScreen
        popup.delegate = self
        popup.showPicker = 1
        popup.pickerDataSource = ["Transfer","Sale","A-Z","Z-A"]
        self.present(popup, animated: true)
    }
    
    func sortBy(value: String, position: Int) {
        switch position {
        case 0:
            poType = String(position)
            lblHeader.text = "Transfer Pending Order"
            ViewControllerUtils.sharedInstance.showLoader()
            apiCompare()
        case 1:
            poType = String(position)
            ViewControllerUtils.sharedInstance.showLoader()
            lblHeader.text = "Sales Pending Order"
            apiCompare()
        case 2:
            self.filteredItems = self.filteredItems.sorted{($0.name)!.localizedCaseInsensitiveCompare($1.name!) == .orderedAscending}
        case 3:
            self.filteredItems = self.filteredItems.sorted{($0.name)!.localizedCaseInsensitiveCompare($1.name!) == .orderedDescending}
         
        default:
            break
        }
        
        self.collectionView.reloadData()
        self.collectionView.collectionViewLayout.invalidateLayout()
    }

    
    //Collectionview...
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return filteredItems.count + 2
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 7
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellContentIdentifier,
                                                                for: indexPath) as! CollectionViewCell
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
                cell.contentLabel.text = "Branch Name"
            case 1:
                cell.contentLabel.text = "Wiring Devices"
            case 2:
                cell.contentLabel.text = "Wire & Cable"
            case 3:
                cell.contentLabel.text = "Lights"
            case 4:
                cell.contentLabel.text = "Mcb & Dbs"
            case 5:
                cell.contentLabel.text = "Pipes & Fittings"
            case 6:
                cell.contentLabel.text = "Total"
            default:
                break
            }
            
        }else if indexPath.section == filteredItems.count + 1{
            cell.contentLabel.font = UIFont(name: "Roboto-Regular", size: 14)
            if #available(iOS 11.0, *) {
                cell.backgroundColor = UIColor.init(named: "Primary")
            } else {
                cell.backgroundColor = UIColor.gray
            }
            switch indexPath.row{
            case 0:
                cell.contentLabel.text = "SUM"
            case 1:
                cell.contentLabel.text = Utility.formatRupee(amount: Double(total["Wd"]!))
            case 2:
                cell.contentLabel.text = Utility.formatRupee(amount: Double(total["Wc"]!))
            case 3:
                cell.contentLabel.text = Utility.formatRupee(amount: Double(total["Lights"]!))
            case 4:
                cell.contentLabel.text = Utility.formatRupee(amount: Double(total["Pf"]!))
            case 5:
                cell.contentLabel.text = Utility.formatRupee(amount: Double(total["McbDbs"]!))
            case 6:
                tempTotal = Double(total["Wd"]!)+Double(total["Wc"]!)+Double(total["Lights"]!)+Double(total["Pf"]!)+Double(total["McbDbs"]!)
                cell.contentLabel.text = Utility.formatRupee(amount: tempTotal)
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
                cell.contentLabel.text = filteredItems[indexPath.section - 1].name
            case 1:
                let currentYear = Double(filteredItems[indexPath.section - 1].wiringdevices!)!
                let prevYear = Double(total["Wd"]!)
                let temp = (currentYear*100)/prevYear
                cell.contentLabel.attributedText = calculatePercentage(currentYear: currentYear, prevYear: prevYear, temp: temp)
            case 2:
                let currentYear = Double(filteredItems[indexPath.section - 1].wireAndCABLE!)!
                let prevYear = Double(total["Wc"]!)
                let temp = (currentYear*100)/prevYear
                cell.contentLabel.attributedText = calculatePercentage(currentYear: currentYear, prevYear: prevYear, temp: temp)
            case 3:
                let currentYear = Double(filteredItems[indexPath.section - 1].lights!)!
                let prevYear = Double(total["Lights"]!)
                let temp = (currentYear*100)/prevYear
                cell.contentLabel.attributedText = calculatePercentage(currentYear: currentYear, prevYear: prevYear, temp: temp)
            case 4:
                let currentYear = Double(filteredItems[indexPath.section - 1].pipesAndFITTINGS!)!
                let prevYear = Double(total["Pf"]!)
                let temp = (currentYear*100)/prevYear
                cell.contentLabel.attributedText = calculatePercentage(currentYear: currentYear, prevYear: prevYear, temp: temp)
            case 5:
                let currentYear = Double(filteredItems[indexPath.section - 1].mcbAndDBS!)!
                let prevYear = Double(total["McbDbs"]!)
                let temp = (currentYear*100)/prevYear
                cell.contentLabel.attributedText = calculatePercentage(currentYear: currentYear, prevYear: prevYear, temp: temp)
            case 6:
                let currentYear = Double(filteredItems[indexPath.section - 1].wiringdevices!)! + Double(filteredItems[indexPath.section - 1].wireAndCABLE!)! + Double(filteredItems[indexPath.section - 1].lights!)! + Double(filteredItems[indexPath.section - 1].pipesAndFITTINGS!)! + Double(filteredItems[indexPath.section - 1].mcbAndDBS!)!
                let prevYear = Double(tempTotal)
                let temp = (currentYear*100)/prevYear
                cell.contentLabel.attributedText = calculatePercentage(currentYear: currentYear, prevYear: prevYear, temp: temp)
            default:
                break
            }
            
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == self.collectionView {
            if(indexPath.row == 0 && indexPath.section == 0){
                let sb = UIStoryboard(name: "Search", bundle: nil)
                let popup = sb.instantiateInitialViewController()! as! SearchViewController
                popup.modalPresentationStyle = .overFullScreen
                popup.delegate = self
                popup.from = "branch"
                self.present(popup, animated: true)
            }else if indexPath.row != 0 && indexPath.row != 6 && indexPath.section != 0 && indexPath.section != filteredItems.count + 1{
                if indexPath.row == 1 {
                    sendDivCode = "1"
                    header = "Wiring Devices"
                }else if indexPath.row == 2{
                    header = "Wire & Cable"
                    sendDivCode = "4"
                }else if indexPath.row == 3{
                    header = "Lights"
                    sendDivCode = "2"
                }else if indexPath.row == 4{
                    header = "Pipes & Fittings"
                    sendDivCode = "6"
                }else if indexPath.row == 5{
                    header = "Mcb & Dbs"
                    sendDivCode = "7"
                }
                index = (indexPath.section-1)
                performSegue(withIdentifier: "segueOrderCategory", sender: self)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "segueOrderCategory") {
            if let destination = segue.destination as? CategoryWiseOrderController{
                destination.branchCode = filteredItems[index].partyId!
                destination.poType = poType
                destination.divCode = sendDivCode
                destination.divName = header
                destination.branchName = filteredItems[index].name!
            }else{
                
            }
        }
        
    }
    
    func showSearchValue(value: String) {
        if value == "ALL" {
            filteredItems = self.pendingOrderObj
            self.collectionView.reloadData()
            self.collectionView.collectionViewLayout.invalidateLayout()
            return
        }
        filteredItems = self.pendingOrderObj.filter { $0.name == value }
        self.collectionView.reloadData()
        self.collectionView.collectionViewLayout.invalidateLayout()
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
    
    //APIFUNC...
    func apiCompare(){
        let json: [String: Any] = ["ClientSecret":"ClientSecret","CIN":UserDefaults.standard.value(forKey: "userCIN") as! String,"Category":UserDefaults.standard.value(forKey: "userCategory") as! String,"BranchId":branchId,"potype":poType]
        let manager =  DataManager.shared
        print("Params Sent : \(json)")
        manager.makeAPICall(url: pendingApiUrl, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            
            do {
                //self.dashDivObj.removeAll()
                self.pendingOrder = try JSONDecoder().decode([MainOrderPending].self, from: data!)
                self.pendingOrderObj  = self.pendingOrder[0].data
                self.filteredItems = self.pendingOrder[0].data
                print("Response : \(self.filteredItems)")
                //Total of All Items...
                self.total["Wd"] = self.filteredItems.reduce(0, { $0 + Double($1.wiringdevices!)! })
                self.total["Lights"] = self.filteredItems.reduce(0, { $0 + Double($1.lights!)! })
                self.total["Wc"] = self.filteredItems.reduce(0, { $0 + Double($1.wireAndCABLE!)! })
                self.total["Pf"] = self.filteredItems.reduce(0, { $0 + Double($1.pipesAndFITTINGS!)! })
                self.total["McbDbs"] = self.filteredItems.reduce(0, { $0 + Double($1.mcbAndDBS!)! })
                  
                self.collectionView.reloadData()
                self.collectionView.collectionViewLayout.invalidateLayout()
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
