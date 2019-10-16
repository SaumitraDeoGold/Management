//
//  OutstandingReportCell.swift
//  DealorsApp
//
//  Created by Goldmedal on 4/7/18.
//  Copyright © 2018 Goldmedal. All rights reserved.
//

import UIKit

@objc protocol OutstandingAmountDelegate {
    @objc optional func UpdateAmount(cell: OutstandingReportCell)
    @objc optional func UpdateCheckbox(cell: OutstandingReportCell)
    @objc optional func showInfoCell(cell: OutstandingReportCell)
}

class OutstandingReportCell: UITableViewCell,UITextFieldDelegate {
    
    @IBOutlet weak var lblInvoiceNo: UILabel!
    @IBOutlet weak var lblInvoiceHeader: UILabel!
    @IBOutlet weak var lblDivision: UILabel!
    @IBOutlet weak var lblinvoiceAmnt: UILabel!
    @IBOutlet weak var lblOutsAmnt: UILabel!
    @IBOutlet weak var lblDueDays: UILabel!
    @IBOutlet weak var lblPartialTag: UILabel!
    @IBOutlet weak var btnEdtAmount: UIButton!
    @IBOutlet weak var btnCheckbox: UIButton!
    @IBOutlet weak var btnInfoDetail: UIButton!
    
    var delegate: OutstandingAmountDelegate?
    var callFrom = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    @IBAction func addAmount(sender: AnyObject) {
        delegate?.UpdateAmount!(cell: self)
    }
    
    @IBAction func checkBox(sender: AnyObject) {
        delegate?.UpdateCheckbox!(cell: self)
    }
    
    @IBAction func infoCell(sender: AnyObject) {
        delegate?.showInfoCell!(cell: self)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
