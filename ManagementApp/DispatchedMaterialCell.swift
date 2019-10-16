//
//  DispatchedMaterialCell.swift
//  DealorsApp
//
//  Created by Goldmedal on 4/4/18.
//  Copyright © 2018 Goldmedal. All rights reserved.
//

import UIKit

class DispatchedMaterialCell: UITableViewCell {
    
    @IBOutlet weak var lblItemName: UILabel!
    @IBOutlet weak var lblInvoiceNumber: UILabel!
    @IBOutlet weak var imvDownloadPdf: UIImageView!
    @IBOutlet weak var lblInvoiceDate: UILabel!
    @IBOutlet weak var lblAmnt: UILabel!
    @IBOutlet weak var lblDivision: UILabel!
    @IBOutlet weak var lblLrNo: UILabel!
    @IBOutlet weak var lblTransporter: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
