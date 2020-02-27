//
//  ExcelViewController.swift
//  ManagementApp
//
//  Created by Goldmedal on 26/12/19.
//  Copyright © 2019 Goldmedal. All rights reserved.
//

import UIKit

struct ExcelArray:Codable {
    var counter: Int?
    var data: [ExcelData]
}

struct ExcelData: Codable {
    var crDate, crDescription, deDate, deDescription: String?
    var crAmount, deAmount: Double?
}

class ExcelViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    //Outlets...
    @IBOutlet weak var CollectionView: UICollectionView!
    @IBOutlet weak var addRow: UIButton!
    @IBOutlet weak var printValue: UIButton!
    @IBOutlet weak var textField: UITextField!
    
    //Declarations...
    var cellContentIdentifier = "\(CollectionViewCell.self)"
    var alphabets = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
    var counter = 15
    var excelArray = [ExcelArray]()
    var excelData = [ExcelData]()
    var tempIndex = 0
    var tempRow = 0
    var totalCeAmount = 0.0
    var totalDeAmount = 0.0

    override func viewDidLoad() {
        super.viewDidLoad()
        excelData.append(ExcelData(crDate: "", crDescription: "",deDate:"", deDescription:"",crAmount: 0.0, deAmount:0.0))
        print("Array Count \(excelData.count)")
        //excelData[0].crDate = "whatever"
        //print("Array \(excelData)")
    }
    
    @IBAction func saveExcel(_ sender: UIBarButtonItem) {
        
        
        let fileName = "TestExcel.xls"
        let path = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)
        
        var csvText = "Make,Model,Nickname\nsomething,something2,something3\n\nDate,Mileage,Gallons,Price,Price per gallon,Miles between fillups,MPG\n"
        
        //currentCar.fillups.sortInPlace({ $0.date.compare($1.date) == .OrderedDescending })
        
        let count = 26
        
        if count > 0 {
            
            for fillup in alphabets {
                
                let dateFormatter = DateFormatter()
                //dateFormatter.dateStyle = DateFormatter.Style.ShortStyle
                //let convertedDate = dateFormatter.stringFromDate("fillup.date")
                
                let newLine = "abc,asd,asd,asd,asd,asd,asd\n"
                csvText = csvText + newLine
                //csvText.appendContentsOf(newLine)
            }
            
            do {
                try csvText.write(to: path!, atomically: true, encoding: String.Encoding.utf8)
                
                let vc = UIActivityViewController(activityItems: [path!], applicationActivities: [])
                vc.excludedActivityTypes = [
                    UIActivityType.assignToContact,
                    UIActivityType.saveToCameraRoll,
                    UIActivityType.postToFlickr,
                    UIActivityType.postToVimeo,
                    UIActivityType.postToTencentWeibo,
                    UIActivityType.postToTwitter,
                    UIActivityType.postToFacebook,
                    UIActivityType.openInIBooks
                ]
                present(vc, animated: true, completion: nil)
                
            } catch {
                print("Failed to create file")
                print("\(error)")
            }
            
        } else {
            print("Error Failed to create file")
            //showErrorAlert("Error", msg: "There is no data to export")
        }
        
        //counter += 1
        //        excelData.append(ExcelData(crDate: "", crDescription: "",deDate:"", deDescription:"",crAmount: 0.0, deAmount:0.0))
        //        self.CollectionView.reloadData()
        //        self.CollectionView.collectionViewLayout.invalidateLayout()
    }
    
    @IBAction func addNewColumn(_ sender: UIBarButtonItem) {
        counter += 1
        excelData.append(ExcelData(crDate: "", crDescription: "",deDate:"", deDescription:"",crAmount: 0.0, deAmount:0.0))
        self.CollectionView.reloadData()
        self.CollectionView.collectionViewLayout.invalidateLayout()
    }
    
    @IBAction func printList(_ sender: UIBarButtonItem) {
        switch tempRow{
         
        case 1:
            excelData[tempIndex].crDate = textField.text
        case 2:
            excelData[tempIndex].crDescription = textField.text
        case 3:
            excelData[tempIndex].crAmount = Double(textField.text!)
        case 4:
            excelData[tempIndex].deDate = textField.text
        case 5:
            excelData[tempIndex].deDescription = textField.text
        case 6:
            excelData[tempIndex].deAmount = Double(textField.text!)
            
        default:
            //cell.contentLabel.text = ""
            break
        }
        //print("Array \(excelData)")
        totalCeAmount = self.excelData.reduce(0, { $0 + ($1.crAmount)! })
        totalDeAmount = self.excelData.reduce(0, { $0 + ($1.deAmount)! })
        textField.text = ""
        self.CollectionView.reloadData()
        self.CollectionView.collectionViewLayout.invalidateLayout()
        textField.resignFirstResponder()
    }
    
    //Collection View......
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return excelData.count+2
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
                cell.contentLabel.text = "Ref No."
            case 1:
                cell.contentLabel.text = "Cr Date"
            case 2:
                cell.contentLabel.text = "Cr Description"
            case 3:
                cell.contentLabel.text = "Cr Amount"
            case 4:
                cell.contentLabel.text = "De Date"
            case 5:
                cell.contentLabel.text = "De Description"
            case 6:
                cell.contentLabel.text = "De Amount"
                
            default:
                cell.contentLabel.text = ""
                break
            }
            
            //cell.backgroundColor = UIColor.lightGray
        }else if indexPath.section == excelData.count + 1{
            cell.contentLabel.font = UIFont(name: "Roboto-Medium", size: 16)
            if #available(iOS 11.0, *) {
                cell.backgroundColor = UIColor.init(named: "Primary")
            } else {
                cell.backgroundColor = UIColor.gray
            }
            switch indexPath.row{
            case 0:
                cell.contentLabel.text = "TOTAL"
            case 1:
                cell.contentLabel.text = "Cr Date"
            case 2:
                cell.contentLabel.text = "Cr Description"
            case 3:
                cell.contentLabel.text = Utility.formatRupee(amount: Double(totalCeAmount ))
            case 4:
                cell.contentLabel.text = "De Date"
            case 5:
                cell.contentLabel.text = "De Description"
            case 6:
                cell.contentLabel.text = Utility.formatRupee(amount: Double(totalDeAmount ))
                
            default:
                cell.contentLabel.text = ""
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
                cell.contentLabel.text = String(indexPath.section)
            case 1:
                cell.contentLabel.text = excelData[indexPath.section-1].crDate
            case 2:
                cell.contentLabel.text = excelData[indexPath.section-1].crDescription
            case 3:
                cell.contentLabel.text = Utility.formatRupee(amount: Double(excelData[indexPath.section-1].crAmount! ))
            case 4:
                cell.contentLabel.text = excelData[indexPath.section-1].deDate
            case 5:
                cell.contentLabel.text = excelData[indexPath.section-1].deDescription
            case 6:
                    cell.contentLabel.text = Utility.formatRupee(amount: Double(excelData[indexPath.section-1].deAmount! ))
             
            default:
                cell.contentLabel.text = ""
                break
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("ROW \(indexPath.row) Section \(indexPath.section)")
         tempIndex = indexPath.section - 1
         tempRow = indexPath.row
         textField.becomeFirstResponder()
    }
    

}
