//
//  DashOutstandingCell.swift
//  DealorsApp
//
//  Created by Goldmedal on 9/11/18.
//  Copyright © 2018 Goldmedal. All rights reserved.
//

import UIKit

class DashOutstandingCell: UITableViewCell {
    
    @IBOutlet weak var lblTotal: UILabel!
    @IBOutlet weak var lblOverDue: UILabel!
    @IBOutlet weak var lblDue: UILabel!
    @IBOutlet weak var lblDivision: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
