//
//  PendingOrderCell.swift
//  DealorsApp
//
//  Created by Goldmedal on 4/7/18.
//  Copyright © 2018 Goldmedal. All rights reserved.
//

import UIKit

class PendingOrderCell: UITableViewCell {

  
    @IBOutlet weak var lblPendingOrderName: UILabel!
    @IBOutlet weak var lblPoNo: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblAmount: UILabel!
    @IBOutlet weak var lblQuantity: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
