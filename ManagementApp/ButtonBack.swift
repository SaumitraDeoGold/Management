//
//  ButtonBack.swift
//  Mharo Sikar
//
//  Created by Rahul Bangde on 26/02/18.
//  Copyright © 2018 Rahul Bangde. All rights reserved.
//

import UIKit

class ButtonBack: UIButton {

    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
       
     
        self.addTarget(self, action: #selector(navigateBackView), for: .touchUpInside)
    }
    
    @objc func navigateBackView() {
        self.parentViewController?.navigationController?.popViewController(animated: true)
    }
    

}

