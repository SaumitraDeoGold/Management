//
//  CaptchaController.swift
//  DealorsApp
//
//  Created by Goldmedal on 4/24/18.
//  Copyright © 2018 Goldmedal. All rights reserved.
//

import UIKit

public class CaptchaView : UIView {
    
    @IBOutlet weak var lblCaptcha: UILabel!
    @IBOutlet weak var edtCaptcha: UITextField!
    @IBOutlet weak var imvReload: UIImageView!
    
    var isCaptchaCorrect = false
    
   
    var  ar1 = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
    
    var Captcha_string = ""
    
    var i1 = 0
    var i2 = 0
    var i3 = 0
    var i4 = 0
    var i5 = 0
    
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
        let nib = UINib(nibName: "CaptchaView", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        view.frame = bounds
        view.autoresizingMask = [UIViewAutoresizing.flexibleWidth,UIViewAutoresizing.flexibleHeight]
        addSubview(view)
        
        
        reload_captcha()
       // edtCaptcha.becomeFirstResponder()
        
        let tabReload = UITapGestureRecognizer(target: self, action: #selector(CaptchaView.tapFunction))
        imvReload.addGestureRecognizer(tabReload)
        
        return view

    }
    
    
    @objc func tapFunction(sender:UITapGestureRecognizer) {
        print("tap working")
        
        reload_captcha()
        
    }
    
    func reload_captcha() {
            i1 = Int(arc4random_uniform(62))
            print("RANDOM INDEX:\(i1) ")
            i2 = Int(arc4random_uniform(62))
            print("RANDOM INDEX:\(i2) ")
            i3 = Int(arc4random_uniform(62))
            print("RANDOM INDEX:\(i3) ")
            i4 = Int(arc4random_uniform(62))
            print("RANDOM INDEX:\(i4) ")
            i5 = Int(arc4random_uniform(62))
            print("RANDOM INDEX:\(i5) ")
        
        if(i1>0 && i2>0 && i3>0 && i4>0 && i5>0){
            Captcha_string = "\(ar1[i1 - 1])\(ar1[i2 - 1])\(ar1[i3 - 1])\(ar1[i4 - 1])\(ar1[i5 - 1])"
            print(" Captcha String : \(Captcha_string)")
            lblCaptcha.text = Captcha_string
        }
    }
    
    func checkCaptcha() -> Bool {
        var test = false
        
        if(edtCaptcha.text?.trimmingCharacters(in: NSCharacterSet.whitespaces) == lblCaptcha.text?.trimmingCharacters(in: NSCharacterSet.whitespaces))
        {
            test = true
        }else{
            test = false
        }
        
        return test
    }

}
