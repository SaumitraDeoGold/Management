//
//  OutsPaymentSummaryCell.swift
//  DealorsApp
//
//  Created by Goldmedal on 3/11/19.
//  Copyright © 2019 Goldmedal. All rights reserved.
//

import UIKit

protocol TransactionRetryDelegate: AnyObject {
    func btnRetry(cell: OutsPaymentSummaryCell)
    func btnRaiseDispute(cell: OutsPaymentSummaryCell)
}

class OutsPaymentSummaryCell: UITableViewCell {
    @IBOutlet weak var btnRetry: UIButton!
    @IBOutlet weak var btnRaiseDispute: UIButton!
    @IBOutlet weak var lblReceipt: UILabel!
    @IBOutlet weak var lblOrderNumber: UILabel!
    @IBOutlet weak var lblVoucherdt: UILabel!
    @IBOutlet weak var lblDiscoumtamt: UILabel!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var lblTotalamt: UILabel!
    @IBOutlet weak var lblSavedamt: UILabel!
    weak var delegate: TransactionRetryDelegate?
    
    
    @IBAction func btnRetry(sender: AnyObject) {
        delegate?.btnRetry(cell: self)
      
    }
    
    @IBAction func btnRaiseDispute(sender: AnyObject) {
       
        delegate?.btnRaiseDispute(cell: self)
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
