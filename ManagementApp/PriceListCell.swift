//
//  PriceListCell.swift
//  DealorsApp
//
//  Created by Goldmedal on 4/10/18.
//  Copyright © 2018 Goldmedal. All rights reserved.
//

import UIKit

class PriceListCell: UITableViewCell {

    @IBOutlet weak var imvPriceList: UIImageView!
    @IBOutlet weak var lblBrandName: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblRangeName: UILabel!
  
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
