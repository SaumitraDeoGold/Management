//
//  ItemViewController.swift
//  DealorsApp
//
//  Created by Goldmedal on 5/23/18.
//  Copyright © 2018 Goldmedal. All rights reserved.
//

import UIKit

class ItemViewController: UIViewController {
    
    
    @IBOutlet weak var itemLabel: UILabel!
    var itemText: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        itemLabel.text = itemText!
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
