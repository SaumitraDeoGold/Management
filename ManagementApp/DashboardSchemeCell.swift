//
//  DashboardSchemeCell.swift
//  DealorsApp
//
//  Created by Goldmedal on 8/7/18.
//  Copyright © 2018 Goldmedal. All rights reserved.
//

import UIKit

class DashboardSchemeCell: UITableViewCell {

    @IBOutlet weak var lblNextSlab: UILabel!
    @IBOutlet weak var lblCurrentSlab: UILabel!
    @IBOutlet weak var lblNetAmount: UILabel!
    @IBOutlet weak var lblSchemeName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
