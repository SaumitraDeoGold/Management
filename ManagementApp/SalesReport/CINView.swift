//
//  CINView.swift
//  GStar
//
//  Created by Goldmedal on 23/04/20.
//  Copyright © 2020 Goldmedal. All rights reserved.
//
import UIKit
@IBDesignable class CINView: BaseCustomView {

   
    @IBOutlet var lblCIN: UILabel!
   @IBOutlet var btnCancel: UIButton!
   
    var delegate: PopupDateDelegate?
    
    
    override func xibSetup() {
        super.xibSetup()
          
    }
  
    
    @IBAction func cancel_clicked(_ sender: UIButton) {
        delegate?.refreshApi?()
         
       }
     

}
 
