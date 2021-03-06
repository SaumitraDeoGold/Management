//
//  InvoiceViewController.swift
//  ManagementApp
//
//  Created by Goldmedal on 14/12/19.
//  Copyright © 2019 Goldmedal. All rights reserved.
//

import UIKit

class InvoiceViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, PopupDateDelegate {

    //Outlets...
    @IBOutlet weak var CollectionView: UICollectionView!
    @IBOutlet weak var noDataView: NoDataView!
    @IBOutlet weak var backButton: UIImageView!
    @IBOutlet weak var sort: UIImageView!
    @IBOutlet weak var header: UILabel!
    
    //Declarations...
    var cellContentIdentifier = "\(CollectionViewCell.self)"
    var invoiceApiUrl = ""
    var invoiceData = [InvoiceData]()
    var invoiceDataObj = [InvoiceDataObj]()
    var filteredItems = [InvoiceDataObj]()
    var dataToRecieve = [SupplierDataObj]()
    var dataFromBranch = [ExpenseHeadObj]()
    var fromDate = ""
    var toDate = ""
    var ledgerid = ""
    var branchid = ""
    var suppliername = ""
    var total = 0.0
    var from = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        invoiceApiUrl = "https://api.goldmedalindia.in/api/getExpenseChildAllSubChild"
        self.noDataView.hideView(view: self.noDataView)
        ViewControllerUtils.sharedInstance.showLoader()
        if from == "supplier" {
            suppliername = dataToRecieve[0].name!
            header.text = "Invoice -> \(dataToRecieve[0].name!)"
        }else{
            suppliername = dataFromBranch[0].name!
            header.text = "Invoice -> \(dataFromBranch[0].name!)"
        }
        apiGetInvoice()
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
        popup.pickerDataSource = ["low to high Amount","high to low Amount"]
        self.present(popup, animated: true)
    }
    
    func sortBy(value: String, position: Int) {
        switch position {
        case 0:
            self.filteredItems = self.invoiceDataObj.sorted(by: {Double($0.amount!)! < Double($1.amount!)!})
        case 1:
            self.filteredItems = self.invoiceDataObj.sorted(by: {Double($0.amount!)! > Double($1.amount!)!})
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
        return 7
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
                cell.contentLabel.text = "Date"
            case 1:
                cell.contentLabel.text = "Amount"
            case 2:
                cell.contentLabel.text = "Narration"
            case 3:
                cell.contentLabel.text = "Payment Mode"
            case 4:
                cell.contentLabel.text = "Type"
            case 5:
                cell.contentLabel.text = "Invoice No."
            case 6:
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
                cell.contentLabel.text = "Narration"
            case 3:
                cell.contentLabel.text = "Payment Mode"
            case 4:
                cell.contentLabel.text = "Type"
            case 5:
                cell.contentLabel.text = "Invoice No."
            case 6:
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
                var splitDate = self.filteredItems[indexPath.section-1].date!.split{$0 == " "}.map(String.init)
                var indianFormatDate = splitDate[0].split{$0 == "/"}.map(String.init)
                cell.contentLabel.text = "\(indianFormatDate[1])/\(indianFormatDate[0])/\(indianFormatDate[2])"
                //cell.contentLabel.text = invoiceDataObj[indexPath.section - 1].date
            case 1:
                let currentYear = Double(filteredItems[indexPath.section - 1].amount!)!
                let prevYear = Double(total)
                //let temp = ((currentYear - prevYear)/prevYear)*100
                let temp = (currentYear*100)/prevYear
                cell.contentLabel.attributedText = calculatePercentage(currentYear: currentYear, prevYear: prevYear, temp: temp)
            case 2:
                cell.contentLabel.font = UIFont(name: "Roboto-Regular", size: 13)
                cell.contentLabel.text = filteredItems[indexPath.section-1].narration//!.lowercased()
            case 3:
                cell.contentLabel.text = filteredItems[indexPath.section-1].paymentmode
            case 4:
                cell.contentLabel.text = filteredItems[indexPath.section-1].type
            case 5:
                cell.contentLabel.text = filteredItems[indexPath.section-1].vocherno
            case 6:
                let attributedString = NSAttributedString(string: NSLocalizedString("View Invoice", comment: ""), attributes:[
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //If item other than BranchName clicked then open next page...
        if let destination = segue.destination as? viewPDFController,
            let index = CollectionView.indexPathsForSelectedItems?.first{
            if index.section > 0 {
                var urlArray = filteredItems[index.section-1].link!.split{$0 == ","}.map(String.init)
                destination.webvwUrl = urlArray[urlArray.count - 1]
            }
            else{
                return
            }
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        //Block Segue if branchname is clicked...
        if let index = CollectionView.indexPathsForSelectedItems?.first{
            if((index.section) > 0){
                
                if filteredItems[index.section-1].link == ""{
                    var alert = UIAlertView(title: "Alert", message: "No Data Found", delegate: nil, cancelButtonTitle: "OK")
                    alert.show()
                    return false
                }else if index.section == self.filteredItems.count + 1{
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
    
    //API CALL...
    func apiGetInvoice(){
        let json: [String: Any] = ["CIN":UserDefaults.standard.value(forKey: "userCIN") as! String,"Category":UserDefaults.standard.value(forKey: "userCategory") as! String,"ClientSecret":"ClientSecret","ledgerid":ledgerid,"branchid":branchid,"fromdate":fromDate,"todate":toDate,"suppliername":suppliername]
        let manager =  DataManager.shared
        print("Params Sent : \(json)")
        manager.makeAPICall(url: invoiceApiUrl, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            
            do {
                self.invoiceData = try JSONDecoder().decode([InvoiceData].self, from: data!)
                self.invoiceDataObj  = self.invoiceData[0].data
                self.filteredItems  = self.invoiceData[0].data
                self.total = self.invoiceDataObj.reduce(0, { $0 + Double($1.amount!)! })
                self.CollectionView.reloadData()
                self.CollectionView.collectionViewLayout.invalidateLayout()
                self.noDataView.hideView(view: self.noDataView)
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

}
