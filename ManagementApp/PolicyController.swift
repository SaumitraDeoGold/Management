//
//  PolicyController.swift
//  DealorsApp
//
//  Created by Goldmedal on 5/5/18.
//  Copyright © 2018 Goldmedal. All rights reserved.
//

import UIKit
import FirebaseAnalytics

class PolicyController: BaseViewController , UITableViewDelegate , UITableViewDataSource {

    @IBOutlet weak var menuPolicy: UIBarButtonItem!
    @IBOutlet weak var tableViewPolicy: UITableView!
    @IBOutlet weak var noDataView: NoDataView!
    
    var PolicyElementMain = [PolicyElement]()
    var PolicyArray = [PolicyData]()
    var strCin = ""
    var policyApi=""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addSlideMenuButton()
        
         self.noDataView.hideView(view: self.noDataView)
        
        Analytics.setScreenName("POLICY SCREEN", screenClass: "PolicyController")
        
        let loginData =  UserDefaults.standard.value(forKey: "loginData") as? Dictionary ?? [:]
        strCin = loginData["userlogid"] as? String ?? ""
        
        let initialData =  UserDefaults.standard.value(forKey: "initialData") as? Dictionary ?? [:]
        policyApi = (initialData["baseApi"] as? String ?? "")+""+(initialData["policy"] as? String ?? "")
        
        
        // Do any additional setup after loading the view.
        if (Utility.isConnectedToNetwork()) {
            print("Internet connection available")
            self.apiPolicyList()
             self.noDataView.hideView(view: self.noDataView)
        }
        else{
            print("No internet connection available")
            
            var alert = UIAlertView(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
             self.noDataView.showView(view: self.noDataView, from: "NET")
        }
        
        
        self.tableViewPolicy.delegate = self;
        self.tableViewPolicy.dataSource = self;
    }
    
    
    func apiPolicyList(){
        let json: [String: Any] = ["CIN":strCin,"ClientSecret":"ClientSecret"]
        
        DataManager.shared.makeAPICall(url: policyApi, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            
             DispatchQueue.main.async {
            do {
                self.PolicyElementMain = try JSONDecoder().decode([PolicyElement].self, from: data!)
                self.PolicyArray = self.PolicyElementMain[0].data
            } catch let errorData {
                print(errorData.localizedDescription)
            }
                
                if(self.PolicyArray.count>0){
                    if(self.tableViewPolicy != nil)
                    {
                        self.tableViewPolicy.reloadData()
                    }
                    self.noDataView.hideView(view: self.noDataView)
                }else{
                    self.noDataView.showView(view: self.noDataView, from: "NDA")
                }
                
            }
        }) { (Error) in
            ViewControllerUtils.sharedInstance.removeLoader()
            print(Error?.localizedDescription)
            self.noDataView.showView(view: self.noDataView, from: "ERR")
        }
        
    }
    
    
    func clickPdf(sender: UITapGestureRecognizer)
    {
        print("pdf name : \(sender.view!.tag)")
        
        guard let url = URL(string: PolicyArray[sender.view!.tag].pdf ?? "-") else {
            var alert = UIAlertView(title: "Error", message: "Invalid Pdf", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
            
            return
        }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return PolicyArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PolicyListCell", for: indexPath) as! PolicyRowCell
        
        cell.lblPolicyName.text = PolicyArray[indexPath.row].policyName?.capitalized ?? "-"
        cell.lblToDate.text = PolicyArray[indexPath.row].todate ?? "-"
        cell.lblFromDate.text = PolicyArray[indexPath.row].fromDate ?? "-"
        
        if PolicyArray[indexPath.row].imgurl != ""
        {
            cell.imvPolicy.sd_setImage(with: URL(string: PolicyArray[indexPath.row].imgurl ?? ""), placeholderImage: UIImage(named: "no_image_icon.png"))
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.clickPdf))
        cell.imvPolicy.addGestureRecognizer(tap)
        cell.imvPolicy.tag = indexPath.row
        cell.imvPolicy.isUserInteractionEnabled = true
        
        return cell
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
