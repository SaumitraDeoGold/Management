//
//  TechSpecsRowCell.swift
//  DealorsApp
//
//  Created by Goldmedal on 5/5/18.
//  Copyright © 2018 Goldmedal. All rights reserved.
//

import UIKit

class TechSpecsRowCell: UITableViewCell {

  
    @IBOutlet weak var imvTechSpecs: UIImageView!
    @IBOutlet weak var lblCode: UILabel!
    @IBOutlet weak var lblName: UILabel!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
