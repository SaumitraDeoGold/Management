//
//  UIViewExtension.swift
//  Mharo Sikar
//
//  Created by Rahul Bangde on 26/02/18.
//  Copyright © 2018 Rahul Bangde. All rights reserved.
//

import Foundation
import UIKit
extension UIView {
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
}
