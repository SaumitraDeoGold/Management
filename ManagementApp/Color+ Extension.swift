//
//  Color.swift
//  Digital Club
//
//  Created by Rahul Bangde on 15/07/18.
//  Copyright © 2018 Rahul Bangde. All rights reserved.
//

import UIKit

extension UIColor {
//    public class var goldan: UIColor {
//        if #available(iOS 11.0, *) {
//            return UIColor(named: "goldanColor") ?? .white
//        } else {
//            // Fallback on earlier versions
//            return UIColor.init(hexString: "B39052")
//        }
//    }
//
//    public class var darkGreen: UIColor {
//        if #available(iOS 11.0, *) {
//            return UIColor(named: "darkGreen") ?? .white
//        } else {
//            // Fallback on earlier versions
//            return UIColor.init(hexString: "004835")
//        }
//    }
    //darkGreen


    convenience init(hexString: String, alpha: CGFloat = 1.0) {
        let hexString: String = hexString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let scanner = Scanner(string: hexString)
        if (hexString.hasPrefix("#")) {
            scanner.scanLocation = 1
        }
        var color: UInt32 = 0
        scanner.scanHexInt32(&color)
        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask
        let red   = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue  = CGFloat(b) / 255.0
        self.init(red:red, green:green, blue:blue, alpha:alpha)
    }
}
