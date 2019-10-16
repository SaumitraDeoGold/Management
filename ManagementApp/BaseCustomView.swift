//
//  BaseCustomView.swift
//  AutoMowerConnect
//
//  Created by Aniket Deshmukh on 14/02/18.
//  Copyright © 2018 Husqvarna. All rights reserved.
//

import UIKit

class BaseCustomView: UIView {
    var view: UIView!

    var nibName: String {
        return String(describing: type(of: self))
    }

    func xibSetup() {
        view = loadViewFromNib()
        view.frame = bounds
        view.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        addSubview(view)
    }

    func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: self.classForCoder)
        let nib = UINib(nibName: nibName, bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil).first as! UIView
        return view
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibSetup()
    }
}
