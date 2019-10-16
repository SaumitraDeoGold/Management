//
//  CatalogueAddViewCell.swift
//  DealorsApp
//
//  Created by Goldmedal on 12/10/18.
//  Copyright © 2018 Goldmedal. All rights reserved.
//

import UIKit

protocol CatalogueQtyDelegate {
    func CatalogueTotalQty(cell: CatalogueAddViewCell)
}

class CatalogueAddViewCell: UITableViewCell {
    
    @IBOutlet weak var lblItemName: UILabel!
    @IBOutlet weak var lblMrp: UILabel!
    @IBOutlet weak var lblDlp: UILabel!
    @IBOutlet weak var lblDiscount: UILabel!
    @IBOutlet weak var lblPromoDiscount: UILabel!
    @IBOutlet weak var lblCartonQty: UILabel!
    @IBOutlet weak var lblOuterQty: UILabel!
    @IBOutlet weak var lblApprovedPendingOrder: UILabel!
    @IBOutlet weak var lblUnApprovedPendingOrder: UILabel!
    @IBOutlet weak var btnQty: UIButton!
    var delegate: CatalogueQtyDelegate?
    
    @IBAction func CatalogueAddQty(sender: AnyObject) {
        delegate?.CatalogueTotalQty(cell: self)
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
