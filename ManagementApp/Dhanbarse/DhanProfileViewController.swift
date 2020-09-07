//
//  DhanProfileViewController.swift
//  ManagementApp
//
//  Created by Goldmedal on 05/04/20.
//  Copyright © 2020 Goldmedal. All rights reserved.
//

import UIKit

class DhanProfileViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    //Outlets...
    @IBOutlet weak var CollectionView: UICollectionView!
    @IBOutlet weak var coverImageView: UIImageView!
    
    //Declarations...
    var dataToRecieve = [SearchDhanProfileObj]()
    var cellContentIdentifier = "\(StockCell.self)"
    var dhanPro = [SearchDhanProfile]()
    var dhanProObj = [SearchDhanProfileObj]()
    var mobile = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        if dataToRecieve.count == 0{
           apiGetProfile()
        }else{
          loadImg()
        }
        
    }
    
    //LoadImage...
    func loadImg(){
        if let url = URL(string: dataToRecieve[0].profilephoto!) {
            do {
                let data: Data = try Data(contentsOf: url)
                coverImageView.image = UIImage(data: data)
            } catch {
                print("Error Loading Img \(error)")
            }
        }
    }
    
    //CollectionView Functions......
    func numberOfSections(in collectionView: UICollectionView) -> Int {
         return 21
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = CollectionView.dequeueReusableCell(withReuseIdentifier: cellContentIdentifier,
                                                      for: indexPath) as! StockCell
        //cell.layer.borderWidth = 3
        //cell.layer.borderColor = UIColor.white.cgColor
        cell.layer.masksToBounds = false
        cell.layer.shadowOffset = CGSize(width: 0, height: 1)
        cell.layer.shadowRadius = 2
        cell.layer.shadowOpacity = 1
        cell.layer.shadowColor = UIColor.black.cgColor
        if dataToRecieve.count > 0{
            if indexPath.section == 0 {
                 
                switch indexPath.row{
                case 0:
                    cell.contentLabel.text = "First Name"
                case 1:
                    cell.contentLabel.font = UIFont(name: "Roboto-Medium", size: 16)
                    cell.contentLabel.text = "\(dataToRecieve[0].userName!) [\(dataToRecieve[0].categorynm!)]"
                    
                default:
                    break
                }
                //cell.backgroundColor = UIColor.lightGray
            } else {
                cell.contentLabel.font = UIFont(name: "Roboto-Regular", size: 14)
//                if #available(iOS 11.0, *) {
//                    //cell.backgroundColor = UIColor.init(named: "primaryLight")
//                } else {
//                    //cell.backgroundColor = UIColor.lightGray
//                }
                switch indexPath.row{
                case 0:
                    switch indexPath.section{
                    case 1:
                        cell.contentLabel.text = "Last Name"
                    case 2:
                        cell.contentLabel.text = "Mobile No"
                    case 3:
                        cell.contentLabel.text = "Date of Birth"
                    case 4:
                        cell.contentLabel.text = "Sex"
                    case 5:
                        cell.contentLabel.text = "Ref Code"
                    case 6:
                        cell.contentLabel.text = "Email"
                    case 7:
                        cell.contentLabel.text = "City Name"
                    case 8:
                        cell.contentLabel.text = "State Name"
                    case 9:
                        cell.contentLabel.text = "District Name"
                    case 10:
                        cell.contentLabel.text = "Home Address"
                    case 11:
                        cell.contentLabel.text = "PinCode"
                    case 12:
                        cell.contentLabel.text = "Shop Name"
                    case 13:
                        cell.contentLabel.text = "GST No"
                    case 14:
                        cell.contentLabel.text = "Document Photo"
                    case 15:
                        cell.contentLabel.text = "Shop Photo"
                    case 16:
                        cell.contentLabel.text = "Work City"
                    case 17:
                        cell.contentLabel.text = "Work State"
                    case 18:
                        cell.contentLabel.text = "Work District"
                    case 19:
                        cell.contentLabel.text = "Work Pin"
                    case 20:
                        cell.contentLabel.text = "CIN"
                    default:
                        break
                    }
                    
                case 1:
                    cell.contentLabel.font = UIFont(name: "Roboto-Medium", size: 16)
                    switch indexPath.section{
                    case 1:
                        cell.contentLabel.text = dataToRecieve[0].userSurname
                    case 2:
                        cell.contentLabel.text = dataToRecieve[0].mobileNo
                    case 3:
                        cell.contentLabel.text = dataToRecieve[0].dateOfBirth
                    case 4:
                        cell.contentLabel.text = dataToRecieve[0].sex
                    case 5:
                        cell.contentLabel.text = dataToRecieve[0].refCode
                    case 6:
                        cell.contentLabel.text = dataToRecieve[0].email
                    case 7:
                        cell.contentLabel.text = dataToRecieve[0].citynm
                    case 8:
                        cell.contentLabel.text = dataToRecieve[0].statenm
                    case 9:
                        cell.contentLabel.text = dataToRecieve[0].distrctnm
                    case 10:
                        cell.contentLabel.text = dataToRecieve[0].hmaddress
                    case 11:
                        cell.contentLabel.text = dataToRecieve[0].hmpincode
                    case 12:
                        cell.contentLabel.text = dataToRecieve[0].shopName
                    case 13:
                        cell.contentLabel.text = dataToRecieve[0].gstNo
                    case 14:
                        cell.contentLabel.text = "View Image"//dataToRecieve[0].documentimglink1
                    case 15:
                        cell.contentLabel.text = "View Image"//dataToRecieve[0].shopEstCerti
                    case 16:
                        cell.contentLabel.text = dataToRecieve[0].wrkcitynm
                    case 17:
                        cell.contentLabel.text = dataToRecieve[0].wrkstatenm
                    case 18:
                        cell.contentLabel.text = dataToRecieve[0].wrkdistrictnm
                    case 19:
                        cell.contentLabel.text = dataToRecieve[0].wrkpincode
                    case 20:
                        cell.contentLabel.text = dataToRecieve[0].cin
                    default:
                        break
                    }
                    
                default:
                    break
                }
                //cell.backgroundColor = UIColor.groupTableViewBackground
            }
        
    }
            return cell
            
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == 1 && indexPath.section == 2{
            dialNumber(number: dataToRecieve[0].mobileNo!)
        }else if indexPath.row == 1 && indexPath.section == 14{
            let sb = UIStoryboard(name: "ViewImage", bundle: nil)
            let popup = sb.instantiateInitialViewController()! as! ImageViewController
            popup.modalPresentationStyle = .overFullScreen
            popup.img = dataToRecieve[0].documentimglink1!
            self.present(popup, animated: true)
        }else if indexPath.row == 1 && indexPath.section == 15{
            let sb = UIStoryboard(name: "ViewImage", bundle: nil)
            let popup = sb.instantiateInitialViewController()! as! ImageViewController
            popup.modalPresentationStyle = .overFullScreen
            popup.img = dataToRecieve[0].shopPhoto!
            self.present(popup, animated: true)
        }
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
    
    //API Function...
    func apiGetProfile(){
        let json: [String: Any] = ["Cin":UserDefaults.standard.value(forKey: "userCIN") as! String,"Cat":UserDefaults.standard.value(forKey: "userCategory") as! String,"ClientSecret":"ClientSecret","Mobile":mobile]
        let manager =  DataManager.shared
        print("vendorArray Params \(json)")
        manager.makeAPICall(url: "https://test2.goldmedalindia.in/api/getcustomerdetailbymob", params: json, method: .POST, success: { (response) in
            let data = response as? Data
            
            do {
                self.dhanPro = try JSONDecoder().decode([SearchDhanProfile].self, from: data!)
                self.dhanProObj  = self.dhanPro[0].data
                self.dataToRecieve  = self.dhanPro[0].data
                print("empSearchObj Result \(self.dhanPro[0].data)")
                self.CollectionView.reloadData()
                self.CollectionView.collectionViewLayout.invalidateLayout()
                self.loadImg()
                ViewControllerUtils.sharedInstance.removeLoader()
                
            } catch let errorData {
                print("Caught Error ------>\(errorData.localizedDescription)")
                ViewControllerUtils.sharedInstance.removeLoader()
            }
        }) { (Error) in
            print("Error -------> \(Error?.localizedDescription as Any)")
            ViewControllerUtils.sharedInstance.removeLoader()
             
         
        }
        
    }
    

}
