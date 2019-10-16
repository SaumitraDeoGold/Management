//
//  CatalogueListCellTableViewCell.swift
//  DealorsApp
//
//  Created by Goldmedal on 8/1/18.
//  Copyright © 2018 Goldmedal. All rights reserved.
//

import UIKit

class CatalogueListCell: UITableViewCell {
    
  
    @IBOutlet weak var lblBrandName: UILabel!
    @IBOutlet weak var lblRangeName: UILabel!
    @IBOutlet weak var lblFromDate: UILabel!
    @IBOutlet weak var imvCatalogue: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
