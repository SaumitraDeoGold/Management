//
//  QuarterYearPickerView.swift
//  GStar
//
//  Created by Goldmedal on 14/04/20.
//  Copyright © 2020 Goldmedal. All rights reserved.
//

import UIKit

class QuarterYearPickerView: UIPickerView, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var quarters = ["Q1 (APR - JUN)", "Q2 (JUL - SEP)", "Q3 (OCT - DEC)", "Q4 (JAN - MAR)"]
    var years: [String]!
    
    
    var quarter = Utility.currQuarter()
    var year = Utility.currFinancialYear()
//    var quarter = Calendar.current.component(.quarter, from: Date()) {
//        didSet {
//            selectRow(quarter-1, inComponent: 0, animated: false)
//
//        }
//    }
    
//    var year = Calendar.current.component(.year, from: Date()) {
//        didSet {
//           // selectRow(years.firstIndex(of: Int(year)!, inComponent: 1, animated: true)
//            selectRow(years?[year], inComponent: 1, animated: true)
//        }
//    }
    
    var onDateSelected: ((_ quarter: Int, _ year: Int) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonSetup()
    }
    
    func commonSetup() {
        // population years
        var years: [String] = []
//        if years.count == 0 {
            //var year = NSCalendar(identifier: NSCalendar.Identifier.gregorian)!.component(.year, from: NSDate() as Date)
            
            
            let date = Date()
                let calendar = Calendar.current
                
                let year = calendar.component(.year, from: date)
                let month = calendar.component(.month, from: date)
               // let day = calendar.component(.day, from: date)
                
                for i in (0...3) {
                    if (month >= 4) {
                        years.append(String(String(year - (i)) + "-" + String(year + 1 - (i))))
                    } else {
                        years.append(String(String(year - 1 - (i)) + "-" + String(year - (i))))
                    }
                }
                    
            
            
        
            
//            var year = 2017
//            for _ in 1...10 {
//                years.append(year)
//                year += 1
//            }
//        }
        self.years = years
        
        // population months with localized names
       // var quarters: [String] = []
//        let quarter = ["Q1 (APR - JUN)", "Q2 (JUL - SEP)", "Q3 (OCT - DEC)", "Q4 (JAN - MAR)"]
//        for index in 0..<quarter.count {
//
//          //  quarters.append(DateFormatter().shortStandaloneQuarterSymbols[quarter].capitalized)
//         quarters.append(quarter[index])
//
//
//           // quarter += 1
//        }
       // self.quarters = quarters
        
        self.delegate = self
        self.dataSource = self
        
        let currentQuarter = NSCalendar(identifier: NSCalendar.Identifier.gregorian)!.component(.quarter, from: NSDate() as Date)
        
        self.selectRow(currentQuarter - 1, inComponent: 0, animated: false)
        
       // let currentYear = NSCalendar(identifier: NSCalendar.Identifier.gregorian)!.component(.year, from: NSDate() as Date)
        
        let financialYear  = Utility.currFinancialYear()
        for (index, element) in self.years.enumerated() {
            if(financialYear == element){
                self.selectRow(index, inComponent: 1, animated: true)
                return
            }
            
        }
    }
    
    // Mark: UIPicker Delegate / Data Source
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let pickerLabel = UILabel()
        pickerLabel.font = UIFont.systemFont(ofSize: 16)
        pickerLabel.textAlignment = .center
        
        switch component {
               case 0:
                pickerLabel.text = quarters[row]
            return pickerLabel
                  
               case 1:
                pickerLabel.text = years[row]
                   return pickerLabel
               default:
                  return pickerLabel
               }
         
        }
    
    
//    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
//        switch component {
//        case 0:
//            return quarters[row]
//        case 1:
//            return years[row]
//        default:
//            return nil
//        }
//    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0:
            return quarters.count
        case 1:
            return years.count
        default:
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        //let month = self.selectedRow(inComponent: 0)+1
        let quarter = quarters[self.selectedRow(inComponent: 0)]
     //   let year = years[self.selectedRow(inComponent: 1)]
         let year = years[self.selectedRow(inComponent: 1)]
//      if let block = onDateSelected {
//                block(quarter, year)
//            }
            self.quarter = quarter
            self.year = year
        
        
        
    }
    
}

