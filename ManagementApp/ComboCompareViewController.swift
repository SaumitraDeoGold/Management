//
//  ComboCompareViewController.swift
//  DealorsApp
//
//  Created by Goldmedal on 10/26/18.
//  Copyright © 2018 Goldmedal. All rights reserved.
//

import UIKit

class ComboCompareViewController: UIViewController,UICollectionViewDataSource,UICollectionViewDelegate {
    
    var ComboCompareElementMain = [ComboCompareElement]()
    var ComboCompareDataMain = [ComboCompareObj]()
    var ComboCompareArray = [ComboCompareArr]()
    var ComboItemArray = [[ComboCompareArr]]()
    var ComboSectionArray = [String]()
    var ComboItemQty = [String]()
    var ComboItemQtyArr = [[String]]()
    var ComboItemsName = [String]()
    var ComboSectionSplit = [String]()
    var ComboQtyList = [String]()
    var ComboCommonQty = [ComboCompareArr]()
    var comboCompareApi=""
    var strComboSection = String()
    var strCin = String()
    var intComboId = Int()
    let contentCellIdentifier = "\(ContentCollectionViewCell.self)"
    
    @IBOutlet weak var imvClose: UIImageView!
    @IBOutlet weak var lblHeader: UILabel!
    @IBOutlet weak var vwClose: UIView!
    @IBOutlet weak var comboCompareCollectionView: UICollectionView!
    @IBOutlet weak var viewHeight: NSLayoutConstraint!
    
    var customComboCompareLayout = CustomComboCompareLayout()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let initialData =  UserDefaults.standard.value(forKey: "initialData") as? Dictionary ?? [:]
        comboCompareApi = (initialData["baseApi"] as? String ?? "")+""+(initialData["comboCompare"] as? String ?? "")

        lblHeader.text = strComboSection
        
        // Do any additional setup after loading the view.
        if (Utility.isConnectedToNetwork()) {
            print("Internet connection available")
            OperationQueue.main.addOperation {
                self.apiComboCompareApi()
            }
        }
        else{
            print("No internet connection available")
            
            var alert = UIAlertView(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
        }
        
        let tabClose = UITapGestureRecognizer(target: self, action: #selector(self.tapFunction))
        vwClose.addGestureRecognizer(tabClose)
        
        self.comboCompareCollectionView.register(UINib(nibName: "ContentCollectionViewCell", bundle: nil),
                                     forCellWithReuseIdentifier: self.contentCellIdentifier)
       
    }
    
    @objc func tapFunction(sender:UITapGestureRecognizer) {
        print("tap working")
        dismiss(animated: true)
    }
    
    
    func apiComboCompareApi(){
        ViewControllerUtils.sharedInstance.showLoader()
        
        let json: [String: Any] = ["ClientSecret":"1170004","CIN":strCin,"ComboIds":intComboId]
        
        DataManager.shared.makeAPICall(url: comboCompareApi, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            DispatchQueue.main.async {
                do {
                    self.ComboCompareElementMain = try JSONDecoder().decode([ComboCompareElement].self, from: data!)
                    self.ComboCompareDataMain = self.ComboCompareElementMain[0].data
                    self.ComboCompareArray = self.ComboCompareDataMain[0].combocomparedetails
                    
                    if(!(self.ComboCompareDataMain[0].allcombonm ?? "").isEmpty){
                    self.ComboSectionSplit = (self.ComboCompareDataMain[0].allcombonm?.components(separatedBy: ","))!
                    }

                    for part in self.ComboSectionSplit {
                       self.ComboItemsName.append(part)
                    }
                    
                    let groupedDictionary = Dictionary(grouping: self.ComboCompareArray, by: { (combo) -> String in
                        return combo.itemnm!
                    })
                    
                    let keys = groupedDictionary.keys.sorted()
                    
                     self.ComboSectionArray.append(contentsOf: keys)
                    
                    keys.forEach({ (key) in
                        self.ComboItemArray.append(groupedDictionary[key]!)
                    })
              
                    
                    var count = 0
                  
                    for items in self.ComboItemArray{
                        self.ComboItemQty.removeAll()
                        self.ComboQtyList.removeAll()
                        self.ComboCommonQty.removeAll()
                       
                        for index in 0...(items.count-1) {
                            self.ComboCommonQty.append(items[index])
                            self.ComboQtyList.append(items[index].comboname!)
                            count=0
                        }
               
                        for qty in self.ComboItemsName{
                            if(self.ComboQtyList.contains(qty)){
                                self.ComboItemQty.append(self.ComboCommonQty[count].qty ?? "-")
                                count+=1
                            }else{
                                self.ComboItemQty.append("X")
                            }
                        }
                        
                        self.ComboItemQtyArr.append(self.ComboItemQty)
                    }
                   
                    
                } catch let errorData {
                    print(errorData.localizedDescription)
                }
                
                self.comboCompareCollectionView.collectionViewLayout = self.customComboCompareLayout
                
                self.comboCompareCollectionView.delegate = self
                self.comboCompareCollectionView.dataSource = self
                self.customComboCompareLayout.numberOfColumns = (self.ComboItemsName.count+1)
                
                if(self.comboCompareCollectionView != nil)
                {
                    self.comboCompareCollectionView.reloadData()
                     self.viewHeight.constant = CGFloat(((self.ComboSectionArray.count+1)*35)+40)
                }
              
            }
            ViewControllerUtils.sharedInstance.removeLoader()
        }) { (Error) in
            ViewControllerUtils.sharedInstance.removeLoader()
            print(Error?.localizedDescription)
        }
        
    }
    
    
    
    
        func numberOfSections(in collectionView: UICollectionView) -> Int {
            return  self.ComboSectionArray.count + 1
        }
    
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return self.ComboItemsName.count + 1
        }
    
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: contentCellIdentifier,
                                                          for: indexPath) as! ContentCollectionViewCell
    
            if indexPath.section == 0 {
                cell.contentLabel.font = UIFont(name: "Roboto-Medium", size: 16)
            } else {
                cell.contentLabel.font = UIFont(name: "Roboto-Regular", size: 14)
            }
    
            cell.layer.borderWidth = 1
            cell.layer.borderColor = UIColor.lightGray.cgColor
            cell.backgroundColor = UIColor.white
          
    
            if indexPath.section == 0 {
                if(indexPath.item == 0){
                     cell.contentLabel.text = "Product Name"
                }else{
                     cell.contentLabel.text = self.ComboItemsName[indexPath.item-1]
                }
              
            }else{
                 if(indexPath.item == 0){
                    cell.contentLabel.text = self.ComboItemArray[indexPath.section-1][0].itemnm
                 }else{
                    print(indexPath.section,"-- - - - - - -",indexPath.item)
                    cell.contentLabel.text = self.ComboItemQtyArr[indexPath.section-1][indexPath.item-1]
                }
            }
    
    
            return cell
        }
    
 
}

