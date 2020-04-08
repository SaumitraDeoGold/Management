//
//  DatePickerController.swift
//  DealorsApp
//
//  Created by Goldmedal on 4/14/18.
//  Copyright © 2018 Goldmedal. All rights reserved.
//

import UIKit

class DatePickerController: UIViewController {
    
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var btnOK: UIButton!
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var lblDateHeader: UILabel!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var mainView: UIView!

    var isFromDate = false
    var truce = false
    var fromDate: Date?
    var toDate: Date?


    var dateFormatter = DateFormatter()
    var selectedDate = ""
    
    var delegate: PopupDateDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        specialEffects()

        if isFromDate && !truce{
            if let toDate = toDate {
                datePicker.maximumDate = toDate
            } else {
                datePicker.maximumDate = Date()
            }
        }else if truce{
            
        } else {
            if let fromDate = fromDate {
                datePicker.minimumDate = fromDate
            } else {
                datePicker.maximumDate = Date()
            }
            
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
 
    
    @IBAction func cancel_clicked(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    
    @IBAction func ok_clicked(_ sender: UIButton) {
        dateFormatter.dateFormat = "dd/MM/yyyy"
        selectedDate = dateFormatter.string(from: datePicker.date)
        delegate?.updateDate!(value: selectedDate, date: datePicker.date)
        dismiss(animated: true)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
