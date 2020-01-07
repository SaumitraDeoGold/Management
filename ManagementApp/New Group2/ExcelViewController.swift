//
//  ExcelViewController.swift
//  ManagementApp
//
//  Created by Goldmedal on 25/12/19.
//  Copyright © 2019 Goldmedal. All rights reserved.
//

import UIKit

class ExcelViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    //Outlets...
    @IBOutlet weak var CollectionView: UICollectionView!
    @IBOutlet weak var noDataView: NoDataView!
    
    //Declarations...
    var alphabets = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
    var cellContentIdentifier = "\(CollectionViewCell.self)"

    override func viewDidLoad() {
        super.viewDidLoad()
 
    }
    
    //Collection View......
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 15
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 26
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
            
            cell.contentLabel.text = alphabets[indexPath.section - 1]
            
//            switch indexPath.row{
//            case 0:
//                cell.contentLabel.text = "Supplier Name"
//            case 1:
//                cell.contentLabel.text = "Amount"
//            case 2:
//                cell.contentLabel.text = "Details"
//
//            default:
//                break
//            }
            //cell.backgroundColor = UIColor.lightGray
        } else {
            cell.contentLabel.font = UIFont(name: "Roboto-Regular", size: 14)
            if #available(iOS 11.0, *) {
                cell.backgroundColor = UIColor.white
            } else {
                cell.backgroundColor = UIColor.white
            }
            cell.contentLabel.text = ""
//            switch indexPath.row{
//            case 0:
//                cell.contentLabel.text = ""
//            case 1:
//                let currentYear = Double(supplierDataObj[indexPath.section - 1].amount!)!
//                let prevYear = Double(total)
//                //let temp = ((currentYear - prevYear)/prevYear)*100
//                let temp = (currentYear*100)/prevYear
//                cell.contentLabel.attributedText = calculatePercentage(currentYear: currentYear, prevYear: prevYear, temp: temp)
//                //                if let amount = partwiseCompObj[indexPath.section - 1].amount
//                //                {
//                //                    cell.contentLabel.text = Utility.formatRupee(amount: Double(amount )!)
//            //                }
//            case 2:
//                let attributedString = NSAttributedString(string: NSLocalizedString("View Ledger", comment: ""), attributes:[
//                    NSAttributedString.Key.foregroundColor : UIColor(named: "ColorBlue") as Any,
//                    NSAttributedString.Key.underlineStyle:1.0
//                    ])
//                cell.contentLabel.attributedText = attributedString
//            default:
//                break
//            }
            //cell.backgroundColor = UIColor.groupTableViewBackground
        }
        return cell
    }
    
}
