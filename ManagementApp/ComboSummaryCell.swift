//
//  ComboSummaryCell.swift
//  DealorsApp
//
//  Created by Goldmedal on 9/25/18.
//  Copyright © 2018 Goldmedal. All rights reserved.
//

import UIKit

class ComboSummaryCell: UITableViewCell {
    
    @IBOutlet weak var lblProductName: UILabel!
    @IBOutlet weak var lblOrdered: UILabel!
    @IBOutlet weak var lblReceived: UILabel!
    @IBOutlet weak var lblBalance: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
