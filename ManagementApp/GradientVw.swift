//
//  GradientVw.swift
//  ManagementApp
//
//  Created by Goldmedal on 20/03/19.
//  Copyright © 2019 Goldmedal. All rights reserved.
//

import Foundation
class GradientView: UIView {
    override open class var layerClass: AnyClass {
        return CAGradientLayer.classForCoder()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        let gradientLayer = layer as! CAGradientLayer
        gradientLayer.colors = [UIColor.white.cgColor, UIColor.black.cgColor]
    }
}
