//
//  CategorySalesView.swift
//  DealorsApp
//
//  Created by Goldmedal on 8/4/18.
//  Copyright © 2018 Goldmedal. All rights reserved.
//

import UIKit
@IBDesignable class CategorySalesView: BaseCustomView {
    var tabs = [
        ViewPagerTab(title: "", image: UIImage(named: "dashboard_sales_icon")),
        ViewPagerTab(title: "", image: UIImage(named: "dashboard_order_icon")),
        ViewPagerTab(title: "", image: UIImage(named: "dashboard_outstanding_icon")),
        ViewPagerTab(title: "", image: UIImage(named: "dashboard_scheme_icon")),
        ViewPagerTab(title: "", image: UIImage(named: "dashboard_scheme_icon")),
        ]
    
    var viewPager:ViewPagerController!
    var options:ViewPagerOptions!
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        // Do any additional setup after loading the view.
     //   parentViewController?.edgesForExtendedLayout = UIRectEdge.init(rawValue: 0)
        
     //  options = ViewPagerOptions(viewPagerWithFrame: self.view.bounds)
   //     options.tabType = ViewPagerTabType.imageWithText
   //     options.tabViewImageSize = CGSize(width: 20, height: 20)
    //    options.tabViewTextFont = UIFont.systemFont(ofSize: 13)
    //    options.isEachTabEvenlyDistributed = true
    //    options.tabViewBackgroundDefaultColor = UIColor.white
     //   options.tabIndicatorViewBackgroundColor = UIColor.init(named: "ColorRed")!
     //   options.fitAllTabsInView = true
    //    options.tabViewPaddingLeft = 20
    //    options.tabViewPaddingRight = 20
     //   options.isTabHighlightAvailable = false
        
    //    viewPager = ViewPagerController()
    //    viewPager.options = options
     //   viewPager.dataSource = self as! ViewPagerControllerDataSource
    //    viewPager.delegate = self as! ViewPagerControllerDelegate
        
     //   parentViewController?.addChildViewController(viewPager)
     //   parentViewController?.view.addSubview(viewPager.view)
     //   viewPager.didMove(toParentViewController: parentViewController)
        
    }
    
    
}

