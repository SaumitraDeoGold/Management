//
//  SupplierViewController.swift
//  ManagementApp
//
//  Created by Goldmedal on 06/12/19.
//  Copyright © 2019 Goldmedal. All rights reserved.
//

import UIKit

class SupplierViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, PopupDateDelegate {
    
    //Outlets...
    @IBOutlet weak var CollectionView: UICollectionView!
    @IBOutlet weak var noDataView: NoDataView!
    @IBOutlet weak var backButton: UIImageView!
    @IBOutlet weak var sort: UIImageView!
    @IBOutlet weak var header: UILabel!
    
    //Declarations...
    var cellContentIdentifier = "\(CollectionViewCell.self)"
    var supplierApiUrl = ""
    var supplierData = [SupplierData]()
    var supplierDataObj = [SupplierDataObj]()
    var filteredItems = [SupplierDataObj]()
    var dataToRecieve = [LedgerwiseBranchObj]()
    var fromDate = ""
    var toDate = ""
    var total = 0.0
    var ledgerid = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        supplierApiUrl = "https://api.goldmedalindia.in/api/getExpenseChildAll"
        header.text = "Partywise -> \(dataToRecieve[0].branchnm!)"
        self.noDataView.hideView(view: self.noDataView)
        ViewControllerUtils.sharedInstance.showLoader()
        self.title = "Suppliers"
        apiGetSupplier()
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(backClicked(tapGestureRecognizer:)))
        backButton.isUserInteractionEnabled = true
        backButton.addGestureRecognizer(tapGestureRecognizer)
        //Sort
        let tapSortRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapSortRecognizer:)))
        sort.isUserInteractionEnabled = true
        sort.addGestureRecognizer(tapSortRecognizer)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        //navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    @objc func backClicked(tapGestureRecognizer: UITapGestureRecognizer)
    {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func imageTapped(tapSortRecognizer: UITapGestureRecognizer)
    {
        let sb = UIStoryboard(name: "Sorting", bundle: nil)
        let popup = sb.instantiateInitialViewController()! as! SortViewController
        popup.modalPresentationStyle = .overFullScreen
        popup.delegate = self
        popup.showPicker = 1
        popup.pickerDataSource = ["A-Z","Z-A","low to high Amount","high to low Amount"]
        self.present(popup, animated: true)
    }
    
    func sortBy(value: String, position: Int) {
        switch position {
        case 0:
            self.filteredItems = self.supplierDataObj.sorted{($0.name)!.localizedCaseInsensitiveCompare($1.name!) == .orderedAscending}
        case 1:
            self.filteredItems = self.supplierDataObj.sorted{($0.name)!.localizedCaseInsensitiveCompare($1.name!) == .orderedDescending}
        case 2:
            self.filteredItems = self.supplierDataObj.sorted(by: {Double($0.amount!)! < Double($1.amount!)!})
        case 3:
            self.filteredItems = self.supplierDataObj.sorted(by: {Double($0.amount!)! > Double($1.amount!)!})
        default:
            break
        }
        
        self.CollectionView.reloadData()
        self.CollectionView.collectionViewLayout.invalidateLayout()
    }
    
    //Collection View......
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.filteredItems.count + 2
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
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
                cell.contentLabel.text = "Supplier Name"
            case 1:
                cell.contentLabel.text = "Amount"
            case 2:
                cell.contentLabel.text = "Details"
                
            default:
                break
            }
            //cell.backgroundColor = UIColor.lightGray
        }else if indexPath.section == filteredItems.count+1{
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
                cell.contentLabel.text = Utility.formatRupee(amount: Double(total))
                cell.contentLabel.textColor = UIColor.black
            case 2:
                cell.contentLabel.text = "DETAILS"
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
                let currentYear = Double(filteredItems[indexPath.section - 1].amount!)!
                let prevYear = Double(total)
                //let temp = ((currentYear - prevYear)/prevYear)*100
                let temp = (currentYear*100)/prevYear
                cell.contentLabel.attributedText = calculatePercentage(currentYear: currentYear, prevYear: prevYear, temp: temp)
                //                if let amount = partwiseCompObj[indexPath.section - 1].amount
                //                {
                //                    cell.contentLabel.text = Utility.formatRupee(amount: Double(amount )!)
            //                }
            case 2:
                let attributedString = NSAttributedString(string: NSLocalizedString("View Ledger", comment: ""), attributes:[
                    NSAttributedString.Key.foregroundColor : UIColor(named: "ColorBlue") as Any,
                    NSAttributedString.Key.underlineStyle:1.0
                    ])
                cell.contentLabel.attributedText = attributedString                                                                                                                                                                                                                 
            default:
                break
            }
            //cell.backgroundColor = UIColor.groupTableViewBackground
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section > 0 && indexPath.section != filteredItems.count + 1{
            if indexPath.row == 2{
                if filteredItems[indexPath.section-1].link == ""{
                    var alert = UIAlertView(title: "Alert", message: "No Data Found", delegate: nil, cancelButtonTitle: "OK")
                    alert.show()
                }else{
                    performSegue(withIdentifier: "showUrlLedger", sender: self)
                }
            }else{
                performSegue(withIdentifier: "showChildLedger", sender: self)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "showChildLedger") {
        //If item other than BranchName clicked then open next page...
        if let destination = segue.destination as? InvoiceViewController,
            let index = CollectionView.indexPathsForSelectedItems?.first{
            if index.section > 0 {
                //destination.webvwUrl = supplierDataObj[index.section-1].link!
                destination.dataToRecieve = [filteredItems[index.section-1]]
                destination.branchid = dataToRecieve[0].branchid!
                destination.ledgerid = ledgerid
                destination.fromDate = fromDate
                destination.toDate = toDate
                destination.from = "supplier"
            }
            else{
                return
            }
        }
        }else{
            if let destination = segue.destination as? viewPDFController,
                let index = CollectionView.indexPathsForSelectedItems?.first{
                if index.section > 0 {
                    destination.webvwUrl = filteredItems[index.section-1].link!
                }
                else{
                    return
                }
            }
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        //Block Segue if branchname is clicked...
        if let index = CollectionView.indexPathsForSelectedItems?.first{ 
            if((index.section) > 0){
                 if index.section == self.filteredItems.count + 1{
                    return false
                }else{
                    return true}
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
    
    //API Func...
    func apiGetSupplier(){
        let json: [String: Any] = ["CIN":UserDefaults.standard.value(forKey: "userCIN") as! String,"Category":UserDefaults.standard.value(forKey: "userCategory") as! String,"ClientSecret":"ClientSecret","ledgerid":ledgerid,"branchid":dataToRecieve[0].branchid!,"fromdate":fromDate,"todate":toDate]
        let manager =  DataManager.shared
        print("Params Sent : \(json)")
        manager.makeAPICall(url: supplierApiUrl, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            
            do {
                self.supplierData = try JSONDecoder().decode([SupplierData].self, from: data!)
                self.supplierDataObj  = self.supplierData[0].data
                self.filteredItems  = self.supplierData[0].data
                self.total = self.supplierDataObj.reduce(0, { $0 + Double($1.amount!)! })
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