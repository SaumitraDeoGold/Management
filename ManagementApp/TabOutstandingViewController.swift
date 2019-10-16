//
//  TabOutstandingViewController.swift
//  DealorsApp
//
//  Created by Goldmedal on 8/7/18.
//  Copyright © 2018 Goldmedal. All rights reserved.
//

import UIKit
import FirebaseAnalytics

class TabOutstandingViewController: UIViewController {
    
     @IBOutlet weak var btnDownloadPdf: UIButton!
     var strPdfUrl = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
         Analytics.setScreenName("TAB PAYMENT", screenClass: "TabOutstandingViewController")

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func clicked_download_pdf(_ sender: UIButton) {
        guard let url = URL(string: strPdfUrl) else {
            
            var alert = UIAlertView(title: "Error", message: "Invalid Pdf", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
            
            return
        }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    

}
