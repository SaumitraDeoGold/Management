//
//  SchemeView.swift
//  DealorsApp
//
//  Created by Goldmedal on 8/7/18.
//  Copyright © 2018 Goldmedal. All rights reserved.
//

import Foundation
import UIKit

import AMPopTip
@IBDesignable class RegularSchemeView: BaseCustomView {
    
    @IBOutlet var tblRegularScheme: IntrinsicTableView!
    @IBOutlet weak var imvInfo: UIImageView!
    @IBOutlet weak var vwRegularScheme: UIView!
     @IBOutlet weak var vwRegularSchemeHeader: UIView!
    
    let cellIdentifier = "\(DashboardSchemeCell.self)"
    var RegularSchemeMain = [RegularSchemeElement]()
    var RegularSchemeArr = [RegularSchemeData]()
    var strCin = ""
    var schemeApi=""
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
     @IBOutlet weak var noDataView: NoDataView!
    
    var txtToolTipAmnt = "Net Amnt is the total sales achieved for the quarter."
    let popTip = PopTip()
 
    override func xibSetup() {
        super.xibSetup()
    
        self.noDataView.hideView(view: self.noDataView)
        
        let loginData =  UserDefaults.standard.value(forKey: "loginData") as? Dictionary ?? [:]
        strCin = loginData["userlogid"] as? String ?? ""
        
        let initialData =  UserDefaults.standard.value(forKey: "initialData") as? Dictionary ?? [:]
        schemeApi = (initialData["baseApi"] as? String ?? "")+""+(initialData["schemeDetails"] as? String ?? "")
        
        let tapInfo = UITapGestureRecognizer(target: self, action: #selector(self.tapFunction))
        imvInfo.addGestureRecognizer(tapInfo)
        
        tblRegularScheme.register(UINib(nibName: cellIdentifier, bundle: nil), forCellReuseIdentifier: cellIdentifier)
        
       
        if (Utility.isConnectedToNetwork()) {
            apiRegularScheme()
        }
        else{
            self.noDataView.showView(view: self.noDataView, from: "NET")
            self.tblRegularScheme.showNoData = true
        }
     
    }
    
    @objc func tapFunction(sender:UITapGestureRecognizer) {
        print("clicked")
        popTip.bubbleColor = UIColor.black
        popTip.show(text: txtToolTipAmnt, direction: .none, maxWidth: 300, in: view, from: vwRegularScheme.frame)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.popTip.hide()
        }
    }
    
    func apiRegularScheme(){
 
        self.noDataView.showView(view: self.noDataView, from: "LOADER")
        self.tblRegularScheme.showNoData = true
        
        let json: [String: Any] = ["CIN":appDelegate.sendCin,"ClientSecret":"201020","Type":1]
        
        DataManager.shared.makeAPICall(url: schemeApi, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            
             DispatchQueue.main.async {
            do {
                self.RegularSchemeMain = try JSONDecoder().decode([RegularSchemeElement].self, from: data!)
                self.RegularSchemeArr = self.RegularSchemeMain[0].data
        
            } catch let errorData {
                print(errorData.localizedDescription)
            }
                if(self.tblRegularScheme != nil)
                { self.tblRegularScheme.reloadData() }
                
                if(self.RegularSchemeArr.count > 0){
                    self.noDataView.hideView(view: self.noDataView)
                    self.tblRegularScheme.showNoData = false
                }else{
                    self.noDataView.showView(view: self.noDataView, from: "NDA")
                    self.tblRegularScheme.showNoData = true
                }
            }
        }) { (Error) in
            print(Error?.localizedDescription)
            self.noDataView.showView(view: self.noDataView, from: "ERR")
            self.tblRegularScheme.showNoData = true
        }
        
    }
    
}

extension RegularSchemeView : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if RegularSchemeArr.count == 0 {
            return 1
        }
        return RegularSchemeArr.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if RegularSchemeArr.count == 0 {
            return UITableViewCell()
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! DashboardSchemeCell

            cell.lblSchemeName.text = RegularSchemeArr[indexPath.row].schemename?.capitalized ?? "-"
            cell.lblNextSlab.text = RegularSchemeArr[indexPath.row].nextslab ?? "-"
            cell.lblNetAmount.text = RegularSchemeArr[indexPath.row].netsale ?? "-"
            cell.lblCurrentSlab.text = RegularSchemeArr[indexPath.row].curslab ?? "-"

            return cell
        }

    }
}


extension RegularSchemeView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
}



class IntrinsicTableView: UITableView {
    var showNoData = false
    var showNoDataPie = false
    var height: CGFloat = 0.0

    override var contentSize:CGSize {
        didSet {
                self.invalidateIntrinsicContentSize()
        }
    }
    
    

    override var intrinsicContentSize: CGSize {
        self.layoutIfNeeded()
        
        if(showNoData){
            height = 300
        }
        
        if(showNoDataPie){
            height = 100
        }
        
       
        return CGSize(width: UIViewNoIntrinsicMetric, height: (showNoData || showNoDataPie) ? height : contentSize.height)
    }

}
