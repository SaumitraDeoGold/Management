//
//  DealerAppointmentViewController.swift
//  ManagementApp
//
//  Created by Goldmedal on 22/03/19.
//  Copyright © 2019 Goldmedal. All rights reserved.
//

import UIKit

struct NDAElement: Codable {
    let result: Bool?
    let message, servertime: String?
    let data: [NDAObj]
}

struct NDAObj: Codable {
    let branch: String?
    let date: String?
    let count: String?
    let branchid, month, year:String?
    
    init(branch: String?, date: String?, count: String?, branchid: String?, month: String?, year: String?) {
        self.branch = branch
        self.date = date
        self.count = count
        self.branchid = branchid
        self.month = month
        self.year = year
    }
}



class DealerAppointmentViewController: BaseViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    @IBOutlet weak var dealerAppmntCollectionVw: UICollectionView!
    @IBOutlet weak var btnFinancialYear: RoundButton!
    @IBOutlet weak var lblYearly: RoundButton!
    @IBOutlet weak var lblMonthly: RoundButton!
    @IBOutlet weak var lblQuarterly: RoundButton!
    @IBOutlet weak var lblFinYear: UILabel!
    @IBOutlet weak var noDataView: NoDataView!
    
    //Declarations
    var cellContentIdentifier = "\(DealerAppCell.self)"
    var apiUrlGetNDAReport = ""
    
    var NDAElementMain = [NDAElement]()
    var NDAElementArr = [NDAObj]()
    var NDAElementSection = [String]()
    var NDAElementArrMain = [[NDAObj]]()
    var NDAElementRetrievingArray = [[NDAObj]]()
    var NDAElementRetrievingObj = [NDAObj]()
    var sortedMonths = [String]()
    
    var ComboItemQty = [String]()
    var ComboItemQtyArr = [[String]]()
    var ComboQtyList = [String]()
    var ComboCommonQty = [NDAObj]()
    
    var customDealerLayout = DealerAppointmentLayout()
    //Picker Related...
    var finYear = ""
    var opType = 3
    var opValue = 0
    var currPosition = 0
    var callFrom = 0
    var dateTo = ""
    var dateFrom = ""
    //let (fromdate, todate) = yearDate()
    var yearStart = "2019"
    var yearEnd = "2020"
    let qrtrlyArrayStart = Utility.quarterlyStartDate()
    let qrtrlyArrayEnd = Utility.quarterlyEndDate()
    let monthEnds = Utility.getMonthEndDate()
    let months = Utility.getMonths()
    var counter = 13
    
    override func viewDidLoad() {
        
        addSlideMenuButton()
        self.noDataView.hideView(view: self.noDataView)
        apiUrlGetNDAReport = "https://api.goldmedalindia.in/api/GetNDAReport"
        ViewControllerUtils.sharedInstance.showLoader()
        (dateFrom, dateTo) = yearDate()
        self.apiGetNDAReport()
        super.viewDidLoad()
        //highlightedButton(callfrom: 4)
    }
  
    @IBAction func yearlyClicked(_ sender: Any) {
        lblFinYear.text = "Financial Year"
        highlightedButton(callfrom: 4)
        callFrom = 4
        dateFrom = months[3]+"01/"+yearStart
        dateTo = months[2]+monthEnds[2]+yearEnd
        apiGetNDAReport()
    }
    @IBAction func monthlyClicked(_ sender: Any) {
        let sb = UIStoryboard(name: "CustomYearPicker", bundle: nil)
        let popup = sb.instantiateInitialViewController()! as! CustomYearPickerController
        popup.modalPresentationStyle = .overFullScreen
        popup.delegate = self
        popup.showPicker = 1
        self.present(popup, animated: true)
        callFrom = 1
        opType = 1
    }
    @IBAction func quarterlyClicked(_ sender: Any) {
        let sb = UIStoryboard(name: "CustomYearPicker", bundle: nil)
        let popup = sb.instantiateInitialViewController()! as! CustomYearPickerController
        popup.modalPresentationStyle = .overFullScreen
        popup.delegate = self
        popup.showPicker = 2
        self.present(popup, animated: true)
        callFrom = 2
        opType = 2
    }
    @IBAction func yearClicked(_ sender: Any) {
        lblFinYear.text = "Financial Year"
        let sb = UIStoryboard(name: "CustomYearPicker", bundle: nil)
        let popup = sb.instantiateInitialViewController()! as! CustomYearPickerController
        popup.modalPresentationStyle = .overFullScreen
        popup.delegate = self
        popup.showPicker = 3
        self.present(popup, animated: true)
        callFrom = 0
        opType = 3
        opValue = 0
    }
    
    func yearDate() -> (String, String){
        let now = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy"
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "MM"
        let currYear = dateFormatter.string(from: now)
        let currMonth = dayFormatter.string(from: now)
        let nextYear = Int(currYear)! + 1
        let prevYear = Int(currYear)! - 1
        var fromdate = ""
        var todate = ""
        print("-------------->CurrYear : \(currYear) currMonth : \(currMonth) nextYear : \(nextYear)  prevYear : \(prevYear)")
        if currMonth == "01" || currMonth == "02" || currMonth == "03"{
            fromdate = "04/01/" + String(prevYear)
            todate = "03/31/" + String(currYear)
            print("-------------->Fromdate : \(fromdate) ToDate : \(todate)")
        }else{
            fromdate = "04/01/" + currYear
            todate = "03/31/" + String(nextYear)
            print("-------------->Fromdate : \(fromdate) ToDate : \(todate)")
        }
        
        return (fromdate, todate)
    }
    
    func updatePositionValue(value: String, position: Int, from: String) {
        ViewControllerUtils.sharedInstance.showLoader()
        switch callFrom {
        case 0:
            lblFinYear.text = "Financial Year"
            highlightedButton(callfrom: 3)
            btnFinancialYear.setTitle(value, for: .normal)
            var tempArray = value.components(separatedBy: "-")
            yearStart = tempArray[0]
            yearEnd = tempArray[1]
            dateFrom = months[3]+"01/"+yearStart
            dateTo = months[2]+monthEnds[2]+yearEnd
            apiGetNDAReport()
        case 1:
            lblFinYear.text = "Monthly Report - " + value
            highlightedButton(callfrom: 1)
            dateFrom = months[position]+"01/"+yearStart
            dateTo = months[position]+monthEnds[position]+yearStart
            apiGetNDAReport()
        case 2:
            lblFinYear.text = "Quarterly Report - " + value
            highlightedButton(callfrom: 2)
            if(position==3){
                dateFrom = qrtrlyArrayStart[position] + yearEnd
                dateTo = qrtrlyArrayEnd[position] + yearEnd
            }else{
                dateFrom = qrtrlyArrayStart[position] + yearStart
                dateTo = qrtrlyArrayEnd[position] + yearStart
            }
            apiGetNDAReport()
        default:
            print("Error")
        }
        
        
    }
    
    func highlightedButton(callfrom: Int){
        self.lblYearly.backgroundColor = (callfrom == 4) ? UIColor(hexString: "#b30000") : UIColor(named: "ColorRed")
        self.lblYearly.shadowOpacity = (callfrom == 4) ? 0 : 1
        self.lblMonthly.backgroundColor = (callfrom == 1) ? UIColor(hexString: "#b30000") : UIColor(named: "ColorRed")
        self.lblMonthly.shadowOpacity = (callfrom == 1) ? 0 : 1
        self.lblQuarterly.backgroundColor = (callfrom == 2) ? UIColor(hexString: "#b30000") : UIColor(named: "ColorRed")
        self.lblQuarterly.shadowOpacity = (callfrom == 2) ? 0 : 1
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return NDAElementSection.count + 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return counter
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = dealerAppmntCollectionVw.dequeueReusableCell(withReuseIdentifier: cellContentIdentifier,
                                                                for: indexPath) as! DealerAppCell
        cell.layer.borderWidth = 1
        cell.layer.borderColor = UIColor.white.cgColor
        
        if sortedMonths.count > 0{if indexPath.section == 0 {
            cell.contentLabel.font = UIFont(name: "Roboto-Medium", size: 16)
            if #available(iOS 11.0, *) {
                cell.backgroundColor = UIColor.init(named: "Primary")
            } else {
                cell.backgroundColor = UIColor.gray
            }
            if(indexPath.item == 0){
                cell.contentLabel.text = "Branch Name"
            }else{
                if(callFrom==1){
                    cell.contentLabel.text = self.sortedMonths[0]
                }else{
                   cell.contentLabel.text = self.sortedMonths[indexPath.item - 1]
                }
                
            }
            
        }else{
            cell.contentLabel.font = UIFont(name: "Roboto-Regular", size: 14)
            if #available(iOS 11.0, *) {
                cell.backgroundColor = UIColor.init(named: "primaryLight")
            } else {
                cell.backgroundColor = UIColor.lightGray
            }
            if(indexPath.item == 0){
                cell.contentLabel.text = self.NDAElementSection[indexPath.section - 1]
            }else {
                cell.contentLabel.text = self.ComboItemQtyArr[indexPath.section - 1][indexPath.item - 1]
            }
            
            }}

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
       //print(self.NDAElementRetrievingArray[indexPath.section-1][indexPath.row-1])
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? NDADetailViewController,
            let index = dealerAppmntCollectionVw.indexPathsForSelectedItems?.first{
            if index.section > 0{
                destination.NDATransferArray = [[self.NDAElementRetrievingArray[index.section-1][index.row-1]]]
            }
            else{
                return
            }
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        
        if let index = dealerAppmntCollectionVw.indexPathsForSelectedItems?.first{
            if((index.section) > 0){
                return true
            }else{
                return false
            }
        }else{
            return false
        }
        
    }
    
    func apiGetNDAReport(){
        self.sortedMonths.removeAll()
        self.ComboItemQtyArr.removeAll()
        self.NDAElementArrMain.removeAll()
        self.NDAElementRetrievingArray.removeAll()
        self.NDAElementSection.removeAll()
        let json: [String: Any] = ["CIN":UserDefaults.standard.value(forKey: "userCIN") as! String,"Category":UserDefaults.standard.value(forKey: "userCategory") as! String,"FromDate":dateFrom,"ClientSecret":"54656","Todate":dateTo]
        
        let manager = DataManager.shared
        
        manager.makeAPICall(url: apiUrlGetNDAReport, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            
            do {
                self.NDAElementMain = try JSONDecoder().decode([NDAElement].self, from: data!)
                self.NDAElementArr = self.NDAElementMain[0].data
                
                let groupedDictionary = Dictionary(grouping: self.NDAElementArr, by: { (ndaReport) -> String in
                    return ndaReport.branch!
                })
                
                let groupedDictionaryMonth = Dictionary(grouping: self.NDAElementArr, by: { (ndaReport) -> String in
                    return ndaReport.date!
                })
                
                let keys = groupedDictionary.keys.sorted()
                let monthKey = groupedDictionaryMonth.keys.sorted()
                
                
                self.sortedMonths = monthKey.map{($0,$0.components(separatedBy:"2"))}
                    .map{($0,$1[1]+" \(Calendar.current.monthSymbols.index(of: $1[0])!+10)")}
                    .sorted{$0.1<$1.1}
                    .map{$0.0}
                
                
                
                self.NDAElementSection.append(contentsOf: keys)
                
                
                keys.forEach({ (key) in
                    self.NDAElementArrMain.append(groupedDictionary[key]!)
                })
                
                
                // - - - -  logic for printing count - -  -- -
                var count = 0
                
                for items in self.NDAElementArrMain{
                    self.ComboItemQty.removeAll()
                    self.ComboQtyList.removeAll()
                    self.ComboCommonQty.removeAll()
                    self.NDAElementRetrievingObj.removeAll()
                    
                    for index in 0...(items.count-1) {
                        self.ComboCommonQty.append(items[index])
                        self.ComboQtyList.append(items[index].date!)
                        count=0
                    }
                    
                    for qty in self.sortedMonths{
                        if(self.ComboQtyList.contains(qty)){
                            self.ComboItemQty.append(self.ComboCommonQty[count].count ?? "-")
                            self.NDAElementRetrievingObj.append(self.ComboCommonQty[count])
                            count+=1
                        }else{
                            self.ComboItemQty.append("X")
                            self.NDAElementRetrievingObj.append(NDAObj.init(branch: "X", date: "X", count: "X", branchid: "X", month: "X", year: "X"))
                        }
                    }
                    
                    self.ComboItemQtyArr.append(self.ComboItemQty)
                    self.NDAElementRetrievingArray.append(self.NDAElementRetrievingObj)
                }
                
                print("Final arr - - - ",self.ComboItemQtyArr)
                
                self.noDataView.hideView(view: self.noDataView)
               ViewControllerUtils.sharedInstance.removeLoader()
            } catch let errorData {
                print(errorData.localizedDescription)
                self.noDataView.showView(view: self.noDataView, from: "NDA")
                ViewControllerUtils.sharedInstance.removeLoader()
            }
            
            if(self.NDAElementArrMain.count > 0 && self.sortedMonths.count > 0){
                self.counter = (self.sortedMonths.count+1)
                self.customDealerLayout.itemAttributes = []
                self.customDealerLayout.numberOfColumns = (self.sortedMonths.count+1)
                self.dealerAppmntCollectionVw.collectionViewLayout = self.customDealerLayout
                self.dealerAppmntCollectionVw.delegate = self
                self.dealerAppmntCollectionVw.dataSource = self
                
                
                self.dealerAppmntCollectionVw.reloadData()
                self.dealerAppmntCollectionVw.collectionViewLayout.invalidateLayout()
                self.dealerAppmntCollectionVw.layoutSubviews()
            }
        }) { (Error) in
            print(Error?.localizedDescription as Any)
            self.noDataView.showView(view: self.noDataView, from: "NDA")
            ViewControllerUtils.sharedInstance.removeLoader()
        }
        
    } 
    
}
