//
//  CollectionViewCell.swift
//  G-Management
//
//  Created by Goldmedal on 25/02/19.
//  Copyright © 2019 Goldmedal. All rights reserved.
//

import Foundation
import UIKit
class CollectionViewCell : UICollectionViewCell{
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var vwColor: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}
