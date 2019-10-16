//
//  PromotionalViewCell.swift
//  DealorsApp
//
//  Created by Goldmedal on 11/28/18.
//  Copyright © 2018 Goldmedal. All rights reserved.
//

import UIKit

class PromotionalViewCell: UITableViewCell {
    
    @IBOutlet weak var lblPromoQty: UILabel!
    @IBOutlet weak var lblPromoDiscount: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
