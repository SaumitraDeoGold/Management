//
//  ComboSchemeViewCell.swift
//  DealorsApp
//
//  Created by Goldmedal on 10/18/18.
//  Copyright © 2018 Goldmedal. All rights reserved.
//

import UIKit

protocol CustomCellDelegate {
    func cellComboDetails(cell: ComboSchemeViewCell)
    func cellAddCombo(cell: ComboSchemeViewCell)
    func cellSubCombo(cell: ComboSchemeViewCell)
}



class ComboSchemeViewCell: UITableViewCell {
    
    @IBOutlet weak var lblComboName: UILabel!
    @IBOutlet weak var lblQty: UILabel!
    @IBOutlet weak var lblAmount: UILabel!
    @IBOutlet weak var lblCalculatedAmount: UILabel!
    @IBOutlet weak var btnAdd: UIButton!
    @IBOutlet weak var btnSubtract: UIButton!
    @IBOutlet weak var btnComboAdd: UIButton!
    @IBOutlet weak var vwComboAdd: RoundView!
    @IBOutlet weak var vwCalculateAdd: RoundView!
    var delegate: CustomCellDelegate?
    
    @IBAction func comboDetails(sender: AnyObject) {
        delegate?.cellComboDetails(cell: self)
    }
    
    @IBAction func addCombo(sender: AnyObject) {
        delegate?.cellAddCombo(cell: self)
    }
    
    @IBAction func subCombo(sender: AnyObject) {
        delegate?.cellSubCombo(cell: self)
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
