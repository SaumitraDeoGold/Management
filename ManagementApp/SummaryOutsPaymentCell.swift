//
//  SummaryOutsPaymentCell.swift
//  DealorsApp
//
//  Created by Goldmedal on 2/28/19.
//  Copyright © 2019 Goldmedal. All rights reserved.
//

import UIKit

class SummaryOutsPaymentCell: UITableViewCell {
    
     @IBOutlet weak var lblSlno: UILabel!
     @IBOutlet weak var lblInvoiceId: UILabel!
     @IBOutlet weak var lblPayableAmount: UILabel!
     @IBOutlet weak var lblTotalAmount: UILabel!
     @IBOutlet weak var lblSavedAmount: UILabel!
    @IBOutlet weak var lblSavedPercent: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
