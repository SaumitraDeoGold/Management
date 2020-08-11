//
//  CategoryWiseOrderController.swift
//  ManagementApp
//
//  Created by Goldmedal on 21/07/20.
//  Copyright © 2020 Goldmedal. All rights reserved.
//

import UIKit

class CategoryWiseOrderController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, PopupDateDelegate {

    //Outlets...
    @IBOutlet weak var lblPartyName: UIButton!
    @IBOutlet weak var txtAmount: UITextField!
    @IBOutlet weak var noDataView: NoDataView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var lblHeader: UILabel!
    
    //Declarations...
    var categorywiseComp = [MainOrderCatwise]()
    var categorywiseCompObj = [MainOrderCatwiseObj]()
    var filteredItems = [MainOrderCatwiseObj]()
    var cellContentIdentifier = "\(CollectionViewCell.self)"
    var categoryApiUrl = ""
    var branchCode = ""
    var poType = ""
    var total = 0.0
    var index = 0
    var divCode = "1"
    var branchName = ""
    var divName = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.noDataView.hideView(view: self.noDataView)
        self.title = "Categorywise"
        if poType == "0"{
            lblHeader.text = "\(branchName) -> Transfer Pending Order"
        }else{
            lblHeader.text = "\(branchName) -> Sales Pending Order"
        }
        categoryApiUrl = "https://test2.goldmedalindia.in/api/getcatwisependingamount"
        ViewControllerUtils.sharedInstance.showLoader()
        apiCompare()
        self.lblPartyName.setTitle("  \(divName.uppercased())", for: .normal)
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
    
    //Popup Func...
    func showParty(value: String,cin: String) {
        lblPartyName.setTitle("  \(value)", for: .normal)
        divCode = cin
        ViewControllerUtils.sharedInstance.showLoader()
        apiCompare()
    }
    
    //APIFUNC...
    func apiCompare(){
        let json: [String: Any] = ["ClientSecret":"ClientSecret","CIN":UserDefaults.standard.value(forKey: "userCIN") as! String,"Category":UserDefaults.standard.value(forKey: "userCategory") as! String,"BranchId":branchCode,"potype":poType,"DivisionId":divCode]
        let manager =  DataManager.shared
        print("Params Sent : \(json)")
        manager.makeAPICall(url: categoryApiUrl, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            
            do {
                //self.dashDivObj.removeAll()
                self.categorywiseComp = try JSONDecoder().decode([MainOrderCatwise].self, from: data!)
                self.categorywiseCompObj  = self.categorywiseComp[0].data
                self.filteredItems = self.categorywiseComp[0].data
                //Total of All Items...
                self.total = self.filteredItems.reduce(0, { $0 + Double($1.amount!)! })
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
    
    //Collectionview...
        func numberOfSections(in collectionView: UICollectionView) -> Int {
            return filteredItems.count + 2
        }
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return 2
        }
         
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellContentIdentifier,
                                                      for: indexPath) as! CollectionViewCell
        cell.layer.borderWidth = 1
        cell.layer.borderColor = UIColor.white.cgColor
        if filteredItems.count > 0{
            if indexPath.section == 0 {
                cell.contentLabel.font = UIFont(name: "Roboto-Medium", size: 14)
                if #available(iOS 11.0, *) {
                    cell.backgroundColor = UIColor.init(named: "Primary")
                } else {
                    cell.backgroundColor = UIColor.gray
                }
                switch indexPath.row{
                case 0:
                    cell.contentLabel.text = "Category"
                case 1:
                    cell.contentLabel.text = "Amount"
//                case 2:
//                    cell.contentLabel.text = "Previous Year Sale"
                default:
                    break
                }
                
            } else if indexPath.section == filteredItems.count + 1{
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
                    cell.contentLabel.text = Utility.formatRupee(amount: (total ))
//                case 2:
//                    cell.contentLabel.text = Utility.formatRupee(amount: (total["prevYs"]! ))
                    
                default:
                    break
                }
            }  else {
                cell.contentLabel.font = UIFont(name: "Roboto-Regular", size: 14)
                if #available(iOS 11.0, *) {
                    cell.backgroundColor = UIColor.init(named: "primaryLight")
                } else {
                    cell.backgroundColor = UIColor.lightGray
                }
                switch indexPath.row{
                case 0:
                    cell.contentLabel.text = filteredItems[indexPath.section - 1].category
                case 1:
                    let currentYear = Double(filteredItems[indexPath.section - 1].amount!)!
                    let prevYear = Double(total)
                    let temp = (currentYear*100)/prevYear
                    cell.contentLabel.attributedText = calculatePercentage(currentYear: currentYear, prevYear: prevYear, temp: temp)
//                case 2:
//                    if let lastwiringdevices = filteredItems[indexPath.section - 1].lastyearssaleamt
//                    {
//                        cell.contentLabel.text = Utility.formatRupee(amount: Double(lastwiringdevices )!)
//                    }
                    
                default:
                    break
                }
                
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
              if indexPath.section != 0 && indexPath.section != filteredItems.count + 1 {
                index = (indexPath.section-1)
                performSegue(withIdentifier: "segueOrderItemwise", sender: self)
            }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "segueOrderItemwise") {
            if let destination = segue.destination as? ItemwiseOrderController{
                destination.branchId = branchCode
                destination.branchName = branchName
                destination.poType = poType
                destination.catId = filteredItems[index].categoryId!
                destination.category = filteredItems[index].category!
            }else{
                
            }
        }
        
    }

}
