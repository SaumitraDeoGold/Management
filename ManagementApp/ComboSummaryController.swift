//
//  SalesReturnViewController.swift
//  DealorsApp
//
//  Created by Goldmedal on 5/12/18.
//  Copyright © 2018 Goldmedal. All rights reserved.
//

import UIKit
import FirebaseAnalytics

class ComboSummaryController: BaseViewController , UITableViewDelegate , UITableViewDataSource{

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noDataView: NoDataView!
    var comboSummaryApi=""
    
    var ComboElementMain = [ComboSummaryElement]()
    var ComboSummaryArr = [ComboSummaryObj]()
    var strCin = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addSlideMenuButton()
        
        self.noDataView.hideView(view: self.noDataView)
        
        let loginData =  UserDefaults.standard.value(forKey: "loginData") as? Dictionary ?? [:]
        strCin = loginData["userlogid"] as? String ?? ""
        
        let initialData =  UserDefaults.standard.value(forKey: "initialData") as? Dictionary ?? [:]
        comboSummaryApi = (initialData["baseApi"] as? String ?? "")+""+(initialData["comboClaim"] as? String ?? "")
        
        
        // Do any additional setup after loading the view.
        if (Utility.isConnectedToNetwork()) {
            print("Internet connection available")
            self.apiComboSummary();
            self.noDataView.hideView(view: self.noDataView)
        }
        else {
            print("No internet connection available")
            var alert = UIAlertView(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
            self.noDataView.showView(view: self.noDataView, from: "NET")
        }
        
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        Analytics.setScreenName("COMBO SUMMARY SCREEN", screenClass: "ComboSummaryController")
        
    }
    
    func apiComboSummary(){
        ViewControllerUtils.sharedInstance.showLoader()
        
        let json: [String: Any] = ["CIN":strCin,"ClientSecret":"ClientSecret"]
        
        DataManager.shared.makeAPICall(url: comboSummaryApi, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            
            DispatchQueue.main.async {
                do {
                    self.ComboElementMain = try JSONDecoder().decode([ComboSummaryCell].self, from: data!)
                    self.ComboSummaryArr.append(contentsOf:self.ComboElementMain[0].data)
                    
                } catch let errorData {
                    print(errorData.localizedDescription)
                }
                
                if(self.tableView != nil)
                {
                    self.tableView.reloadData()
                }
                
                if(self.ComboSummaryArr.count>0){
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
        return ComboSummaryArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ComboSummaryCell", for: indexPath) as! ComboSummaryCell
        
        cell.lblProductName.text = ComboSummaryArr[indexPath.row].itemnm?.capitalized ?? "-"
        cell.lblOrdered.text = ComboSummaryArr[indexPath.row].finalqty ?? "-"
        cell.lblReceived.text = ComboSummaryArr[indexPath.row].totalsale ?? "-"
        cell.lblBalance.text = ComboSummaryArr[indexPath.row].difference ?? "-"
     
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
