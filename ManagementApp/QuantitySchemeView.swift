//
//  QuantitySchemeView.swift
//  DealorsApp
//
//  Created by Goldmedal on 8/9/18.
//  Copyright © 2018 Goldmedal. All rights reserved.
//

import Foundation
import UIKit
import AMPopTip

@IBDesignable class QuantitySchemeView: BaseCustomView {
    
    @IBOutlet var tblQuantityScheme: IntrinsicTableView!
    @IBOutlet weak var imvInfo: UIImageView!
    @IBOutlet weak var vwQuantityScheme: UIView!

    let cellIdentifier = "\(DashboardSchemeCell.self)"
    var QuantitySchemeMain = [QuantitySchemeElement]()
    var QuantitySchemeArr = [QuantitySchemeData]()
    var strCin = ""
    
    @IBOutlet weak var noDataView: NoDataView!

    var txtToolTipQty = "Net Qty is the total Qty sold in the running quarter"
    let popTip = PopTip()
    var schemeApi=""
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

        tblQuantityScheme.register(UINib(nibName: cellIdentifier, bundle: nil), forCellReuseIdentifier: cellIdentifier)
        
        
        if (Utility.isConnectedToNetwork()) {
            apiQuantityScheme()
        }
        else{
            self.noDataView.showView(view: self.noDataView, from: "NET")
            self.tblQuantityScheme.showNoData = true
        }

    }

    @objc func tapFunction(sender:UITapGestureRecognizer) {
        print("clicked")
        popTip.bubbleColor = UIColor.black
        popTip.show(text: txtToolTipQty, direction: .none, maxWidth: 300, in: vwQuantityScheme, from: view.frame)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.popTip.hide()
        }
    }


    func apiQuantityScheme(){
        self.noDataView.showView(view: self.noDataView, from: "LOADER")
        self.tblQuantityScheme.showNoData = true

        let json: [String: Any] = ["CIN":appDelegate.sendCin,"ClientSecret":"201020","Type":2]

        DataManager.shared.makeAPICall(url: schemeApi, params: json, method: .POST, success: { (response) in
            let data = response as? Data

             DispatchQueue.main.async {
            do {
                self.QuantitySchemeMain = try JSONDecoder().decode([QuantitySchemeElement].self, from: data!)
                self.QuantitySchemeArr = self.QuantitySchemeMain[0].data

                let result = self.QuantitySchemeMain[0].result
                
            } catch let errorData {
                print(errorData.localizedDescription)
            }
                if(self.tblQuantityScheme != nil)
                { self.tblQuantityScheme.reloadData() }
                
                if(self.QuantitySchemeArr.count > 0){
                    self.noDataView.hideView(view: self.noDataView)
                    self.tblQuantityScheme.showNoData = false
                }else{
                    self.noDataView.showView(view: self.noDataView, from: "NDA")
                    self.tblQuantityScheme.showNoData = true
                }
            }
        }) { (Error) in
            print(Error?.localizedDescription)
            self.noDataView.showView(view: self.noDataView, from: "ERR")
            self.tblQuantityScheme.showNoData = true
        }
    }
    
}

extension QuantitySchemeView : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return QuantitySchemeArr.count
    }


    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! DashboardSchemeCell

        cell.lblSchemeName.text = QuantitySchemeArr[indexPath.row].schemename?.capitalized ?? "-"
        cell.lblNextSlab.text = QuantitySchemeArr[indexPath.row].nextslab
        cell.lblNetAmount.text = QuantitySchemeArr[indexPath.row].netsale
        cell.lblCurrentSlab.text = QuantitySchemeArr[indexPath.row].curslab

        return cell
    }

}

extension QuantitySchemeView : UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
}
