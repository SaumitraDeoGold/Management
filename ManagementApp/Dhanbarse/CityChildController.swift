//
//  CityChildController.swift
//  ManagementApp
//
//  Created by Goldmedal on 22/06/20.
//  Copyright © 2020 Goldmedal. All rights reserved.
//

import UIKit

class CityChildController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    //Outlets...
    @IBOutlet weak var CollectionView: UICollectionView!
    @IBOutlet weak var textField: UITextField!
    
    //Declarations...
    var cellContentIdentifier = "\(CollectionViewCell.self)"
    var cityChild = [DhanCityProfile]()
    var cityChildObj = [DhanCityProfileObj]()
    var filteredItems = [DhanCityProfileObj]()
    var tempArray = [DhanCityProfileObj]()
    var dataToRecieve = [DhanCitywiseObj]()
    var fromdate = ""
    var todate = ""
    var districtId = 0
    var cat = ""
    var approveStatus = ""
    var districtName = ""
    var catSelected = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ViewControllerUtils.sharedInstance.showLoader()
        if cat == "8"{
            catSelected = "Electrician"
        }else if cat == "11"{
            catSelected = "Retailer"
        }else{
            catSelected = "CounterBoy"
        }
        if districtName == ""{
            self.title = "\(dataToRecieve[0].city!) -> \(approveStatus) -> \(catSelected)"
            apiGetCitywise()
        }else{
            self.title = "\(districtName) -> \(approveStatus) -> \(catSelected)"
            apiGetDistwise()
        }
        
 
    }
    
    func getIdiotsDateFormat(value: String) -> String{
        let inFormatDate = value.split{$0 == "/"}.map(String.init)
        let temp = "\(inFormatDate[2])-\(inFormatDate[1])-\(inFormatDate[0])"
        return temp
    }
    
    func dialNumber(number : String) {
        
        if let url = URL(string: "tel://\(number)"),
            UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url, options: [:], completionHandler:nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        } else {
            // add error message here
        }
    }
    
    //CollectionView Functions......
    func numberOfSections(in collectionView: UICollectionView) -> Int {
            return filteredItems.count + 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
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
                    cell.contentLabel.text = "Name"
                case 1:
                    cell.contentLabel.text = "Category"
                case 2:
                    cell.contentLabel.text = "Join Date"
                case 3:
                    cell.contentLabel.text = "City"
                case 4:
                    cell.contentLabel.text = "State"
                case 5:
                    cell.contentLabel.text = "District"
                case 6:
                    cell.contentLabel.text = "Shop Name"
                case 7:
                    cell.contentLabel.text = "Address"
                case 8:
                    cell.contentLabel.text = "Email"
                case 9:
                    cell.contentLabel.text = "Mobile"
                    
                default:
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
                    cell.contentLabel.text = filteredItems[indexPath.section-1].name
                case 1:
                    cell.contentLabel.text = filteredItems[indexPath.section-1].category
                case 2:
                    cell.contentLabel.text = filteredItems[indexPath.section-1].joinDate
                case 3:
                    cell.contentLabel.text = filteredItems[indexPath.section-1].city
                case 4:
                    cell.contentLabel.text = filteredItems[indexPath.section-1].state
                case 5:
                    cell.contentLabel.text = filteredItems[indexPath.section-1].district
                case 6:
                    cell.contentLabel.text = filteredItems[indexPath.section-1].shopName
                case 7:
                    cell.contentLabel.text = filteredItems[indexPath.section-1].address
                case 8:
                    cell.contentLabel.text = filteredItems[indexPath.section-1].email
                case 9:
                    cell.contentLabel.text = filteredItems[indexPath.section-1].mobileNo
                default:
                    break
                }
                //cell.backgroundColor = UIColor.groupTableViewBackground
            }
            return cell
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == 9{
            dialNumber(number: filteredItems[indexPath.section-1].mobileNo!)
        }else if indexPath.row == 8{
            sendMail(email: filteredItems[indexPath.section-1].email!)
        }else if indexPath.section != 0 && indexPath.section != filteredItems.count + 1{
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let destViewController = storyboard.instantiateViewController(withIdentifier: "DhanProfileViewController") as! DhanProfileViewController
            destViewController.mobile = filteredItems[indexPath.section-1].mobileNo!
            let _ : UIViewController = self.navigationController!.topViewController!
            self.navigationController!.pushViewController(destViewController, animated: true)
        }
        
    }
    
    func sendMail(email : String){
        if let url = URL(string: "mailto:\(email)") {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
     
    
    //Auto-Complete Function...
    @objc func searchRecords(_ textfield: UITextField){
            self.filteredItems.removeAll()
            if textfield.text?.count != 0{
                for dealers in tempArray{
                    let range = dealers.name!.lowercased().range(of: textfield.text!, options: .caseInsensitive, range: nil, locale: nil)
                    if range != nil{
                        filteredItems.append(dealers)
                    }
                }
            }else{
                for dealers in tempArray{
                    filteredItems.append(dealers)
                }
            }
        CollectionView.reloadData()
    }
    
    func apiGetCitywise(){
        
        let json: [String: Any] = ["CIN":UserDefaults.standard.value(forKey: "userCIN") as! String,"Category":UserDefaults.standard.value(forKey: "userCategory") as! String,"ClientSecret":"ClientSecret","Cat":cat,"CityName":dataToRecieve[0].city!,"Fromdate":fromdate,"Todate":todate,"ApproveStatus":approveStatus,"Districtid":districtId]
        print("apiGetCitywise DETAILS : \(json)")
        let manager =  DataManager.shared
        
        manager.makeAPICall(url: "https://test2.goldmedalindia.in/api/getuseraprstatuscitywisedetails", params: json, method: .POST, success: { (response) in
            let data = response as? Data
            
            do {
                self.cityChild = try JSONDecoder().decode([DhanCityProfile].self, from: data!)
                self.cityChildObj = self.cityChild[0].data
                self.filteredItems = self.cityChild[0].data
                self.tempArray = self.cityChild[0].data
                self.textField.addTarget(self, action: #selector(self.searchRecords(_ :)), for: .editingChanged)
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
    
    func apiGetDistwise(){
        
        let json: [String: Any] = ["CIN":UserDefaults.standard.value(forKey: "userCIN") as! String,"Category":UserDefaults.standard.value(forKey: "userCategory") as! String,"ClientSecret":"ClientSecret","Cat":cat,"Districtname":districtName,"Fromdate":"2019-03-01","ToDate":"2020-04-01","ApproveStatus":approveStatus]
        print("apiGetDistwise DETAILS : \(json)")
        let manager =  DataManager.shared
        
        manager.makeAPICall(url: "https://test2.goldmedalindia.in/api/getUserapprovalstatusanddistrictwisedetails", params: json, method: .POST, success: { (response) in
            let data = response as? Data
            
            do {
                self.cityChild = try JSONDecoder().decode([DhanCityProfile].self, from: data!)
                self.cityChildObj = self.cityChild[0].data
                self.filteredItems = self.cityChild[0].data
                self.tempArray = self.cityChild[0].data
                self.textField.addTarget(self, action: #selector(self.searchRecords(_ :)), for: .editingChanged)
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
