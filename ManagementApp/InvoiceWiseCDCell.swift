//
//  InvoiceWiseCDCell.swift
//  DealorsApp
//
//  Created by Goldmedal on 3/18/19.
//  Copyright © 2019 Goldmedal. All rights reserved.
//

import UIKit

class InvoiceWiseCDCell: UITableViewCell {
    
     @IBOutlet weak var lblDueDate: UILabel!
     @IBOutlet weak var lblCDPercent: UILabel!
     @IBOutlet weak var lblDueDays: UILabel!
     @IBOutlet weak var lblSavedAmount: UILabel!
     @IBOutlet weak var lblPayableAmount: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
