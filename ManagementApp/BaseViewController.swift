//
//  BaseViewController.swift
//  AKSwiftSlideMenu
//
//  Created by Ashish on 21/09/15.
//  Copyright (c) 2015 Kode. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController, SlideMenuDelegate, PopupDateDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func slideMenuItemSelectedAtIndex(_ sectionIndex: Int,_ itemIndex: Int) {
        let topViewController : UIViewController = self.navigationController!.topViewController!
        print("View Controller is : \(topViewController) \n", terminator: "")
        switch(sectionIndex,itemIndex){
        case (-2,-2):
            print("MyProfile\n", terminator: "")
            
            self.openViewControllerBasedOnIdentifier("MyProfile")
            
            break
        case (0,-1):
            print("Dashboard\n", terminator: "")

            self.openViewControllerBasedOnIdentifier("Dashboard")
            
            break
//        case (1,0):
//            print("Order placed\n", terminator: "")
//
//            self.openViewControllerBasedOnIdentifier("Order")
//
//            break
//
//        case (1,1):
//            print("Order summary\n", terminator: "")
//
//            self.openViewControllerBasedOnIdentifier("OrderSummary")
//
//            break
//
//        case (2,0):
//            print("Star rewards program\n", terminator: "")
//
//            self.openViewControllerBasedOnIdentifier("StarReward")
//
//            break
//
//        case (2,1):
//            print("Discover the world\n", terminator: "")
//
//          //  self.openViewControllerBasedOnIdentifier("DiscoverTheWorld")
//
//            break
//
//        case (2,2):
//            print("Documents\n", terminator: "")
//
//            self.openViewControllerBasedOnIdentifier("Documents")
//
//            break
            
        case (1,0):
            print("Division wise sales\n", terminator: "")
            
            self.openViewControllerBasedOnIdentifier("DivisionWiseSalesViewController")
            
            break
          
            
        case (1,1):
            print("Dealer Appointment ViewController\n", terminator: "")
            
            self.openViewControllerBasedOnIdentifier("DealerAppointmentViewController")
            
            break
        case (1,2):
            print("Outstanding Above ViewController\n", terminator: "")
            
            self.openViewControllerBasedOnIdentifier("OutstandingAboveController")
            
            break
        case (1,3):
            print("Sales n Purchases\n", terminator: "")
            
            self.openViewControllerBasedOnIdentifier("BranchWiseSalesPurchase")
            
            break
            
        case (1,4):
            print("Dealer Search\n", terminator: "")
            
            self.openViewControllerBasedOnIdentifier("SearchDealer")
            
            break
            
        case (1,5):
            print("Yearly Compare\n", terminator: "")
            
            self.openViewControllerBasedOnIdentifier("YearlyCompareController")
            
            break
            
        case (1,6):
            print("Category Compare\n", terminator: "")
            
            self.openViewControllerBasedOnIdentifier("CategoryWiseCompareController")
            
            break
            
        case (1,7):
            print("Branchwise Outstanding\n", terminator: "")
            
            self.openViewControllerBasedOnIdentifier("AccountsViewController")
            
            break
            
//        case (1,6):
//            print("Complex View\n", terminator: "")
//
//            self.openViewControllerBasedOnIdentifier("ComplexViewController")
//
//            break
            
        case (2,0):
            print("Price list\n", terminator: "")
            
            self.openViewControllerBasedOnIdentifier("PriceList")
            
            break
            
        case (2,1):
            print("Catalogue\n", terminator: "")
            
            self.openViewControllerBasedOnIdentifier("CatalogueList")
            
            break
            
        case (2,2):
            print("Active scheme\n", terminator: "")
            
            self.openViewControllerBasedOnIdentifier("ActiveScheme")
            
            break
            
        case (2,3):
            print("Policy\n", terminator: "")
            
            self.openViewControllerBasedOnIdentifier("Policy")
            
            break
            
        case (2,4):
            print("TechnicalSpecs\n", terminator: "")
            
            self.openViewControllerBasedOnIdentifier("TechnicalSpecs")
            
            break
            
//        case (5,0):
//            print("Enquiry\n", terminator: "")
//
//            self.openViewControllerBasedOnIdentifier("Enquiry")
//
//            break
//
//        case (6,-1):
//            print("call service executive\n", terminator: "")
//
//           //self.openViewControllerBasedOnIdentifier("CallServiceExecutive")
//
//            break
            
            
//        case (7,0):
//            print("Combo Summary Report\n", terminator: "")
//
//            self.openViewControllerBasedOnIdentifier("ComboSummaryController")
//
//            break
//
//        case (7,1):
//            print("Spin wheel\n", terminator: "")
//
//             self.openViewControllerBasedOnIdentifier("SpinWheel")
//           // self.openViewControllerBasedOnIdentifier("ComboScheme")
//
//            break
//
//        case (7,2):
//            print("Combo Scheme\n", terminator: "")
//
//            self.openViewControllerBasedOnIdentifier("ComboScheme")
//
//            break
            
        case (3,-1):
            print("Video\n", terminator: "")
            self.openViewControllerBasedOnIdentifier("VideoController")
            
            break
            
//        case (9,-1):
//            print("Feedback\n", terminator: "")
//
//            self.openViewControllerBasedOnIdentifier("Feedback")
//
//            break
          
            
//        case (10,-1):
//            print("Contact us\n", terminator: "")
//
//            self.openViewControllerBasedOnIdentifier("ContactUs")
//
//            break
            
        case (4,-1):
            print("About Us\n", terminator: "")
            
            self.openViewControllerBasedOnIdentifier("AboutUs")
            
            break
            
        case (5,-1):
            print("Term of use\n", terminator: "")
            
            self.openViewControllerBasedOnIdentifier("TermOfUse")
            
            break
            
//        case (6,0):
//            print("world cup screen\n", terminator: "")
//            
//            self.openViewControllerBasedOnIdentifier("WorldCupMainController")
//            
//            
//            break
            
        case (6,-1):
            print("Increase Limits\n", terminator: "")
            self.openViewControllerBasedOnIdentifier("IncreasedLimitController") 
            break
            
        case (7,-1):
            print("Logout\n", terminator: "")
            let loginData = UserDefaults.standard
            loginData.removeObject(forKey: "loginData")
            
            let vcLogin = self.storyboard?.instantiateViewController(withIdentifier: "LoginScreen") as! LoginController
            self.navigationController!.pushViewController(vcLogin, animated: false)
            self.dismiss(animated: true, completion: nil)
            
            break
            
            
        default:
            print("default\n", terminator: "")
        }
    }
    
    func openViewControllerBasedOnIdentifier(_ strIdentifier:String){
        let destViewController : UIViewController = self.storyboard!.instantiateViewController(withIdentifier: strIdentifier)
        
        let topViewController : UIViewController = self.navigationController!.topViewController!
        
        if (topViewController.restorationIdentifier! == destViewController.restorationIdentifier!){
            //print("Same VC")
        } else {
            self.navigationController!.pushViewController(destViewController, animated: true)
        }
    }
    
    func addSlideMenuButton(){
        let btnShowMenu = UIButton(type: UIButtonType.system)
        btnShowMenu.setImage(self.defaultMenuImage(), for: UIControlState())
        btnShowMenu.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        btnShowMenu.addTarget(self, action: #selector(BaseViewController.onSlideMenuButtonPressed(_:)), for: UIControlEvents.touchUpInside)
        let customBarItem = UIBarButtonItem(customView: btnShowMenu)
        self.navigationItem.leftBarButtonItem = customBarItem;
    }
    
    func addBackButton(){
        let btnShowMenu = UIButton(type: UIButtonType.system)
        if let image = UIImage(named: "back") {
            btnShowMenu.setImage(image, for: UIControlState())
        }
        btnShowMenu.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        btnShowMenu.addTarget(self, action: #selector(BaseViewController.backPressed), for: UIControlEvents.touchUpInside)
        let customBarItem = UIBarButtonItem(customView: btnShowMenu)
        self.navigationItem.leftBarButtonItem = customBarItem;
    }
    
    @objc func backPressed(){
        self.navigationController?.popViewController(animated: true)
        //self.navigationController?.popViewController(animated: true)
    }
    
    
    func addSortButton(){
        let btnShowMenu = UIButton(type: UIButtonType.system)
        if let image = UIImage(named: "icon_sort") {
            btnShowMenu.setImage(image, for: UIControlState())
        }
        btnShowMenu.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        btnShowMenu.addTarget(self, action: #selector(BaseViewController.sortPopup), for: UIControlEvents.touchUpInside)
        let customBarItem = UIBarButtonItem(customView: btnShowMenu)
        self.navigationItem.rightBarButtonItem = customBarItem;

    }
    
    @objc func sortPopup(){
        let sb = UIStoryboard(name: "Sorting", bundle: nil)
        let popup = sb.instantiateInitialViewController()! as! SortViewController
        popup.modalPresentationStyle = .overFullScreen
        popup.delegate = (self as PopupDateDelegate)
        popup.showPicker = 1
        popup.pickerDataSource = ["A-Z","Z-A"]
        self.present(popup, animated: true)
    }
    
    

    func defaultMenuImage() -> UIImage {
        var defaultMenuImage = UIImage()
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 30, height: 22), false, 0.0)
        
        UIColor.black.setFill()
        UIBezierPath(rect: CGRect(x: 0, y: 3, width: 30, height: 1)).fill()
         UIBezierPath(rect: CGRect(x: 0, y: 10, width: 30, height: 1)).fill()
        UIBezierPath(rect: CGRect(x: 0, y: 17, width: 30, height: 1)).fill()
        
        UIColor.white.setFill()
        UIBezierPath(rect: CGRect(x: 0, y: 4, width: 30, height: 1)).fill()
        UIBezierPath(rect: CGRect(x: 0, y: 11,  width: 30, height: 1)).fill()
        UIBezierPath(rect: CGRect(x: 0, y: 18, width: 30, height: 1)).fill()
        
        defaultMenuImage = UIGraphicsGetImageFromCurrentImageContext()!
        
        UIGraphicsEndImageContext()
       
        return defaultMenuImage;
    }
    
    @objc func onSlideMenuButtonPressed(_ sender : UIButton){
        if (sender.tag == 10)
        {
            // To Hide Menu If it already there
            self.slideMenuItemSelectedAtIndex(-1,-1);
            
            sender.tag = 0;
            
            let viewMenuBack : UIView = view.subviews.last!
            
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                var frameMenu : CGRect = viewMenuBack.frame
                frameMenu.origin.x = -1 * UIScreen.main.bounds.size.width
                viewMenuBack.frame = frameMenu
                viewMenuBack.layoutIfNeeded()
                viewMenuBack.backgroundColor = UIColor.clear
                }, completion: { (finished) -> Void in
                    viewMenuBack.removeFromSuperview()
            })
            
            return
        }
        
        sender.isEnabled = false
        sender.tag = 10
        
        let menuVC : MenuViewController = self.storyboard!.instantiateViewController(withIdentifier: "MenuViewController") as! MenuViewController
        menuVC.btnMenu = sender
        menuVC.delegate = self
        self.view.addSubview(menuVC.view)
        self.addChildViewController(menuVC)
        menuVC.view.layoutIfNeeded()
        
        
        menuVC.view.frame=CGRect(x: 0 - UIScreen.main.bounds.size.width, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height);
        
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            menuVC.view.frame=CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height);
            sender.isEnabled = true
            }, completion:nil)
    }
}
