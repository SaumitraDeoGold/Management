//
//  ComplexCell.swift
//  ManagementApp
//
//  Created by Goldmedal on 19/08/19.
//  Copyright © 2019 Goldmedal. All rights reserved.
//

import Foundation
import UIKit
class ComplexCell : UICollectionViewCell{
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var contentLabelTwo: UILabel!
    @IBOutlet weak var labelHeightConstraintOne: NSLayoutConstraint!
    @IBOutlet weak var labelHeightConstraintTwo: NSLayoutConstraint!
    @IBOutlet weak var vwColor: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}
