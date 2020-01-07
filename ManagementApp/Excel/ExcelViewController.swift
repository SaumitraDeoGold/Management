//
//  ExcelViewController.swift
//  ManagementApp
//
//  Created by Goldmedal on 26/12/19.
//  Copyright © 2019 Goldmedal. All rights reserved.
//

import UIKit

class ExcelViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    //Outlets...
    @IBOutlet weak var CollectionView: UICollectionView!
    //@IBOutlet weak var noDataView: NoDataView!
    
    //Declarations...
    var cellContentIdentifier = "\(CollectionViewCell.self)"
    var alphabets = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]

    override func viewDidLoad() {
        super.viewDidLoad()
        //self.noDataView.hideView(view: self.noDataView)
        // Do any additional setup after loading the view.
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
            switch indexPath.row{
            case indexPath.row:
                cell.contentLabel.text = alphabets[indexPath.row]
                
            default:
                cell.contentLabel.text = ""
                break
            }
            
            //cell.backgroundColor = UIColor.lightGray
        } else {
            cell.contentLabel.font = UIFont(name: "Roboto-Regular", size: 14)
            if #available(iOS 11.0, *) {
                cell.backgroundColor = UIColor.init(named: "primaryLight")
            } else {
                cell.backgroundColor = UIColor.lightGray
            }
            switch indexPath.row{
            case 0:
                cell.contentLabel.text = String(indexPath.section)
             
            default:
                cell.contentLabel.text = ""
                break
            }
            
            //cell.backgroundColor = UIColor.groupTableViewBackground
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("ROW \(indexPath.row) Section \(indexPath.section)")
    }
    

}
