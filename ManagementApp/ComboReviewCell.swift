//
//  ComboReviewCell.swift
//  DealorsApp
//
//  Created by Goldmedal on 11/5/18.
//  Copyright © 2018 Goldmedal. All rights reserved.
//

import UIKit

class ComboReviewCell: UITableViewCell {
     @IBOutlet weak var lblComboItemName: UILabel!
     @IBOutlet weak var lblComboItemNo: UILabel!
     @IBOutlet weak var lblComboRange: UILabel!
     @IBOutlet weak var lblComboQty: UILabel!
   
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

