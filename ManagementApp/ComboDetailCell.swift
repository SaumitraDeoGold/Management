//
//  ComboDetailCell.swift
//  DealorsApp
//
//  Created by Goldmedal on 10/30/18.
//  Copyright © 2018 Goldmedal. All rights reserved.
//

import UIKit

class ComboDetailCell: UITableViewCell {
    
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblQty: UILabel!
    @IBOutlet weak var lblDlp: UILabel!
    @IBOutlet weak var lblAmount: UILabel!
    @IBOutlet weak var lblComboNumber: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
