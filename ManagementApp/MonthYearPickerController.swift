//
//  CustomDatePickerController.swift
//  GStar
//
//  Created by Goldmedal on 14/04/20.
//  Copyright © 2020 Goldmedal. All rights reserved.
//

import UIKit

class MonthYearPickerController: UIViewController {
    
    @IBOutlet weak var datePicker: MonthYearPickerView!
    @IBOutlet weak var btnOK: UIButton!
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var lblDateHeader: UILabel!

    var dateFormatter = DateFormatter()
    var selectedDate = ""
    var delegate: PopupDateDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
 
    
    @IBAction func cancel_clicked(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    
    @IBAction func ok_clicked(_ sender: UIButton) {
        dateFormatter.dateFormat = "dd/MM/yyyy"
        
        selectedDate = "\(DateFormatter().monthSymbols[datePicker.month-1].capitalized) \(datePicker.year)"
        let formattedString = "01/\(datePicker.month)/\(datePicker.year)"
        let date = dateFormatter.date(from: formattedString) ?? Date()
        
        delegate?.updateDateFromPicker!(value: selectedDate, date: date,from: "MONTH")
        dismiss(animated: true)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

