//
//  PendingOrderView.swift
//  DealorsApp
//
//  Created by Goldmedal on 8/7/18.
//  Copyright © 2018 Goldmedal. All rights reserved.
//

import Foundation
import UIKit
@IBDesignable class PendingOrderView: BaseCustomView {
    
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        var vc = UIViewController()
        vc = parentViewController?.storyboard?.instantiateViewController(withIdentifier: "PendingOrderView") as! PendingOrderViewController
        
        parentViewController?.addChildViewController(vc)
        self.addSubview(vc.view)
        vc.didMove(toParentViewController: parentViewController)
    }
    
    
}
