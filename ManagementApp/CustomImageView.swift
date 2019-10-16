//
//  CustomImageView.swift
//  DealorsApp
//
//  Created by Rahul Bangde on 19/08/18.
//  Copyright © 2018 Goldmedal. All rights reserved.
//

import UIKit

@IBDesignable
class CustomImageView: UIImageView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    @IBInspectable override var tintColor: UIColor! {
        didSet {
            guard let imageNew = self.image else {
               return
            }
             self.image = imageNew.withRenderingMode(.alwaysTemplate)
        }
    }

}
