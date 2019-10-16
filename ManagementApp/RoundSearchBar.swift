//
//  RoundSearchBar.swift
//  DealorsApp
//
//  Created by Goldmedal on 8/17/18.
//  Copyright © 2018 Goldmedal. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class RoundSearchBar : UISearchBar
{
   @IBInspectable  var cornerRadius: CGFloat = 0
        {
        didSet {
            self.layer.cornerRadius = cornerRadius
        }
    }


   @IBInspectable  var borderWidth: CGFloat = 0
        {
        didSet {
            self.layer.borderWidth = borderWidth
        }
    }

   @IBInspectable  var borderColor: UIColor = UIColor.clear
        {
        didSet {
            self.layer.borderColor = borderColor.cgColor
        }
}
}

