//
//  TodaySalesViewController.swift
//  ManagementApp
//
//  Created by Goldmedal on 18/03/19.
//  Copyright © 2019 Goldmedal. All rights reserved.
//

import UIKit

class TodaySalesViewController: UIViewController {
    
    @IBOutlet weak var lblTodaySales: UILabel!
    @IBOutlet weak var lblMonthlySales: UILabel!
    @IBOutlet weak var lblQuarterlySales: UILabel!
    @IBOutlet weak var lblYearlySales: UILabel!
    @IBOutlet weak var viewToday: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        lblTodaySales.text = Utility.formatRupee(amount: Double(todaySale))
        lblMonthlySales.text = Utility.formatRupee(amount: Double(monthlySale))
        lblQuarterlySales.text = Utility.formatRupee(amount: Double(quarterlySale))
        lblYearlySales.text = Utility.formatRupee(amount: Double(yearlySale))
        refresh()
        // Do any additional setup after loading the view.
    }
    
    var todaySale = 7852
    var monthlySale = 67852
    var quarterlySale = 457852
    var yearlySale = 9127852
    
    
    
    let colors = Colors()
    
    func refresh() {
        viewToday.layer.cornerRadius = 20.0
        viewToday.layer.shadowColor = UIColor.gray.cgColor
        viewToday.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        viewToday.layer.shadowRadius = 12.0
        viewToday.layer.shadowOpacity = 0.7
    }
    
    
}




class Colors {
    var gl:CAGradientLayer!
    
    init() {
        let colorTop = UIColor(red: 192.0 / 255.0, green: 38.0 / 255.0, blue: 42.0 / 255.0, alpha: 1.0).cgColor
        let colorBottom = UIColor(red: 35.0 / 255.0, green: 2.0 / 255.0, blue: 2.0 / 255.0, alpha: 1.0).cgColor
        
        self.gl = CAGradientLayer()
        self.gl.colors = [colorTop, colorBottom]
        self.gl.locations = [0.0, 1.0]
    }
}
