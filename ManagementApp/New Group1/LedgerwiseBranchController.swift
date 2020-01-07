//
//  LedgerwiseBranchController.swift
//  ManagementApp
//
//  Created by Goldmedal on 07/12/19.
//  Copyright © 2019 Goldmedal. All rights reserved.
//

import UIKit

class LedgerwiseBranchController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, PopupDateDelegate {
    
    //Outlets...
    @IBOutlet weak var CollectionView: UICollectionView!
    @IBOutlet weak var noDataView: NoDataView!
    @IBOutlet weak var backButton: UIImageView!
    @IBOutlet weak var sort: UIImageView!
    @IBOutlet weak var header: UILabel!
    
    //Declarations...
    var branchComparisonUrl = ""
    var branchCompare = [LedgerwiseBranch]()
    var branchCompareObj = [LedgerwiseBranchObj]()
    var filteredItems = [LedgerwiseBranchObj]()
    var dataToRecieve = [LedgerwiseObj]()
    var cellContentIdentifier = "\(CollectionViewCell.self)"
    var total = 0.0
    var dateTo = ""
    var dateFrom = ""
    let qrtrlyArrayStart = Utility.quarterlyStartDate()
    let qrtrlyArrayEnd = Utility.quarterlyEndDate()
    let monthEnds = Utility.getMonthEndDate()
    let months = Utility.getMonths()

    override func viewDidLoad() {
        super.viewDidLoad()
        branchComparisonUrl = "https://test2.goldmedalindia.in/api/getManagementLedgerwiseBranchExpense"
        header.text = "Branchwise -> \(dataToRecieve[0].headnm!)"
        ViewControllerUtils.sharedInstance.showLoader()
        self.noDataView.hideView(view: self.noDataView)
        apiGetBranchwise()
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
            self.filteredItems = self.branchCompareObj.sorted{($0.branchnm)!.localizedCaseInsensitiveCompare($1.branchnm!) == .orderedAscending}
        case 1:
            self.filteredItems = self.branchCompareObj.sorted{($0.branchnm)!.localizedCaseInsensitiveCompare($1.branchnm!) == .orderedDescending}
        case 2:
            self.filteredItems = self.branchCompareObj.sorted(by: {Double($0.amount!)! < Double($1.amount!)!})
        case 3:
            self.filteredItems = self.branchCompareObj.sorted(by: {Double($0.amount!)! > Double($1.amount!)!})
        default:
            break
        }
        
        self.CollectionView.reloadData()
        self.CollectionView.collectionViewLayout.invalidateLayout()
    }
    
    //CollectionView Functions...
    func numberOfSections(in collectionView: UICollectionView) -> Int {
            return filteredItems.count + 2
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
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
                    cell.contentLabel.text = "Branch Name"
                case 1:
                    cell.contentLabel.text = "Amount"
                    cell.contentLabel.textColor = UIColor.black
                default:
                    break
                }
                cell.backgroundColor = UIColor.lightGray
            }else if indexPath.section == filteredItems.count + 1{
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
                    cell.contentLabel.text = (filteredItems[indexPath.section - 1].branchnm)!.uppercased()
                case 1:
//                    if let otherespenses = filteredItems[indexPath.section - 1].amount
//                    {
//                        cell.contentLabel.text = Utility.formatRupee(amount: Double(otherespenses )!)
//                    }
                    let currentYear = Double(filteredItems[indexPath.section - 1].amount!)!
                    let prevYear = Double(total)
                    //let temp = ((currentYear - prevYear)/prevYear)*100
                    let temp = (currentYear*100)/prevYear
                    cell.contentLabel.attributedText = calculatePercentage(currentYear: currentYear, prevYear: prevYear, temp: temp)
                default:
                    break
                }
                //cell.backgroundColor = UIColor.groupTableViewBackground
            }
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //If item other than BranchName clicked then open next page...
        if let destination = segue.destination as? SupplierViewController,
            let index = CollectionView.indexPathsForSelectedItems?.first{
            if index.section > 0 {
                destination.dataToRecieve = [filteredItems[index.section-1]]
                destination.ledgerid = dataToRecieve[0].ledgerid!
                destination.fromDate = dateFrom
                destination.toDate = dateTo
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
    
    
    //API CALL...
    func apiGetBranchwise(){
        let json: [String: Any] = ["fromdate":dateFrom,"todate":dateTo,"ClientSecret":"ClientSecret","CIN":UserDefaults.standard.value(forKey: "userCIN") as! String,"Category":UserDefaults.standard.value(forKey: "userCategory") as! String,"ledgerid":dataToRecieve[0].ledgerid!]
        let manager =  DataManager.shared
        print("Params Sent : \(json)")
        manager.makeAPICall(url: branchComparisonUrl, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            
            do {
                self.branchCompare = try JSONDecoder().decode([LedgerwiseBranch].self, from: data!)
                self.branchCompareObj  = self.branchCompare[0].data
                self.filteredItems = self.branchCompare[0].data
                self.total = self.branchCompareObj.reduce(0, { $0 + Double($1.amount!)! })
                self.CollectionView.reloadData()
                self.CollectionView.collectionViewLayout.invalidateLayout()
                ViewControllerUtils.sharedInstance.removeLoader()
                self.noDataView.hideView(view: self.noDataView)
            } catch let errorData {
                print(errorData.localizedDescription)
                ViewControllerUtils.sharedInstance.removeLoader()
                self.noDataView.showView(view: self.noDataView, from: "NDA")
            }
        }) { (Error) in
            print(Error?.localizedDescription as Any)
            ViewControllerUtils.sharedInstance.removeLoader()
            self.noDataView.showView(view: self.noDataView, from: "NDA")
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
