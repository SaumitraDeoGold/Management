//
//  PaddingLabel.swift
//  DealorsApp
//
//  Created by Goldmedal on 8/16/18.
//  Copyright © 2018 Goldmedal. All rights reserved.
//

import UIKit

@IBDesignable
class PaddingLabel: UILabel {
    
   @IBInspectable  var topInset: CGFloat = 0.0
  @IBInspectable   var bottomInset: CGFloat = 0.0
   @IBInspectable  var leftInset: CGFloat = 0.0
   @IBInspectable  var rightInset: CGFloat = 0.0
    
  override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets.init(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
        super.drawText(in: UIEdgeInsetsInsetRect(rect, insets))
    }
    
  override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + leftInset + rightInset,
                      height: size.height + topInset + bottomInset)
    }
}
