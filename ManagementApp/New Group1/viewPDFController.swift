//
//  viewPDFController.swift
//  ManagementApp
//
//  Created by Goldmedal on 07/12/19.
//  Copyright © 2019 Goldmedal. All rights reserved.
//

import UIKit
import WebKit

class viewPDFController: UIViewController, WKNavigationDelegate {
    
    //Outlets...
    @IBOutlet var webView: WKWebView!

    //Declarations...
    var webvwUrl = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let url = URL(string: webvwUrl)!
        webView.load(URLRequest(url: url))
        ViewControllerUtils.sharedInstance.showLoader()
    }
    
    override func loadView() {
        webView = WKWebView()
        webView.navigationDelegate = self
        view = webView
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        //title = webView.title
        ViewControllerUtils.sharedInstance.removeLoader()
    }
    
//    func webViewDidFinishLoad(webView : UIWebView) {
//        //Page is loaded do what you want
//        ViewControllerUtils.sharedInstance.removeLoader()
//    }
    

}
