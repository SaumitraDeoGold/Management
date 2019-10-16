//
//  YearlySalesViewCell.swift
//  DealorsApp
//
//  Created by Goldmedal on 8/6/18.
//  Copyright © 2018 Goldmedal. All rights reserved.
//

import UIKit

class YearlySalesViewCell: UITableViewCell {
 
    @IBOutlet weak var lblDivision: UILabel!
    @IBOutlet weak var lblYsa: UILabel!
    @IBOutlet weak var lblSales: UILabel!
    @IBOutlet weak var lblOverallChg: UILabel!
    @IBOutlet weak var lblOverallPercent: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
