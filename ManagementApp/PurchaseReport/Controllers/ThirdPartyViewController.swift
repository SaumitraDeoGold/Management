//
//  ThirdPartyViewController.swift
//  ManagementApp
//
//  Created by Goldmedal on 20/05/20.
//  Copyright © 2020 Goldmedal. All rights reserved.
//

import UIKit

class ThirdPartyViewController: BaseViewController, UITableViewDelegate , UITableViewDataSource {

    //Outlets...
    @IBOutlet weak var CollectionView: UICollectionView!
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var lblPartyName: UIButton!
    @IBOutlet weak var btnFromDate: UIButton!
    @IBOutlet weak var btnToDate: UIButton!
    
    //Declarations...
    var apiThirdPartyStat = ""
    var thirdPartyStatus = [ThirdPartyStatus]()
    var thirdPartyStatusObj = [ThirdPartyStatusObj]()
    var filteredItems = [ThirdPartyStatusObj]()
    var cellContentIdentifier = "\(CollectionViewCell.self)"
    var total = 0.0
    var divCode = "1"
    let currDate = Date()
    var dateFormatter = DateFormatter()
    var fromDate: Date?
    var toDate: Date?
    var strFromDate = ""
    var strToDate = ""
    var fromdate = "04/01/2020"
    var todate = "03/31/2021"
    var statename = [[String : String]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        apiThirdPartyStat = "https://test2.goldmedalindia.in/api/Getthirdpartypurstatus"
        dateFormatter.dateFormat = "dd/MM/yyyy"
        strToDate = dateFormatter.string(from: currDate)
        fromDate = dateFormatter.date(from: strFromDate)
        toDate = dateFormatter.date(from: strToDate)
        ViewControllerUtils.sharedInstance.showLoader()
        addSlideMenuButton()
        apiThirdPartyData()
    }
    
    //Button...
    @IBAction func searchParty(_ sender: Any) {
        let sb = UIStoryboard(name: "PartyStoryboard", bundle: nil)
        let popup = sb.instantiateInitialViewController()! as! PartySearchController
        popup.modalPresentationStyle = .overFullScreen
        popup.delegate = self
        popup.fromPage = "Division"
        self.present(popup, animated: true)
    }
    
    @IBAction func clicked_from_date_div(_ sender: UIButton) {
        sender.isSelected = true
        let sb = UIStoryboard(name: "DatePicker", bundle: nil)
        let popup = sb.instantiateInitialViewController()  as? DatePickerController
        popup?.fromDate = fromDate
        popup?.toDate = toDate
        popup?.isFromDate = true
        popup?.delegate = self
        self.present(popup!, animated: true)
    }
    
    @IBAction func clicked_to_date_div(_ sender: UIButton) {
        sender.isSelected = true
        let sb = UIStoryboard(name: "DatePicker", bundle: nil)
        let popup = sb.instantiateInitialViewController()  as? DatePickerController
        popup?.delegate = self
        popup?.toDate = toDate
        popup?.fromDate = fromDate
        popup?.isFromDate = false
        self.present(popup!, animated: true)
    }
    
    //Popup Func...
    func showParty(value: String,cin: String) {
        lblPartyName.setTitle("  \(value)", for: .normal)
        divCode = cin
        ViewControllerUtils.sharedInstance.showLoader()
        apiThirdPartyData()
    }
    
    func updateDate(value: String, date: Date) {
        if btnFromDate.isSelected {
            btnFromDate.setTitle(value, for: .normal)
            btnFromDate.isSelected = false
            fromDate = date
            strFromDate = Utility.formattedDateFromString(dateString: value, withFormat: "MM/dd/yyyy")!
            fromdate = strFromDate
            //dailyfromdate = fromdate
        }
        else
        {
            btnToDate.setTitle(value, for: .normal)
            btnToDate.isSelected = false
            toDate = date
            strToDate = Utility.formattedDateFromString(dateString: value, withFormat: "MM/dd/yyyy")!
            todate = strToDate
            //dailytodate = todate
        }
        
        apiThirdPartyData()
    }
    
    func getOnlyDate(value: String) -> String{
        var tempDate = value.split{$0 == " "}.map(String.init)
        var inFormatDate = tempDate[0].split{$0 == "/"}.map(String.init)
        let temp = "\(inFormatDate[1])/\(inFormatDate[0])/\(inFormatDate[2])"
        return temp
    }
    
