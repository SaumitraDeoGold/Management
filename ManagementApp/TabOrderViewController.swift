//
//  TabOrderViewController.swift
//  DealorsApp
//
//  Created by Goldmedal on 8/7/18.
//  Copyright © 2018 Goldmedal. All rights reserved.
//

import UIKit
import FirebaseAnalytics

class TabOrderViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
         Analytics.setScreenName("TAB ORDER", screenClass: "TabOrderViewController")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   
}
