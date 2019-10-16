//
//  NDADetailCell.swift
//  ManagementApp
//
//  Created by Goldmedal on 26/03/19.
//  Copyright © 2019 Goldmedal. All rights reserved.
//

import Foundation
import UIKit
class NDADetailCell : UITableViewCell{

    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblSalesEx: UILabel!
    @IBOutlet weak var lblAmount: UILabel!
    @IBOutlet weak var lblJoiningDate: UILabel!
    @IBOutlet weak var vwCellContent: UIView!
    
    @IBOutlet weak var lblNameTitle: UILabel!
    @IBOutlet weak var lblpercentage: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}
