//
//  LimitDetailsCell.swift
//  ManagementApp
//
//  Created by Goldmedal on 18/10/19.
//  Copyright © 2019 Goldmedal. All rights reserved.
//

import Foundation
import UIKit
class LimitDetailsCell : UITableViewCell{
    
    @IBOutlet weak var lblPartyName: UILabel!
    @IBOutlet weak var lblAmount: UILabel!
    @IBOutlet weak var lblCreatedBy: UILabel!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var lblUsedAmt: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var vwCellContent: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}
