//
//  CreditDebitCell.swift
//  DealorsApp
//
//  Created by Goldmedal on 9/5/18.
//  Copyright © 2018 Goldmedal. All rights reserved.
//

import UIKit

class CreditDebitCell: UITableViewCell {
    
    @IBOutlet weak var lblReferenceNumber: UILabel!
    @IBOutlet weak var lblLedgerDesc: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblType: UILabel!
    @IBOutlet weak var lblAmount: UILabel!
    @IBOutlet weak var vwAdjustment: UIView!
    @IBOutlet weak var vwDownload: UIView!
    @IBOutlet weak var vwCnBreakup: UIView!
    @IBOutlet weak var vwMainContent: UIStackView!
    @IBOutlet weak var imvAdjustment: UIImageView!
    @IBOutlet weak var viewHeight: NSLayoutConstraint!
    @IBOutlet weak var imvCnBreakup: UIImageView!
    @IBOutlet weak var imvDownloadCn: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
