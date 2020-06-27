//
//  QuarterYearPickerController.swift
//  GStar
//
//  Created by Goldmedal on 14/04/20.
//  Copyright © 2020 Goldmedal. All rights reserved.
//

import UIKit

class QuarterYearPickerController: UIViewController {
    
    
    
    @IBOutlet weak var datePicker: QuarterYearPickerView!
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
        
        
        print("QUARTER - - - ",datePicker.quarter)
        print("YEAR  - - - ",datePicker.year)
        
        
        selectedDate = "\(datePicker.quarter) \(datePicker.year)"
        let formattedString = "01/\(datePicker.quarter)/\(datePicker.year)"
        let date = dateFormatter.date(from: formattedString) ?? Date()
        
        delegate?.updateDateFromPicker!(value: selectedDate, date: date,from: "QUARTER")
        dismiss(animated: true)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}


