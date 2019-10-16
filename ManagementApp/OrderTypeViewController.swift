//
//  OrderTypeViewController.swift
//  DealorsApp
//
//  Created by Goldmedal on 8/21/18.
//  Copyright © 2018 Goldmedal. All rights reserved.
//

import Foundation
import UIKit

class OrderTypeViewController: UIViewController ,UIPickerViewDataSource, UIPickerViewDelegate{
    
    @IBOutlet weak var pickerOrderType: UIPickerView!
    @IBOutlet weak var lblOrderTypeHeader: UILabel!
    @IBOutlet weak var btnOk: UIButton!
    @IBOutlet weak var btnCancel: UIButton!
    var delegate: PopupDateDelegate?
    var strOrderType = ""
    var intOrderRow = 0
    var intRowValue = 0
    var intOutsRow = 0
    var outsArr = [2500,15,30,45,60]
    var pickerDataSource = [String]()
    var showPicker = 0
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.pickerOrderType.dataSource = self;
        self.pickerOrderType.delegate = self;
        
        if showPicker == 1 {
        pickerDataSource = ["ALL","BELOW 15","BELOW 30","BELOW 45","BELOW 60"]
        lblOrderTypeHeader.text = "OUTSTANDING"
        }else{
            pickerDataSource = ["Order Wise","Summary Wise"]
            lblOrderTypeHeader.text = "ORDER TYPE"
        }
    }
    
    
    @IBAction func cancel_clicked(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @IBAction func ok_clicked(_ sender: UIButton) {
        if(strOrderType == ""){
         strOrderType = pickerDataSource[0]
            intOrderRow = 1
            intOutsRow = 2500
        }
        
        if(showPicker == 1){
            intRowValue = intOutsRow
        }else{
            intRowValue = intOrderRow
        }
        
        delegate?.updatePositionValue!(value: strOrderType, position: intRowValue, from: "ORDER")
        dismiss(animated: true)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1;
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerDataSource.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerDataSource[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        strOrderType = pickerDataSource[row]
        intOrderRow = row + 1
        intOutsRow = outsArr[row]
    }
    
}

