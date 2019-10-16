//
//  DashAgingCell.swift
//  DealorsApp
//
//  Created by Goldmedal on 9/11/18.
//  Copyright © 2018 Goldmedal. All rights reserved.
//

import UIKit

class DashAgingCell: UITableViewCell {
    
    @IBOutlet weak var lblAmount: UILabel!
    @IBOutlet weak var lblPeriod: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
