//
//  VideoViewCell.swift
//  DealorsApp
//
//  Created by Goldmedal on 9/7/18.
//  Copyright © 2018 Goldmedal. All rights reserved.
//

import UIKit

class VideoViewCell: UITableViewCell {

    @IBOutlet weak var vwMainVideo: UIView!
    @IBOutlet weak var lblVideoDuration: UILabel!
    @IBOutlet weak var imvThumbnail: UIImageView!
    @IBOutlet weak var lblVideoDetail: UILabel!
    @IBOutlet weak var lblVideoName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
