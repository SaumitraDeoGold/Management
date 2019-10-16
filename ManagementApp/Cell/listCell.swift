//
//  listCell.swift
//  G-Management
//
//  Created by Goldmedal on 13/03/19.
//  Copyright © 2019 Goldmedal. All rights reserved.
//

import UIKit

class listCell: UITableViewCell {
    @IBOutlet weak var lblSubMenu: UILabel!
    
    var item: Reports?  {
        didSet {
            lblSubMenu?.text = item?.key
        }
    }
    
    static var nib:UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    static var identifier: String {
        return String(describing: self)
    }
    
}
