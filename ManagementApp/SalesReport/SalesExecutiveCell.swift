//
//  SalesExecutiveCell.swift
//  GStar
//
//  Created by Goldmedal on 02/04/20.
//  Copyright © 2020 Goldmedal. All rights reserved.
//

import UIKit

class SalesExecutiveCell: UITableViewCell {

    @IBOutlet weak var lblDivisionName: UILabel!
      
      @IBOutlet weak var lblTarget: UILabel!
      @IBOutlet weak var lblDealer: UILabel!
      @IBOutlet weak var lblSales: UILabel!
      @IBOutlet weak var lblOverallChg: UILabel!
      @IBOutlet weak var lblOverallChgPercent: UILabel!
      @IBOutlet weak var lblDealPercent: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
