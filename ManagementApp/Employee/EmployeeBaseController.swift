//
//  EmployeeBaseController.swift
//  ManagementApp
//
//  Created by Goldmedal on 04/03/20.
//  Copyright © 2020 Goldmedal. All rights reserved.
//

import UIKit

class EmployeeBaseController: UIViewController {

    var tabs = [
        ViewPagerTab(title: "EMPLOYEE", image: UIImage(named: ""))
        //ViewPagerTab(title: "ATTENDANCE", image: UIImage(named: ""))
    ]
    
    var viewPager:ViewPagerController!
    var options:ViewPagerOptions!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let imageView = UIImageView(image:UIImage(named: "dashboard_logo.png"))
        self.navigationItem.titleView = imageView
        self.navigationController?.setNavigationBarHidden(false, animated: true)
         
        
        //addSlideMenuButton()
        
        // Do any additional setup after loading the view.
        self.edgesForExtendedLayout = UIRectEdge.init(rawValue: 0)
        
        options = ViewPagerOptions(viewPagerWithFrame: self.view.bounds)
        options.tabType = ViewPagerTabType.basic
        options.tabViewImageSize = CGSize(width: 20, height: 20)
        options.tabViewTextFont = UIFont(name: "Roboto-Regular", size: 12)!
        options.tabViewTextHighlightColor = UIColor.white
        options.isEachTabEvenlyDistributed = true
        options.tabViewBackgroundHighlightColor = UIColor.init(named: "DashboardHeader")!
        options.isTabHighlightAvailable = true
        options.tabViewBackgroundDefaultColor = UIColor.init(named: "Primary")!
        options.tabViewTextDefaultColor = UIColor.black
        options.isTabIndicatorAvailable = false
        options.fitAllTabsInView = true
        options.tabViewPaddingLeft = 20
        options.tabViewPaddingRight = 20
        //options.viewPagerTransitionStyle = .pageCurl
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
    
}

extension EmployeeBaseController: ViewPagerControllerDataSource {
    
    func numberOfPages() -> Int {
        return tabs.count
    }
    
    func viewControllerAtPosition(position:Int) -> UIViewController {
        var vc = UIViewController()
        if position == 0
        {
            vc = self.storyboard?.instantiateViewController(withIdentifier: "EmployeeDataController") as! EmployeeDataController
        }
        else if position == 1
        {
            vc = self.storyboard?.instantiateViewController(withIdentifier: "Attendance") as! AttendanceViewController
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

extension EmployeeBaseController: ViewPagerControllerDelegate {
    func willMoveToControllerAtIndex(index:Int) {
        print("Moving to page \(index)")
    }
    
    func didMoveToControllerAtIndex(index: Int) {
        print("Moved to page \(index)")
    }
}
