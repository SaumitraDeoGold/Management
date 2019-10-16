//
//  CustomYearPickerController.swift
//  DealorsApp
//
//  Created by Goldmedal on 4/13/18.
//  Copyright © 2018 Goldmedal. All rights reserved.
//

import UIKit

class CustomYearPickerController: UIViewController ,UIPickerViewDataSource, UIPickerViewDelegate {
   
    @IBOutlet weak var picker: UIPickerView!
    @IBOutlet weak var lblPickerHeader: UILabel!
    @IBOutlet weak var btnOK: UIButton!
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var mainView: UIView!
    
    var strSelectedValue = ""
    var rowPosition = 0
    
    var delegate: PopupDateDelegate?
    
    var pickerDataSource = [String]()
    var showPicker = Int()
   
    
    @IBAction func cancel_clicked(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    
    @IBAction func ok_clicked(_ sender: UIButton) {
        if(strSelectedValue == ""){
            if showPicker == 3{
                strSelectedValue = pickerDataSource[2]
            }else{
                strSelectedValue = pickerDataSource[0]
            }
        }
        delegate?.updatePositionValue!(value: strSelectedValue, position: rowPosition,from: "YEAR")
        dismiss(animated: true)
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.picker.dataSource = self;
        self.picker.delegate = self;
        specialEffects()
        if showPicker == 2 {
            print("--------Q----------",showPicker)
             pickerDataSource = ["Q1 (APR - JUN)", "Q2 (JUL - SEP)", "Q3 (OCT - DEC)", "Q4 (JAN - MAR)"];
            lblPickerHeader.text = "QUARTERLY"
        }
        
        if showPicker == 1 {
            print("--------M----------",showPicker)
             pickerDataSource = ["JANUARY", "FEBRUARY", "MARCH", "APRIL","MAY","JUNE","JULY","AUGUST","SEPTEMBER","OCTOBER","NOVEMBER","DECEMBER"];
            lblPickerHeader.text = "MONTHLY"
        }
        
        if showPicker == 3 {
            print("--------Y----------",showPicker)
             pickerDataSource = ["2017-2018","2018-2019","2019-2020"];
            lblPickerHeader.text = "YEARLY"
            picker.selectRow(2, inComponent: 0, animated: true)
        }
    }
    
    //Corner Radius and Blurr Effect...
    func specialEffects(){
        //Corner Radius [Selective]...
        let rectShape = CAShapeLayer()
        rectShape.bounds = self.topView.frame
        rectShape.position = self.topView.center
        rectShape.path = UIBezierPath(roundedRect: self.topView.bounds, byRoundingCorners: [.topRight , .topLeft], cornerRadii: CGSize(width: 14, height: 14)).cgPath
        self.topView.layer.mask = rectShape
        let roundCorner = CAShapeLayer()
        roundCorner.bounds = self.bottomView.frame
        roundCorner.position = self.bottomView.center
        roundCorner.path = UIBezierPath(roundedRect: self.bottomView.bounds, byRoundingCorners: [.bottomRight , .bottomLeft], cornerRadii: CGSize(width: 14, height: 14)).cgPath
        self.bottomView.layer.mask = roundCorner
        
        //Blur Effect...
        if !UIAccessibility.isReduceTransparencyEnabled {
            mainView.backgroundColor = .clear
            let blurEffect = UIBlurEffect(style: .dark)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            //always fill the view
            blurEffectView.frame = self.view.bounds
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            mainView.addSubview(blurEffectView) //if you have more UIViews, use an insertSubview API to place it where needed
            mainView.sendSubview(toBack: blurEffectView)
        }
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
        strSelectedValue = pickerDataSource[row]
        rowPosition = row
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
