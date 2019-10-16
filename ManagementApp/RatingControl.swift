//
//  RatingControl.swift
//  DealorsApp
//
//  Created by Goldmedal on 4/19/18.
//  Copyright © 2018 Goldmedal. All rights reserved.
//

import UIKit

class RatingControl: UIStackView {

    override init(frame: CGRect) {
        super.init(frame: frame)
         setupButtons()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
         setupButtons()
    }
    
    private func setupButtons() {
        
        // Create the button
        let button = UIButton()
        button.backgroundColor = UIColor.red
        
        // Add constraints
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 30.0).isActive = true
        button.widthAnchor.constraint(equalToConstant: 30.0).isActive = true
        
        // Add the button to the stack
        addArrangedSubview(button)
    }
    
}
