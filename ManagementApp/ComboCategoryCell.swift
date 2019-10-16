//
//  ComboCategoryCell.swift
//  DealorsApp
//
//  Created by Goldmedal on 10/29/18.
//  Copyright © 2018 Goldmedal. All rights reserved.
//

import UIKit

class ComboCategoryCell: UITableViewCell {
    
     @IBOutlet weak var lblCategory: UILabel!
     @IBOutlet weak var lblCount: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
