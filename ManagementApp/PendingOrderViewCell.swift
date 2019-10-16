//
//  PendingOrderViewCell.swift
//  DealorsApp
//
//  Created by Goldmedal on 8/7/18.
//  Copyright © 2018 Goldmedal. All rights reserved.
//

import UIKit

class PendingOrderViewCell: UITableViewCell {

    @IBOutlet var lblCategory: UILabel!
     @IBOutlet var vwColor: UIView!
    @IBOutlet var lblAmount: UILabel!
    @IBOutlet var lblPercentage: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
