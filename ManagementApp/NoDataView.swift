//
//  CaptchaController.swift
//  DealorsApp
//
//  Created by Goldmedal on 4/24/18.
//  Copyright © 2018 Goldmedal. All rights reserved.
//

import UIKit

public class NoDataView : UIView {
    
    @IBOutlet weak var vwOverlay:UIView?
 
    override init (frame : CGRect) {
        super.init(frame : frame)
        
    }
    
    convenience init () {
        self.init(frame:CGRect.zero)
        
    }
   
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        let _ = loadViewFromNib()
        
    }
    
    func loadViewFromNib() -> UIView {
        
        let bundle = Bundle.init(for: type(of: self))
        let nib = UINib(nibName: "NoDataView", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        view.frame = bounds
        view.autoresizingMask = [UIViewAutoresizing.flexibleWidth,UIViewAutoresizing.flexibleHeight]
        self.addSubview(view)
      
        return view
        
    }
    
}

