//
//  CartRowCell.swift
//  DealorsApp
//
//  Created by Goldmedal on 11/19/18.
//  Copyright © 2018 Goldmedal. All rights reserved.
//

import UIKit

protocol ShowQtyDelegate {
    func ShowTotalQty(cell: CartRowCell)
}

class CartRowCell: UITableViewCell {
    
    @IBOutlet weak var lblItemCategory: UILabel!
    @IBOutlet weak var lblItemName: UILabel!
    @IBOutlet weak var btnEdtQty: UIButton!
    @IBOutlet weak var btnRemove: UIButton!
    @IBOutlet weak var lblItemGST: UILabel!
    @IBOutlet weak var lblItemBillingRate: UILabel!
    @IBOutlet weak var lblItemDiscountAmnt: UILabel!
    @IBOutlet weak var lblItemPromoAmnt: UILabel!
    @IBOutlet weak var lblItemAmount: UILabel!
   
   var delegate: ShowQtyDelegate?
   
    @IBAction func addQty(sender: AnyObject) {
        delegate?.ShowTotalQty(cell: self)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
