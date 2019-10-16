//
//  ComplexViewController.swift
//  ManagementApp
//
//  Created by Goldmedal on 20/08/19.
//  Copyright © 2019 Goldmedal. All rights reserved.
//

import UIKit

class ComplexViewController: BaseViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    //Outlets...
    @IBOutlet weak var collectionView: UICollectionView!
    
    //Declarations...
    var categorywiseComp = [CategorywiseComp]()
    var categorywiseCompObj = [CategorywiseCompObj]()
    var filteredItems = [CategorywiseCompObj]()
    var compareApiUrl = ""
    var cellContentIdentifier = "\(ComplexCell.self)"
    //Picker Related...
    var finYear = ""
    var opType = 3
    var opValue = 0
    var currPosition = 0
    var callFrom = 0
    var strCin = ""
    var strTotalAmnt = "-"
    var dateTo = "08/14/2019"
    var dateFrom = "04/01/2019"
    var prevDateTo = "08/14/2018"
    var prevDateFrom = "04/01/2018"
    var yearStart = "2019"
    var yearEnd = "2020"
    let qrtrlyArrayStart = Utility.quarterlyStartDate()
    let qrtrlyArrayEnd = Utility.quarterlyEndDate()
    let monthEnds = Utility.getMonthEndDate()
    let months = Utility.getMonths()
    var dateFormatter = DateFormatter()
    let monthFormatter = DateFormatter()
    let yearFormatter = DateFormatter()
    let currDate = Date()
    var total = ["currWd":0.0,"currLights":0.0,"currPf":0.0,"currWc":0.0,"currMcbDbs":0.0,"prevWd":0.0,"prevLights":0.0,"prevPf":0.0,"prevWc":0.0,"prevMcbDbs":0.0]
    var allMonths = ["JANUARY", "FEBRUARY", "MARCH", "APRIL","MAY","JUNE","JULY","AUGUST","SEPTEMBER","OCTOBER","NOVEMBER","DECEMBER"];
    var quatMonths = ["Q1 (APR - JUN)", "Q2 (JUL - SEP)", "Q3 (OCT - DEC)", "Q4 (JAN - MAR)"];
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addSlideMenuButton()
//        self.noDataView.hideView(view: self.noDataView)
        dateFormatter.dateFormat = "MM/dd/yyyy"
        monthFormatter.dateFormat = "MM"
        yearFormatter.dateFormat = "yyyy"
        compareApiUrl = "https://api.goldmedalindia.in/api/GetTotalSaleBranchWiseLast"
        ViewControllerUtils.sharedInstance.showLoader()
        apiCompare()
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
                                                      for: indexPath) as! ComplexCell
        
        cell.layer.borderWidth = 1
        cell.layer.borderColor = UIColor.white.cgColor
        
        
        if indexPath.section == 0 {
            cell.contentLabel.font = UIFont(name: "Roboto-Medium", size: 14)
            cell.contentLabel.backgroundColor = UIColor.init(named: "Primary")
            cell.contentLabelTwo.backgroundColor = UIColor.init(named: "Primary")
            switch indexPath.row{
            case 0:
                cell.contentLabel.text = "Branch Name"
            case 1:
                cell.contentLabel.text = "Current W D"
                cell.contentLabelTwo.text = "Previous W D"
            case 2:
                cell.contentLabel.text = "Current Lights"
                cell.contentLabelTwo.text = "Previous Lights"
            case 3:
                cell.contentLabel.text = "Current W&C"
                cell.contentLabelTwo.text = "Previous W&C"
            case 4:
                cell.contentLabel.text = "Current P&F"
                cell.contentLabelTwo.text = "Previous P&F"
            case 5:
                cell.contentLabel.text = "Current Mcb&Dbs"
                cell.contentLabelTwo.text = "Previous Mcb&Dbs"
            case 6:
                cell.contentLabel.text = "Curr. Sale"
                cell.contentLabelTwo.text = "Prev. Sale"
            default:
                break
            }
            
            if indexPath.row == 0 {
                cell.labelHeightConstraintOne.constant = CGFloat(70)
                cell.labelHeightConstraintTwo.constant = CGFloat(0)
            }else{
                cell.labelHeightConstraintOne.constant = CGFloat(35)
                cell.labelHeightConstraintTwo.constant = CGFloat(35)
            }
            
        }else if indexPath.section == filteredItems.count + 1{
            cell.contentLabel.font = UIFont(name: "Roboto-Medium", size: 14)
            cell.contentLabel.backgroundColor = UIColor.init(named: "Primary")
            cell.contentLabelTwo.backgroundColor = UIColor.init(named: "Primary")
            if indexPath.row == 0{
                cell.labelHeightConstraintOne.constant = CGFloat(70)
                cell.labelHeightConstraintTwo.constant = CGFloat(0)
                //cell.contentLabel.backgroundColor = UIColor.init(named: "Primary")
                //cell.contentLabelTwo.backgroundColor = UIColor.init(named: "Primary")
            }else{
                cell.labelHeightConstraintOne.constant = CGFloat(35)
                cell.labelHeightConstraintTwo.constant = CGFloat(35)
                //cell.contentLabel.backgroundColor = UIColor.init(named: "ColorGreen")
                //cell.contentLabelTwo.backgroundColor = UIColor.init(named: "ColorGreen")
            }
            switch indexPath.row{
            case 0:
                cell.contentLabel.text = "SUM"
            case 1:
                cell.contentLabel.text = Utility.formatRupee(amount: (total["currWd"]! ))
                cell.contentLabelTwo.text = Utility.formatRupee(amount: (total["prevWd"]! ))
            case 2:
                cell.contentLabel.text = Utility.formatRupee(amount: (total["currLights"]! ))
                cell.contentLabelTwo.text = Utility.formatRupee(amount: (total["prevLights"]! ))
            case 3:
                cell.contentLabel.text = Utility.formatRupee(amount: (total["currWc"]! ))
                cell.contentLabelTwo.text = Utility.formatRupee(amount: (total["prevWc"]! ))
            case 4:
                cell.contentLabel.text = Utility.formatRupee(amount: (total["currPf"]! ))
                cell.contentLabelTwo.text = Utility.formatRupee(amount: (total["prevPf"]! ))
            case 5:
                cell.contentLabel.text = Utility.formatRupee(amount: (total["currMcbDbs"]! ))
                cell.contentLabelTwo.text = Utility.formatRupee(amount: (total["prevMcbDbs"]! ))
            case 6:
                if let curtotalsale = filteredItems[0].curtotalsale
                {
                    cell.contentLabel.text = Utility.formatRupee(amount: Double(curtotalsale )!)
                }
                if let lasttotalsale = filteredItems[0].lasttotalsale
                {
                    cell.contentLabelTwo.text = Utility.formatRupee(amount: Double(lasttotalsale )!)
                }
            default:
                break
            }
        } else
        {
            cell.contentLabel.font = UIFont(name: "Roboto-Medium", size: 14)
           
            if indexPath.row == 0{
                cell.labelHeightConstraintOne.constant = CGFloat(70)
                cell.labelHeightConstraintTwo.constant = CGFloat(0)
                
                cell.contentLabel.backgroundColor = UIColor.init(named: "Primary")
                cell.contentLabelTwo.backgroundColor = UIColor.init(named: "Primary")
            }else{
                cell.labelHeightConstraintOne.constant = CGFloat(35)
                cell.labelHeightConstraintTwo.constant = CGFloat(35)
                
                cell.contentLabel.backgroundColor = UIColor.init(named: "PrimaryLight")
                cell.contentLabelTwo.backgroundColor = UIColor.init(named: "PrimaryLight")
                
                //cell.contentLabel.backgroundColor = UIColor.init(named: "ColorYellow")
                //cell.contentLabelTwo.backgroundColor = UIColor.init(named: "ColorYellow")
            }
            switch indexPath.row{
            case 0:
                cell.contentLabel.text = filteredItems[indexPath.section - 1].branchnm
            case 1:
                if let curwiringdevices = filteredItems[indexPath.section - 1].curwiringdevices
                {
                    cell.contentLabel.text = Utility.formatRupee(amount: Double(curwiringdevices )!)
                }
                if let lastwiringdevices = filteredItems[indexPath.section - 1].lastwiringdevices
                {
                    cell.contentLabelTwo.text = Utility.formatRupee(amount: Double(lastwiringdevices )!)
                }
            case 2:
                if let curlights = filteredItems[indexPath.section - 1].curlights
                {
                    cell.contentLabel.text = Utility.formatRupee(amount: Double(curlights )!)
                }
                if let lastlights = filteredItems[indexPath.section - 1].lastlights
                {
                    cell.contentLabelTwo.text = Utility.formatRupee(amount: Double(lastlights )!)
                }
            case 3:
                if let curwireandcable = filteredItems[indexPath.section - 1].curwireandcable
                {
                    cell.contentLabel.text = Utility.formatRupee(amount: Double(curwireandcable )!)
                }
                if let lastwireandcable = filteredItems[indexPath.section - 1].lastwireandcable
                {
                    cell.contentLabelTwo.text = Utility.formatRupee(amount: Double(lastwireandcable )!)
                }
            case 4:
                if let curpipesandfittings = filteredItems[indexPath.section - 1].curpipesandfittings
                {
                    cell.contentLabel.text = Utility.formatRupee(amount: Double(curpipesandfittings )!)
                }
                if let lastpipesandfittings = filteredItems[indexPath.section - 1].lastpipesandfittings
                {
                    cell.contentLabelTwo.text = Utility.formatRupee(amount: Double(lastpipesandfittings )!)
                }
            case 5:
                if let curmcbanddbs = filteredItems[indexPath.section - 1].curmcbanddbs
                {
                    cell.contentLabel.text = Utility.formatRupee(amount: Double(curmcbanddbs )!)
                }
                if let lastmcbanddbs = filteredItems[indexPath.section - 1].lastmcbanddbs
                {
                    cell.contentLabelTwo.text = Utility.formatRupee(amount: Double(lastmcbanddbs )!)
                }
            case 6:
                if let curbranchcontribution = filteredItems[indexPath.section - 1].curbranchcontribution
                {
                    cell.contentLabel.text = Utility.formatRupee(amount: Double(curbranchcontribution )!)
                }
                if let lastbranchcontribution = filteredItems[indexPath.section - 1].lastbranchcontribution
                {
                    cell.contentLabelTwo.text = Utility.formatRupee(amount: Double(lastbranchcontribution )!)
                }
            default:
                break
            }
            
        }
        return cell
    }
    
    //APIFUNC...
    func apiCompare(){
        let json: [String: Any] = ["CurFromDate":dateFrom,"CurToDate":dateTo,"ClientSecret":"ClientSecret","CIN":UserDefaults.standard.value(forKey: "userCIN") as! String,"Category":UserDefaults.standard.value(forKey: "userCategory") as! String,"LastFromDate":prevDateFrom,"LastToDate":prevDateTo]
        let manager =  DataManager.shared
        print("Params Sent : \(json)")
        manager.makeAPICall(url: compareApiUrl, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            
            do {
                //self.dashDivObj.removeAll()
                self.categorywiseComp = try JSONDecoder().decode([CategorywiseComp].self, from: data!)
                self.categorywiseCompObj  = self.categorywiseComp[0].data
                self.filteredItems = self.categorywiseComp[0].data
                //Total of All Items...
                self.total["currWd"] = self.filteredItems.reduce(0, { $0 + Double($1.curwiringdevices!)! })
                self.total["currLights"] = self.filteredItems.reduce(0, { $0 + Double($1.curlights!)! })
                self.total["currWc"] = self.filteredItems.reduce(0, { $0 + Double($1.curwireandcable!)! })
                self.total["currPf"] = self.filteredItems.reduce(0, { $0 + Double($1.curpipesandfittings!)! })
                self.total["currMcbDbs"] = self.filteredItems.reduce(0, { $0 + Double($1.curmcbanddbs!)! })
                self.total["prevWd"] = self.filteredItems.reduce(0, { $0 + Double($1.lastwiringdevices!)! })
                self.total["prevLights"] = self.filteredItems.reduce(0, { $0 + Double($1.lastlights!)! })
                self.total["prevWc"] = self.filteredItems.reduce(0, { $0 + Double($1.lastwireandcable!)! })
                self.total["prevPf"] = self.filteredItems.reduce(0, { $0 + Double($1.lastpipesandfittings!)! })
                self.total["prevMcbDbs"] = self.filteredItems.reduce(0, { $0 + Double($1.lastmcbanddbs!)! })
                //self.totalAmount = self.dashBranchObj.reduce(0, { $0 + Double($1.amount!)! })
                self.collectionView.reloadData()
                self.collectionView.collectionViewLayout.invalidateLayout()
                //self.noDataView.hideView(view: self.noDataView)
                ViewControllerUtils.sharedInstance.removeLoader()
            } catch let errorData {
                print(errorData.localizedDescription)
                //self.noDataView.showView(view: self.noDataView, from: "NDA")
                ViewControllerUtils.sharedInstance.removeLoader()
            }
        }) { (Error) in
            print(Error?.localizedDescription as Any)
            //self.noDataView.showView(view: self.noDataView, from: "NDA")
            ViewControllerUtils.sharedInstance.removeLoader()
        }
    }
 
}
