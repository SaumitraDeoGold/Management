//
//  WebViewController.swift
//  DealorsApp
//
//  Created by Goldmedal on 24/10/18.
//  Copyright © 2018 Goldmedal. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: BaseViewController, WKNavigationDelegate {
    
    @IBOutlet weak var backBtn: UIButton!
     @IBOutlet weak var webView: WKWebView!

     var strUrl = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let url = URL(string: strUrl)!
        webView.load(URLRequest(url: url))
    }
    
    @IBAction func clicked_back(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
