//
//  CatalogueListItemCell.swift
//  DealorsApp
//
//  Created by Goldmedal on 12/8/18.
//  Copyright © 2018 Goldmedal. All rights reserved.
//

import UIKit

protocol CatalogueListDelegate: AnyObject {
    func btnAddTapped(cell: CatalogueListItemCell)
}


class CatalogueListItemCell: UITableViewCell {
    
    @IBOutlet weak var lblCatalogueCode: UILabel!
    @IBOutlet weak var lblCatalogueName: UILabel!
    @IBOutlet weak var btnAdd: UIButton!
    weak var delegate: CatalogueListDelegate?
    
    //3. assign this action to close button
    @IBAction func btnAddClicked(sender: AnyObject) {
        delegate?.btnAddTapped(cell: self)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
