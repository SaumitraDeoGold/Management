//
//  OldDashboardController.swift
//  ManagementApp
//
//  Created by Goldmedal on 20/05/19.
//  Copyright © 2019 Goldmedal. All rights reserved.
//

import UIKit

class OldDashboardController: UIViewController {
    
    @IBOutlet weak var backButton: UIBarButtonItem!
    
    var tabs = [
        ViewPagerTab(title: "SALES", image: UIImage(named: "dashboard_sales_icon")),
        ViewPagerTab(title: "ORDERS", image: UIImage(named: "dashboard_order_icon")),
        ViewPagerTab(title: "PAYMENT", image: UIImage(named: "dashboard_outstanding_icon")),
        ViewPagerTab(title: "SCHEME", image: UIImage(named: "dashboard_scheme_icon")),
        ]
    
    var viewPager:ViewPagerController!
    var options:ViewPagerOptions!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let imageView = UIImageView(image:UIImage(named: "dashboard_logo.png"))
        self.navigationItem.titleView = imageView
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.edgesForExtendedLayout = UIRectEdge.init(rawValue: 0)
        
        options = ViewPagerOptions(viewPagerWithFrame: self.view.bounds)
        options.tabType = ViewPagerTabType.imageWithText
        options.tabViewImageSize = CGSize(width: 20, height: 20)
        options.tabViewTextFont = UIFont.systemFont(ofSize: 13)
        options.isEachTabEvenlyDistributed = true
        options.tabViewBackgroundDefaultColor = UIColor.white
        
        if #available(iOS 11.0, *) {
            options.tabIndicatorViewBackgroundColor = UIColor.init(named: "ColorRed")!
        } else {
            options.tabIndicatorViewBackgroundColor = UIColor.red
        }
        options.fitAllTabsInView = true
        options.tabViewPaddingLeft = 20
        options.tabViewPaddingRight = 20
        options.isTabHighlightAvailable = false
        
        viewPager = ViewPagerController()
        viewPager.options = options
        viewPager.dataSource = self as ViewPagerControllerDataSource
        viewPager.delegate = self as ViewPagerControllerDelegate
        
        self.addChildViewController(viewPager)
        self.view.addSubview(viewPager.view)
        viewPager.didMove(toParentViewController: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func back_Button(_ sender: UIBarButtonItem) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
     
    
}

extension OldDashboardController: ViewPagerControllerDataSource {
    
    func numberOfPages() -> Int {
        return tabs.count
    }
    
    func viewControllerAtPosition(position:Int) -> UIViewController {
        var vc = UIViewController()
        if position == 0
        {
            vc = self.storyboard?.instantiateViewController(withIdentifier: "TabSales") as! TabSalesViewController 
        }
        else if position == 1
        {
            vc = self.storyboard?.instantiateViewController(withIdentifier: "TabOrder") as! TabOrderViewController
        }
        else if position == 2
        {
            vc = self.storyboard?.instantiateViewController(withIdentifier: "TabOutstanding") as! TabOutstandingViewController
        }
        else if position == 3
        {
            vc = self.storyboard?.instantiateViewController(withIdentifier: "TabScheme") as! TabSchemeViewController
        }
        return vc
    }
    
    func tabsForPages() -> [ViewPagerTab] {
        return tabs
    }
    
    func startViewPagerAtIndex() -> Int {
        return 0
    }
}

extension OldDashboardController: ViewPagerControllerDelegate {
    
    func willMoveToControllerAtIndex(index:Int) {
        print("Moving to page \(index)")
    }
    
    func didMoveToControllerAtIndex(index: Int) {
        print("Moved to page \(index)")
    }
}
