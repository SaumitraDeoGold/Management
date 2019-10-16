//
//  OrderSummaryCell.swift
//  DealorsApp
//
//  Created by Goldmedal on 12/1/18.
//  Copyright © 2018 Goldmedal. All rights reserved.
//

import UIKit

class OrderSummaryCell: UITableViewCell {

    @IBOutlet weak var imvPdf: UIImageView!
    @IBOutlet weak var lblPoNumber: UILabel!
    @IBOutlet weak var lblPoTime: UILabel!
    @IBOutlet weak var lblPoDate: UILabel!
    @IBOutlet weak var lblOrderAmount: UILabel!
    @IBOutlet weak var lblLogStatus: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
