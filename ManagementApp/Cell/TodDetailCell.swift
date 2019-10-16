//
//  TodDetailCell.swift
//  DealorsApp
//
//  Created by Goldmedal on 7/15/19.
//  Copyright © 2019 Goldmedal. All rights reserved.
//

import UIKit

class TodDetailCell: UITableViewCell {
    
    @IBOutlet weak var lblYearlyTarget: UILabel!
    @IBOutlet weak var lblYearlySales: UILabel!
    @IBOutlet weak var lblGroupName: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
