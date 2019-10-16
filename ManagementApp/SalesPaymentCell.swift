//
//  SalesPaymentCell.swift
//  DealorsApp
//
//  Created by Goldmedal on 4/7/18.
//  Copyright © 2018 Goldmedal. All rights reserved.
//

import UIKit

class SalesPaymentCell: UITableViewCell {

    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblDivision: UILabel!
    @IBOutlet weak var lblAmount: UILabel!
    @IBOutlet weak var lblPaymentType: UILabel!
    @IBOutlet weak var imvSalesAdjustment: UIImageView!
    
   
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