    //TableView Functions...
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredItems.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "DispatchedMaterialCell", for: indexPath) as! DispatchedMaterialCell
        if(filteredItems.count>0){
            
            if let amount = filteredItems[indexPath.row].total as? String {
                cell.lblAmnt.text = Utility.formatRupee(amount: Double(amount)!)
            }
            cell.lblLrNo.text = filteredItems[indexPath.row].orderStatus
            cell.lblDivision.text = filteredItems[indexPath.row].branch ?? "-"
            cell.lblInvoiceDate.text = getOnlyDate(value: filteredItems[indexPath.row].poDate!)
            cell.lblTransporter.text = filteredItems[indexPath.row].status ?? "-"
            cell.lblInvoiceNumber.text = filteredItems[indexPath.row].pono!
            cell.lblItemName.text = filteredItems[indexPath.row].party!
            
            let imvPdf = UITapGestureRecognizer(target: self, action: #selector(self.pdfTapped))
            cell.imvDownloadPdf.isUserInteractionEnabled = true
            cell.imvDownloadPdf.tag = indexPath.row
            cell.imvDownloadPdf.addGestureRecognizer(imvPdf)
            
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.sendCin = filteredItems[indexPath.item].partyId!
        appDelegate.partyName = filteredItems[indexPath.item].party!
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let destViewController = storyboard.instantiateViewController(withIdentifier: "NewDashBoard") as! NewDashboardViewController 
        parent?.navigationController!.pushViewController(destViewController, animated: true)
    }
    
    func pdfTapped(sender: UITapGestureRecognizer) {
        print("pdf name : \(sender.view?.tag)")
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let destViewController = storyboard.instantiateViewController(withIdentifier: "Webview") as! viewPDFController
        destViewController.webvwUrl = filteredItems[sender.view!.tag].url!
        let topViewController : UIViewController = self.navigationController!.topViewController!
        self.navigationController!.pushViewController(destViewController, animated: true)
        
//        guard let url = URL(string: DispatchedMaterialArray[sender.view!.tag].url ?? "") else {
//            var alert = UIAlertView(title: "Error", message: "Invalid Pdf", delegate: nil, cancelButtonTitle: "OK")
//            alert.show()
//
//            return
//        }
//        if UIApplication.shared.canOpenURL(url) {
//            UIApplication.shared.open(url, options: [:], completionHandler: nil)
//        }
        
    }

    //Collection View......
//    func numberOfSections(in collectionView: UICollectionView) -> Int {
//        return self.filteredItems.count + 2
//    }
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return 8
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = CollectionView.dequeueReusableCell(withReuseIdentifier: cellContentIdentifier,
//                                                      for: indexPath) as! CollectionViewCell
//        cell.layer.borderWidth = 1
//        cell.layer.borderColor = UIColor.white.cgColor
//
//        if indexPath.section == 0 {
//            cell.contentLabel.font = UIFont(name: "Roboto-Medium", size: 16)
//            if #available(iOS 11.0, *) {
//                cell.backgroundColor = UIColor.init(named: "Primary")
//            } else {
//                cell.backgroundColor = UIColor.gray
//            }
//            switch indexPath.row{
//            case 4:
//                cell.contentLabel.text = "Branch"
//            case 5:
//                cell.contentLabel.text = "PO No"
//            case 1:
//                cell.contentLabel.text = "PO Date"
//            case 0:
//                cell.contentLabel.text = "Party Name"
//            case 3:
//                cell.contentLabel.text = "Order Status"
//            case 6:
//                cell.contentLabel.text = "Status"
//            case 2:
//                cell.contentLabel.text = "Total"
//            case 7:
//                cell.contentLabel.text = "Print"
//
//            default:
//                break
//            }
//            //cell.backgroundColor = UIColor.lightGray
//        }else if indexPath.section == filteredItems.count+1{
//            cell.contentLabel.font = UIFont(name: "Roboto-Medium", size: 16)
//            if #available(iOS 11.0, *) {
//                cell.backgroundColor = UIColor.init(named: "Primary")
//            } else {
//                cell.backgroundColor = UIColor.gray
//            }
//            switch indexPath.row{
//            case 4:
//                cell.contentLabel.text = "Branch"
//            case 5:
//                cell.contentLabel.text = "PO No"
//            case 1:
//                cell.contentLabel.text = "PO Date"
//            case 0:
//                cell.contentLabel.text = "Party Name"
//            case 3:
//                cell.contentLabel.text = "Order Status"
//            case 6:
//                cell.contentLabel.text = "SUM"
//            case 2:
//                cell.contentLabel.text = Utility.formatRupee(amount: total)
//            case 7:
//                cell.contentLabel.text = "Print"
//            default:
//                break
//            }
//        } else {
//            cell.contentLabel.font = UIFont(name: "Roboto-Regular", size: 14)
//            if #available(iOS 11.0, *) {
//                cell.backgroundColor = UIColor.init(named: "primaryLight")
//            } else {
//                cell.backgroundColor = UIColor.lightGray
//            }
//            switch indexPath.row{
//             case 4:
//                cell.contentLabel.text = filteredItems[indexPath.section-1].branch
//            case 5:
//                cell.contentLabel.text = filteredItems[indexPath.section-1].pono
//            case 1:
//                cell.contentLabel.text = getOnlyDate(value: filteredItems[indexPath.section-1].poDate!)
//            case 0:
//                cell.contentLabel.text = filteredItems[indexPath.section-1].party
//            case 3:
//                cell.contentLabel.text = filteredItems[indexPath.section-1].orderStatus
//            case 6:
//                cell.contentLabel.text = filteredItems[indexPath.section-1].status
//            case 2:
//                if let totalAmt = filteredItems[indexPath.section - 1].total
//                {
//                    cell.contentLabel.text = Utility.formatRupee(amount: Double(totalAmt )!)
//                }
//            case 7:
//                cell.contentLabel.text = "View Pdf 🔖"
//            default:
//                break
//            }
//            //cell.backgroundColor = UIColor.groupTableViewBackground
//        }
//        return cell
//    }
//
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        if indexPath.section == 0 && indexPath.row == 0 {
//           let sb = UIStoryboard(name: "Search", bundle: nil)
//            let popup = sb.instantiateInitialViewController()! as! SearchViewController
//            popup.modalPresentationStyle = .overFullScreen
//            popup.delegate = self
//            popup.alltype = statename
//            popup.from = "all"
//            self.present(popup, animated: true)
//        }else if indexPath.section != 0 && indexPath.section != filteredItems.count + 1 && indexPath.row != 7{
//            let appDelegate = UIApplication.shared.delegate as! AppDelegate
//            appDelegate.sendCin = filteredItems[indexPath.section-1].partyId!
//            appDelegate.partyName = filteredItems[indexPath.item].party!
//            let storyboard = UIStoryboard(name: "Main", bundle: nil)
//            let destViewController : UIViewController = storyboard.instantiateViewController(withIdentifier: "NewDashBoard")
//            let topViewController : UIViewController = self.navigationController!.topViewController!
//            self.navigationController!.pushViewController(destViewController, animated: true)
//        }else if indexPath.row == 7{
//
//            let storyboard = UIStoryboard(name: "Main", bundle: nil)
//            let destViewController = storyboard.instantiateViewController(withIdentifier: "Webview") as! viewPDFController
//            destViewController.webvwUrl = filteredItems[indexPath.section - 1].url!
//            let topViewController : UIViewController = self.navigationController!.topViewController!
//            self.navigationController!.pushViewController(destViewController, animated: true)
//        }
//    }
//
//    func showSearchValue(value: String) {
//        if value == "ALL" {
//            filteredItems = self.thirdPartyStatusObj
//            self.CollectionView.reloadData()
//            self.CollectionView.collectionViewLayout.invalidateLayout()
//            return
//        }
//        filteredItems = self.thirdPartyStatusObj.filter { $0.party == value }
//        self.CollectionView.reloadData()
//        self.CollectionView.collectionViewLayout.invalidateLayout()
//
//    }
    
    //API CALLS..............
    func apiThirdPartyData(){
        
        let json: [String: Any] = ["CIN":UserDefaults.standard.value(forKey: "userCIN") as! String,"Category":UserDefaults.standard.value(forKey: "userCategory") as! String,"Fromdate":fromdate,"Todate":todate,"ClientSecret":"ClientSecret","DivId":divCode]
        
        let manager =  DataManager.shared
        print("thirdPartyStatus params \(json)")
        manager.makeAPICall(url: apiThirdPartyStat, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            
            do {
               self.thirdPartyStatus = try JSONDecoder().decode([ThirdPartyStatus].self, from: data!)
               print("thirdPartyStatus result \(self.thirdPartyStatus[0].data)")
               self.thirdPartyStatusObj = self.thirdPartyStatus[0].data
               self.filteredItems = self.thirdPartyStatus[0].data
                for index in 0...(self.filteredItems.count-1) {
                    self.statename.append(["name":self.filteredItems[index].party!])
                }
               self.total = self.filteredItems.reduce(0, { $0 + Double($1.total!)! })
                self.tableview.reloadData()
//               self.CollectionView.reloadData()
//               self.CollectionView.collectionViewLayout.invalidateLayout()
                //self.CollectionView.setContentOffset(CGPoint.zero, animated: true)
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
