//
//  ActiveSchemeCell.swift
//  DealorsApp
//
//  Created by Goldmedal on 4/7/18.
//  Copyright © 2018 Goldmedal. All rights reserved.
//

import UIKit

class ActiveSchemeCell: UITableViewCell {
    
    @IBOutlet weak var imvActiveScheme: UIImageView!
    @IBOutlet weak var lblSchemeName: UILabel!
    @IBOutlet weak var lblSchemeType: UILabel!
    @IBOutlet weak var lblFromDate: UILabel!
   
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
