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
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    override func viewDidLoad() {
        super.viewDidLoad()
        if webvwUrl == ""{
            webvwUrl = appDelegate.sendCin
        }
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
    
    func webView(_ webView: WKWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool
    {
        print(request)
        if requestIsDownloadable(request: request)
        {
            initializeDownload(download: request)


            return false
        }


        return true
    }


    func requestIsDownloadable( request: URLRequest) -> Bool
    {
        let requestString : NSString = (request.url?.absoluteString)! as NSString
        let fileType : String = requestString.pathExtension
        print(fileType)
        let isDownloadable : Bool = (
            (fileType.caseInsensitiveCompare("zip") == ComparisonResult.orderedSame) ||
            (fileType.caseInsensitiveCompare("rar") == ComparisonResult.orderedSame)
        )


        return isDownloadable
    }


    func initializeDownload( download: URLRequest)
    {
        let downloadAlertController : UIAlertController = UIAlertController(title: "Download Detected!", message: "Would you like to download this file?", preferredStyle: UIAlertControllerStyle.alert)

        let cancelAction : UIAlertAction = UIAlertAction(title: "Nope", style: UIAlertActionStyle.cancel, handler:
            {(alert: UIAlertAction!) in
                print("Download Cancelled.")
        })

        let okAction : UIAlertAction = UIAlertAction(title: "Yes!", style: UIAlertActionStyle.default, handler:
            {(alert: UIAlertAction!) in
                let downloadingAlertController : UIAlertController = UIAlertController(title: "Downloading...", message: "Please wait while your file downloads.\nThis alert will disappear when it's done.", preferredStyle: UIAlertControllerStyle.alert)
                self.present(downloadingAlertController, animated: true, completion: nil)

                do
                {
                    let urlToDownload : NSString = (download.url?.absoluteString)! as NSString
                    let url : NSURL = NSURL(string: urlToDownload as String)!
                    let urlData : NSData = try NSData.init(contentsOf: url as URL)

                    if urlData.length > 0
                    {
                        let paths : Array = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
                        let documentsDirectory : String = paths[0]
                        let filePath : String = String.localizedStringWithFormat("%@/%@", documentsDirectory, urlToDownload.lastPathComponent)

                        urlData.write(toFile: filePath, atomically: true)
                        downloadingAlertController.dismiss(animated: true, completion: nil)
                    }
                }
                catch let error as NSError
                {
                    print(error.localizedDescription)
                }
        })

        downloadAlertController.addAction(cancelAction)
        downloadAlertController.addAction(okAction)
        self.present(downloadAlertController, animated: true, completion: nil)
    }
    

}
