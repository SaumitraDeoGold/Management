//
//  ComboSchemeHeaderCell.swift
//  DealorsApp
//
//  Created by Goldmedal on 10/20/18.
//  Copyright © 2018 Goldmedal. All rights reserved.
//

import UIKit

class ComboSchemeHeaderCell: UITableViewCell {

     @IBOutlet weak var lblComboGroupName: UILabel!
     @IBOutlet weak var btnCompare: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
