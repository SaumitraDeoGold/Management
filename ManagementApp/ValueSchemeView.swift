//
//  ValueSchemeView.swift
//  DealorsApp
//
//  Created by Goldmedal on 8/9/18.
//  Copyright © 2018 Goldmedal. All rights reserved.
//

import Foundation
import UIKit
import AMPopTip

@IBDesignable class ValueSchemeView: BaseCustomView {
    
    @IBOutlet var tblValueScheme: IntrinsicTableView!
    @IBOutlet weak var imvInfo: UIImageView!
    @IBOutlet weak var vwValueScheme: UIView!
    
    var ValueSchemeMain = [ValueSchemeElement]()
    var ValueSchemeArr = [ValueSchemeData]()
    var strCin = ""
     let cellIdentifier = "\(DashboardSchemeCell.self)"
    
    var txtToolTipQty = "Net Qty is the total Qty sold in the running quarter"
    let popTip = PopTip()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
     @IBOutlet weak var noDataView: NoDataView!
    var schemeApi=""
    
    override func xibSetup() {
        super.xibSetup()
        
         self.noDataView.hideView(view: self.noDataView)
        
        let loginData =  UserDefaults.standard.value(forKey: "loginData") as? Dictionary ?? [:]
        strCin = loginData["userlogid"] as? String ?? ""
        
        let initialData =  UserDefaults.standard.value(forKey: "initialData") as? Dictionary ?? [:]
        schemeApi = (initialData["baseApi"] as? String ?? "")+""+(initialData["schemeDetails"] as? String ?? "")
        
        
        let tapInfo = UITapGestureRecognizer(target: self, action: #selector(self.tapFunction))
        imvInfo.addGestureRecognizer(tapInfo)
        
        tblValueScheme.register(UINib(nibName: cellIdentifier, bundle: nil), forCellReuseIdentifier: cellIdentifier)
        
        // Do any additional setup after loading the view.
        if (Utility.isConnectedToNetwork()) {
             apiValueScheme()
        }
        else{
            self.noDataView.showView(view: self.noDataView, from: "NET")
            self.tblValueScheme.showNoData = true
        }
    }
    
    @objc func tapFunction(sender:UITapGestureRecognizer) {
        print("clicked")
        popTip.bubbleColor = UIColor.black
        popTip.show(text: txtToolTipQty, direction: .none, maxWidth: 300, in: vwValueScheme, from: vwValueScheme.frame)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.popTip.hide()
        }
    }
    
    func apiValueScheme(){
        self.noDataView.showView(view: self.noDataView, from: "LOADER")
        self.tblValueScheme.showNoData = true
        
        let json: [String: Any] = ["CIN":appDelegate.sendCin,"ClientSecret":"201020","Type":3]
        
        DataManager.shared.makeAPICall(url: schemeApi, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            
             DispatchQueue.main.async {
            do {
                self.ValueSchemeMain = try JSONDecoder().decode([ValueSchemeElement].self, from: data!)
                self.ValueSchemeArr = self.ValueSchemeMain[0].data
                
                let result = self.ValueSchemeMain[0].result
         
            } catch let errorData {
                print(errorData.localizedDescription)
            }
                if(self.tblValueScheme != nil)
                { self.tblValueScheme.reloadData() }
                
                if(self.ValueSchemeArr.count > 0){
                    self.noDataView.hideView(view: self.noDataView)
                    self.tblValueScheme.showNoData = false
                }else{
                    self.noDataView.showView(view: self.noDataView, from: "NDA")
                    self.tblValueScheme.showNoData = true
                }
            }
        }) { (Error) in
            print(Error?.localizedDescription)
            self.noDataView.showView(view: self.noDataView, from: "ERR")
            self.tblValueScheme.showNoData = true
        }
        
    }
 
}


extension ValueSchemeView : UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
}

extension ValueSchemeView : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ValueSchemeArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! DashboardSchemeCell
        
        cell.lblSchemeName.text = ValueSchemeArr[indexPath.row].schemename?.capitalized ?? "-"
        cell.lblNextSlab.text = ValueSchemeArr[indexPath.row].nextslab ?? "-"
        cell.lblNetAmount.text = ValueSchemeArr[indexPath.row].netsale ?? "-"
        cell.lblCurrentSlab.text = ValueSchemeArr[indexPath.row].curslab ?? "-"
        
        return cell
    }

    
}

