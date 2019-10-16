//
//  CatSalesCell.swift
//  DealorsApp
//
//  Created by Goldmedal on 8/6/18.
//  Copyright © 2018 Goldmedal. All rights reserved.
//

import UIKit

class CatSalesCell: UITableViewCell {
    
    @IBOutlet weak var lblCategoryName: UILabel!
    @IBOutlet weak var lblAmount: UILabel!
    @IBOutlet weak var lblPercentage: UILabel!
     @IBOutlet weak var vwColor: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
