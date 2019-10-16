//
//  ShadowCardVw.swift
//  ManagementApp
//
//  Created by Goldmedal on 19/03/19.
//  Copyright © 2019 Goldmedal. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class ShadowCardVw : UIView
{
    
    @IBInspectable   var cornerRadius: CGFloat = 0
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
    
    @IBInspectable var borderColor: UIColor = UIColor.clear
        {
        didSet {
            self.layer.borderColor = borderColor.cgColor
        }
    }
    
    @IBInspectable   var shadowColor: UIColor = UIColor.clear
        {
        didSet {
            self.layer.shadowColor = shadowColor.cgColor
        }
    }
    
    @IBInspectable  var shadowOffset: CGSize = CGSize(width: 0, height: 0)
        {
        didSet {
            self.layer.shadowOffset = shadowOffset
        }
    }
    
    @IBInspectable   var shadowRadius: CGFloat = 0
        {
        didSet {
            self.layer.shadowRadius = shadowRadius
        }
    }
    
    @IBInspectable  var masksToBounds: Bool = false
        {
        didSet {
            self.layer.masksToBounds = masksToBounds
        }
    }
    
    @IBInspectable   var shadowOpacity: CGFloat = 0
        {
        didSet {
            self.layer.shadowOpacity = Float(shadowOpacity)
        }
    }
    
//    @IBInspectable var gradientColor1: UIColor = UIColor.white {
//        didSet{
//            self.setGradient()
//        }
//    }
//    
//    @IBInspectable var gradientColor2: UIColor = UIColor.white {
//        didSet{
//            self.setGradient()
//        }
//    }
//    
//    @IBInspectable var gradientStartPoint: CGPoint = .zero {
//        didSet{
//            self.setGradient()
//        }
//    }
//    
//    @IBInspectable var gradientEndPoint: CGPoint = CGPoint(x: 0, y: 1) {
//        didSet{
//            self.setGradient()
//        }
//    }
//    
//    private func setGradient()
//    {
//        let gradientLayer = CAGradientLayer()
//        gradientLayer.colors = [self.gradientColor1.cgColor, self.gradientColor2.cgColor]
//        gradientLayer.startPoint = self.gradientStartPoint
//        gradientLayer.endPoint = self.gradientEndPoint
//        gradientLayer.frame = self.bounds
//        if let topLayer = self.layer.sublayers?.first, topLayer is CAGradientLayer
//        {
//            topLayer.removeFromSuperlayer()
//        }
//        self.layer.addSublayer(gradientLayer)
//    }
    
}


