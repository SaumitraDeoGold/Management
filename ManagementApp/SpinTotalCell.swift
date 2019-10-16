//
//  SpinTotalCell.swift
//  DealorsApp
//
//  Created by Goldmedal on 10/17/18.
//  Copyright © 2018 Goldmedal. All rights reserved.
//

import UIKit

class SpinTotalCell: UITableViewCell {
    
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblAmount: UILabel!
    @IBOutlet weak var lblSpinNumber: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
