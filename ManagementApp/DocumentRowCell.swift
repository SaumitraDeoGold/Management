//
//  DocumentRowCell.swift
//  DealorsApp
//
//  Created by Goldmedal on 8/13/18.
//  Copyright © 2018 Goldmedal. All rights reserved.
//

import UIKit

class DocumentRowCell: UITableViewCell {

    @IBOutlet weak var imvDocument: UIImageView!
    @IBOutlet weak var lblToDate: UILabel!
    @IBOutlet weak var lblFromDate: UILabel!
    @IBOutlet weak var lblDocumentName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
