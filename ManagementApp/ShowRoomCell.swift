//
//  ShowRoomCell.swift
//  DealorsApp
//
//  Created by Goldmedal on 15/11/18.
//  Copyright © 2018 Goldmedal. All rights reserved.
//

import UIKit

class ShowRoomCell: UITableViewCell {
    
    @IBOutlet weak var lblShowRoomName: UILabel!
    @IBOutlet weak var lblShowRoomAddress: UILabel!
    @IBOutlet weak var imvShowRoom: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
