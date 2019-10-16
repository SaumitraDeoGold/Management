//
//  GroupSchemeView.swift
//  DealorsApp
//
//  Created by Goldmedal on 8/9/18.
//  Copyright © 2018 Goldmedal. All rights reserved.
//

import Foundation
import UIKit
import AMPopTip

@IBDesignable class GroupSchemeView: BaseCustomView {
    
    @IBOutlet var tblGroupSchemeView: IntrinsicTableView!
    @IBOutlet weak var imvInfo: UIImageView!
    @IBOutlet weak var vwGroupScheme: UIView!
    
    var GroupSchemeMain = [GroupSchemeElement]()
    var GroupSchemeArr = [GroupSchemeData]()
    var strCin = ""
    let cellIdentifier = "\(DashboardSchemeCell.self)"
    
    var schemeApi=""
    
     @IBOutlet weak var noDataView: NoDataView!
    
    var txtToolTipAmnt = "Net Amnt is the total sales achieved for the quarter."
    let popTip = PopTip()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    override func xibSetup() {
        super.xibSetup()
        
        self.noDataView.hideView(view: self.noDataView)
        
        let loginData =  UserDefaults.standard.value(forKey: "loginData") as? Dictionary ?? [:]
        strCin = loginData["userlogid"] as? String ?? ""
        
        let initialData =  UserDefaults.standard.value(forKey: "initialData") as? Dictionary ?? [:]
        schemeApi = (initialData["baseApi"] as? String ?? "")+""+(initialData["schemeDetails"] as? String ?? "")
        
        let tapInfo = UITapGestureRecognizer(target: self, action: #selector(self.tapFunction))
        imvInfo.addGestureRecognizer(tapInfo)
        
        tblGroupSchemeView.register(UINib(nibName: cellIdentifier, bundle: nil), forCellReuseIdentifier: cellIdentifier)
        
       
        if (Utility.isConnectedToNetwork()) {
             apiGroupScheme()
        }
        else{
            self.noDataView.showView(view: self.noDataView, from: "NET")
            self.tblGroupSchemeView.showNoData = true
        }
    }
    
    
    @objc func tapFunction(sender:UITapGestureRecognizer) {
        print("clicked")
        popTip.bubbleColor = UIColor.black
        popTip.show(text: txtToolTipAmnt, direction: .none, maxWidth: 300, in: vwGroupScheme, from: vwGroupScheme.frame)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.popTip.hide()
        }
    }
    
    
    func apiGroupScheme(){
        self.noDataView.showView(view: self.noDataView, from: "LOADER")
        self.tblGroupSchemeView.showNoData = true
        
        let json: [String: Any] = ["CIN":appDelegate.sendCin,"ClientSecret":"201020","Type":4]
        
        DataManager.shared.makeAPICall(url: schemeApi, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            
            DispatchQueue.main.async {
            do {
                self.GroupSchemeMain = try JSONDecoder().decode([GroupSchemeElement].self, from: data!)
                self.GroupSchemeArr = self.GroupSchemeMain[0].data
                
                let result = self.GroupSchemeMain[0].result
         
            } catch let errorData {
                print(errorData.localizedDescription)
            }
                
                if(self.tblGroupSchemeView != nil)
                { self.tblGroupSchemeView.reloadData() }
                
                if(self.GroupSchemeArr.count > 0){
                    self.noDataView.hideView(view: self.noDataView)
                    self.tblGroupSchemeView.showNoData = false
                }else{
                    self.noDataView.showView(view: self.noDataView, from: "NDA")
                    self.tblGroupSchemeView.showNoData = true
                }
            }
        }) { (Error) in
            print(Error?.localizedDescription)
            self.noDataView.showView(view: self.noDataView, from: "ERR")
            self.tblGroupSchemeView.showNoData = true
        }
        
    }
}


extension GroupSchemeView : UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
}

extension GroupSchemeView : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return GroupSchemeArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! DashboardSchemeCell
        
        cell.lblSchemeName.text = GroupSchemeArr[indexPath.row].schemename?.capitalized ?? "-"
        cell.lblNextSlab.text = GroupSchemeArr[indexPath.row].nextslab ?? "-"
        cell.lblNetAmount.text = GroupSchemeArr[indexPath.row].netsale ?? "-"
        cell.lblCurrentSlab.text = GroupSchemeArr[indexPath.row].curslab ?? "-"
        
        return cell
    }
    
}
