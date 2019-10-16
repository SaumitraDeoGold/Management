//
//  ComboReviewViewController.swift
//  DealorsApp
//
//  Created by Goldmedal on 11/5/18.
//  Copyright © 2018 Goldmedal. All rights reserved.
//

import UIKit
import FirebaseAnalytics

class ComboReviewViewController: UIViewController , UITableViewDelegate , UITableViewDataSource{
    
    @IBOutlet weak var lblComboTotal: UILabel!
    @IBOutlet weak var imvBack: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noDataView: NoDataView!
    
    var ComboReviewElementMain = [ComboReviewElement]()
    var ComboReviewData = [ComboReviewObj]()
    var ComboReviewArr = [ComboTotalQtyDetail]()
    
    var ComboSplit = [String]()
    var totalQty = "-"
    
    var ComboReviewApi = ""
    var strCin = ""
    var strComboId = ""
    var strComboQty = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.noDataView.hideView(view: self.noDataView)
        
        let initialData =  UserDefaults.standard.value(forKey: "initialData") as? Dictionary ?? [:]
        ComboReviewApi = (initialData["baseApi"] as? String ?? "")+""+(initialData["comboTotalQuantit"] as? String ?? "")
        
        // Do any additional setup after loading the view.
        if (Utility.isConnectedToNetwork()) {
            print("Internet connection available")
            self.apiComboReviewList()
            self.noDataView.hideView(view: self.noDataView)
        }
        else{
            print("No internet connection available")
            
            var alert = UIAlertView(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
            self.noDataView.showView(view: self.noDataView, from: "NET")
        }
        
        
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        
        Analytics.setScreenName("VIEW COMBO REVIEW SCREEN", screenClass: "ComboReviewViewController")
        
        let tabBack = UITapGestureRecognizer(target: self, action: #selector(self.tapFunction))
        imvBack.addGestureRecognizer(tabBack)
    }
    
    @objc func tapFunction(sender:UITapGestureRecognizer) {
        print("back")
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func apiComboReviewList(){
        ViewControllerUtils.sharedInstance.showLoader()
        
        let json: [String: Any] = ["ClientSecret":"2017-2018","CIN":strCin,"ComboId":strComboId,"ComboQty":strComboQty]
        
        DataManager.shared.makeAPICall(url: ComboReviewApi, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            
            DispatchQueue.main.async {
                do {
                    self.ComboReviewElementMain = try JSONDecoder().decode([ComboReviewElement].self, from: data!)
                    self.ComboReviewData = self.ComboReviewElementMain[0].data
                    self.ComboReviewArr.append(contentsOf:self.ComboReviewData[0].comboTotalQtyDetails)
                    
                    self.totalQty = self.ComboReviewData[0].totalqty ?? "-"
                    self.lblComboTotal.text = self.totalQty
                   
                } catch let errorData {
                    print(errorData.localizedDescription)
                }
                
                if(self.tableView != nil)
                {
                    self.tableView.reloadData()
                }
                
                if(self.ComboReviewArr.count>0){
                    self.noDataView.hideView(view: self.noDataView)
                }else{
                    self.noDataView.showView(view: self.noDataView, from: "NDA")
                }
                ViewControllerUtils.sharedInstance.removeLoader()
            }
        }) { (Error) in
            ViewControllerUtils.sharedInstance.removeLoader()
            print(Error?.localizedDescription)
            self.noDataView.showView(view: self.noDataView, from: "ERR")
        }
        
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ComboReviewArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ComboReviewCell", for: indexPath) as! ComboReviewCell
        
        if(!(self.ComboReviewArr[indexPath.row].itemname ?? "").isEmpty){
            self.ComboSplit = (self.ComboReviewArr[indexPath.row].itemname?.components(separatedBy: " - "))!
        }else{
            self.ComboSplit = ["-","-"]
        }
        
        cell.lblComboItemNo.text = ComboSplit[0]
        cell.lblComboItemName.text = ComboSplit[1].capitalized
        cell.lblComboRange.text = ComboReviewArr[indexPath.row].range ?? "-"
        cell.lblComboQty.text = ComboReviewArr[indexPath.row].qty ?? "-"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    
    
    @IBAction  func clicked_viewOrder(sender: UIButton){
        self.dismiss(animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
