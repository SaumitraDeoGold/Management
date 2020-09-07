//
//  AgentLimitController.swift
//  ManagementApp
//
//  Created by Goldmedal on 20/04/20.
//  Copyright © 2020 Goldmedal. All rights reserved.
//

import UIKit

class AgentLimitController: BaseViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    //Outlets...
    @IBOutlet weak var CollectionView: UICollectionView!
    
    //Declarations
    var cellContentIdentifier = "\(CollectionViewCell.self)"
    var agentLimit = [AgentLimit]()
    var agentLimitObj = [AgentLimitObj]()
    var filteredItems = [AgentLimitObj]()
    var apiAgentLimit = ""
    var totalSales = ["secure":0.0,"unsecure":0.0,"outs":0.0,"agentL":0]
    var noOfColumns = Int()
    var isagent = false
    var statename = [[String : String]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addSlideMenuButton()
        apiAgentLimit = "https://test2.goldmedalindia.in/api/getManagementagentwisesecuredamt"
        ViewControllerUtils.sharedInstance.showLoader()
        if UserDefaults.standard.value(forKey: "userCategory") as! String == "Agent"{
            isagent = true
            noOfColumns = 2
        }else{
            noOfColumns = 5
        }
        apiGetAgentData()
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
            self.filteredItems = self.agentLimitObj.sorted{($0.agent).localizedCaseInsensitiveCompare($1.agent) == .orderedAscending}
        case 1:
            self.filteredItems = self.agentLimitObj.sorted{($0.agent).localizedCaseInsensitiveCompare($1.agent) == .orderedDescending}
        case 2:
            self.filteredItems = self.agentLimitObj.sorted(by: {Double($0.unSecured) < Double($1.unSecured)})
        case 3:
            self.filteredItems = self.agentLimitObj.sorted(by: {Double($0.unSecured) > Double($1.unSecured)})
        default:
            break
        }
        
        self.CollectionView.reloadData()
        self.CollectionView.collectionViewLayout.invalidateLayout()
    }
    
    //CollectionView Layout...
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if isagent{
           return 5
        }else{
           return filteredItems.count + 2
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return noOfColumns
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = CollectionView.dequeueReusableCell(withReuseIdentifier: cellContentIdentifier,
                                                      for: indexPath) as! CollectionViewCell
        cell.layer.borderWidth = 1
        cell.layer.borderColor = UIColor.white.cgColor
        //Header of CollectionView...
        if isagent && filteredItems.count > 0{
            if #available(iOS 11.0, *) {
                cell.backgroundColor = UIColor.init(named: "primaryLight")
            } else {
                cell.backgroundColor = UIColor.gray
            }
            if indexPath.row == 0{
                cell.contentLabel.font = UIFont(name: "Roboto-Medium", size: 16)
                switch indexPath.section{
                case 0:
                    cell.contentLabel.text = "Branch Name"
                case 1:
                    cell.contentLabel.text = "Secure Amt"
                case 2:
                    cell.contentLabel.text = "Unsecure Amt"
                case 3:
                    cell.contentLabel.text = "Outs. Amt"
                case 4:
                    cell.contentLabel.text = "Agent Limit"
                default:
                    break
                }
            }else{
                cell.contentLabel.font = UIFont(name: "Roboto-Medium", size: 16)
                switch indexPath.section{
               case 0:
                   cell.contentLabel.text = filteredItems[0].agent
               case 1:
                   let currentYear = Double(filteredItems[0].secured)
                   let prevYear = Double(filteredItems[0].outstanding)
                   let temp = (currentYear*100)/prevYear
                   cell.contentLabel.attributedText = calculatePercentage(currentYear: currentYear, prevYear: prevYear, temp: temp, from: "")
               case 2:
                   let currentYear = Double(filteredItems[0].unSecured)
                   let prevYear = Double(filteredItems[0].outstanding)
                   let temp = (currentYear*100)/prevYear
                   cell.contentLabel.attributedText = calculatePercentage(currentYear: currentYear, prevYear: prevYear, temp: temp, from: "unsecured")
               case 3:
                   let currentYear = Double(filteredItems[0].outstanding)
                   let prevYear = Double(totalSales["outs"]!)
                   let temp = (currentYear*100)/prevYear
                   cell.contentLabel.attributedText = calculatePercentage(currentYear: currentYear, prevYear: prevYear, temp: temp, from: "")
               case 4:
                   let currentYear = Double(filteredItems[0].agentLimit)
                   let prevYear = Double(totalSales["agentL"]!)
                   let temp = (currentYear*100)/prevYear
                   cell.contentLabel.attributedText = calculatePercentage(currentYear: currentYear, prevYear: prevYear, temp: temp, from: "")
                default:
                    break
                }
            }
            
            return cell
        } else if filteredItems.count > 0{
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
                case 4:
                    cell.contentLabel.text = "Agent Limit"
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
                case 4:
                    cell.contentLabel.text = Utility.formatRupee(amount: Double(totalSales["agentL"]! ))
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
                    cell.contentLabel.text = filteredItems[indexPath.section-1].agent
                case 1:
                    let currentYear = Double(filteredItems[indexPath.section - 1].secured)
                    let prevYear = Double(filteredItems[indexPath.section - 1].outstanding)
                    let temp = (currentYear*100)/prevYear
                    cell.contentLabel.attributedText = calculatePercentage(currentYear: currentYear, prevYear: prevYear, temp: temp, from: "")
                case 2:
                    let currentYear = Double(filteredItems[indexPath.section - 1].unSecured)
                    let prevYear = Double(filteredItems[indexPath.section - 1].outstanding)
                    let temp = (currentYear*100)/prevYear
                    cell.contentLabel.attributedText = calculatePercentage(currentYear: currentYear, prevYear: prevYear, temp: temp, from: "unsecured")
                case 3:
                    let currentYear = Double(filteredItems[indexPath.section - 1].outstanding)
                    let prevYear = Double(totalSales["outs"]!)
                    let temp = (currentYear*100)/prevYear
                    cell.contentLabel.attributedText = calculatePercentage(currentYear: currentYear, prevYear: prevYear, temp: temp, from: "")
                case 4:
                    let currentYear = Double(filteredItems[indexPath.section - 1].agentLimit)
                    let prevYear = Double(totalSales["agentL"]!)
                    let temp = (currentYear*100)/prevYear
                    cell.contentLabel.attributedText = calculatePercentage(currentYear: currentYear, prevYear: prevYear, temp: temp, from: "")
                default:
                    break
                }
                
            }
            
            return cell
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
            filteredItems = self.agentLimitObj
            self.CollectionView.reloadData()
            self.CollectionView.collectionViewLayout.invalidateLayout()
            return
        }
        filteredItems = self.agentLimitObj.filter { $0.agent == value }
        self.CollectionView.reloadData()
        self.CollectionView.collectionViewLayout.invalidateLayout()
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? PartyAgentLimitController,
            let index = CollectionView.indexPathsForSelectedItems?.first{
            if index.section > 0{
                if isagent{
                   destination.dataToRecieve = [filteredItems[0]]
                }else{
                   destination.dataToRecieve = [filteredItems[index.section-1]]
                }
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
    func calculatePercentage(currentYear: Double, prevYear: Double, temp: Double, from: String) -> NSAttributedString{
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
            if from == "unsecured"{
                attribute.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor(named: "ColorRed") as Any , range: range)
                return attribute
            }
            attribute.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor(named: "ColorGreen") as Any , range: range)
        }else{
            attribute.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.red as Any , range: range)
        }
        return attribute
    }
    
    //API CALL...
    func apiGetAgentData(){
        let json: [String: Any] = ["ClientSecret":"ClientSecret","CIN":UserDefaults.standard.value(forKey: "userCIN") as! String,"Category":UserDefaults.standard.value(forKey: "userCategory") as! String]
        let manager =  DataManager.shared
        print("Params Sent : \(json)")
        manager.makeAPICall(url: apiAgentLimit, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            
            do {
                self.agentLimit = try JSONDecoder().decode([AgentLimit].self, from: data!)
                self.agentLimitObj  = self.agentLimit[0].data
                self.filteredItems  = self.agentLimit[0].data
                self.totalSales["secure"] = self.filteredItems.reduce(0, { $0 + Double($1.secured) })
                self.totalSales["unsecure"] = self.filteredItems.reduce(0, { $0 + Double($1.unSecured) })
                self.totalSales["outs"] = self.filteredItems.reduce(0, { $0 + Double($1.outstanding) })
                self.totalSales["agentL"] = Double(self.filteredItems.reduce(0, { $0 + Int($1.agentLimit) }))
                for index in 0...(self.filteredItems.count-1) {
                    self.statename.append(["name":self.filteredItems[index].agent])
                }
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
