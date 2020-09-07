//
//  BaseViewController.swift
//  AKSwiftSlideMenu
//
//  Created by Ashish on 21/09/15.
//  Copyright (c) 2015 Kode. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController, SlideMenuDelegate, PopupDateDelegate {
    
    var pReport = 100
    var IncLimit = 4
    var video = 3
    var vendorSubSelector = 100
    var logoutSelector = 9
    var logoutSubSelector = -1
    var empSelector = 6
    var empSubSelector = 0
    var empTwoSub = 1
    var empThreeSub = 2
    var aboutus = 7
    var termofuse = 8
    var dhanSelector = 5
    var dhanSubSelector = 0
    var docs = 2
    var vendorStory = false
    var salesStory = false
    var dhanbarseStory = false
    var salesAgent = 10000
    var ETT = 10
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if(UserDefaults.standard.value(forKey: "userCategory") != nil && UserDefaults.standard.value(forKey: "userCategory") as! String == "Management"){
            docs = 3
            pReport = 2
            IncLimit = 5
            video = 4
            vendorSubSelector = -1
            dhanSelector = 6
            dhanSubSelector = 0
            empSelector = 7
            empSubSelector = 0
            logoutSelector = 10
            logoutSubSelector = -1
            aboutus = 8
            termofuse = 9
            salesAgent = 10
            ETT = 11
        }
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
            
        case (1,8):
            print("Insurance\n", terminator: "")
            
            self.openViewControllerBasedOnIdentifier("Insurance")
            
            break
            
        case (1,9):
            print("ExpenseBillViewController\n", terminator: "")
            
            self.openViewControllerBasedOnIdentifier("ExpenseBillViewController")
            
            break
            
        case (1,salesAgent):
            print("AgentLimit\n", terminator: "")
            
            self.openViewControllerBasedOnIdentifier("AgentLimit")
            
            break
            
        case (1,ETT):
            print("Executive Target Tracking\n", terminator: "")
            salesStory = true
            self.openViewControllerBasedOnIdentifier("ExecutiveTgtTrkController") 
            break
            
        case (pReport,0):
            print("SearchSupplier\n", terminator: "")
            self.openViewControllerBasedOnIdentifier("SearchSupplier")
            break
            
        case (pReport,1):
            print("SearchVendor\n", terminator: "")
            self.openViewControllerBasedOnIdentifier("SearchVendor")
            break
            
        case (pReport,2):
            print("Cat Purchase Controller\n", terminator: "")
            vendorStory = true
            self.openViewControllerBasedOnIdentifier("CatPurchaseController")
            break
            
        case (pReport,3):
            print("VendorPurchaseOrder\n", terminator: "")
            vendorStory = true
            self.openViewControllerBasedOnIdentifier("VendorPurchaseOrder")
            break
            
        case (pReport,4):
            print("PurSalesLedgerViewController\n", terminator: "")
            vendorStory = true
            self.openViewControllerBasedOnIdentifier("PurSalesLedgerViewController")
            break
            
//        case (pReport,4):
//            print("ProductPlanViewController\n", terminator: "")
//            vendorStory = true
//            self.openViewControllerBasedOnIdentifier("ProductPlanViewController")
//            break
            
        case (pReport,5):
            print("ThirdPartyViewController\n", terminator: "")
            vendorStory = true
            self.openViewControllerBasedOnIdentifier("ThirdPartyViewController")
            break
            
//        case (pReport,6):
//            print("MonthwiseViewController\n", terminator: "")
//            vendorStory = true
//            self.openViewControllerBasedOnIdentifier("MonthwiseViewController")
//            break
            
        case (pReport,6):
            print("AgingReportController\n", terminator: "")
            vendorStory = true
            self.openViewControllerBasedOnIdentifier("AgingReportController")
            break
            
        case (pReport,7):
            print("RateComparisonController\n", terminator: "")
            vendorStory = true
            self.openViewControllerBasedOnIdentifier("RateComparisonController")
            break
            
        case (docs,0):
            print("Price list\n", terminator: "")
            
            self.openViewControllerBasedOnIdentifier("PriceList")
            
            break
            
        case (docs,1):
            print("Catalogue\n", terminator: "")
            
            self.openViewControllerBasedOnIdentifier("CatalogueList")
            
            break
            
        case (docs,2):
            print("Active scheme\n", terminator: "")
            
            self.openViewControllerBasedOnIdentifier("ActiveScheme")
            
            break
            
        case (docs,3):
            print("Policy\n", terminator: "")
            
            self.openViewControllerBasedOnIdentifier("Policy")
            
            break
            
        case (docs,4):
            print("TechnicalSpecs\n", terminator: "")
            
            self.openViewControllerBasedOnIdentifier("TechnicalSpecs")
            
            break
            
        case (docs,5):
            print("Dhanbarse docs\n", terminator: "")
            
            self.openViewControllerBasedOnIdentifier("DhanbarseDocs")
            
            break
            
        case (docs,6):
            print("Qwikpay docs\n", terminator: "")
            
            self.openViewControllerBasedOnIdentifier("QwikpayDocs")
            
            break
            
        case (video,0):
            print("Video\n", terminator: "")
            self.openViewControllerBasedOnIdentifier("VideoController")
            
            break
            
            
        case (video,1):
            print("dhanbarse video\n", terminator: "")
            self.openViewControllerBasedOnIdentifier("DhanbarseVideo")
            
            break
            
        case (video,2):
            print("Qwikpay video\n", terminator: "")
            self.openViewControllerBasedOnIdentifier("QwikpayVideo")
            
            break
            
        case (IncLimit,-1):
            print("Increase Limits\n", terminator: "")
            self.openViewControllerBasedOnIdentifier("IncreasedLimitController") 
            break
//        case (7,-1):
//            print("ExcelViewController\n", terminator: "")
//            self.openViewControllerBasedOnIdentifier("ExcelViewController")
//            break
//        case (supplierSelector,supplierSubSelector):
//            print("SearchSupplier\n", terminator: "")
//            self.openViewControllerBasedOnIdentifier("SearchSupplier")
//            break
//        case (vendorSelector,vendorSubSelector):
//            print("SearchVendor\n", terminator: "")
//            self.openViewControllerBasedOnIdentifier("SearchVendor")
//            break
            
        case (dhanSelector,dhanSubSelector):
            print("Dhanbarse Details\n", terminator: "")
            
            self.openViewControllerBasedOnIdentifier("Dhanbarse")
            
            break
        case (dhanSelector,1):
            print("Dhanbarse Profile\n", terminator: "")
            
            self.openViewControllerBasedOnIdentifier("DhanbarseProfile")
            
            break
            
        case (dhanSelector,2):
            print("Dhanbarse DRPRRP \n", terminator: "")
            
            self.openViewControllerBasedOnIdentifier("DRPRRPController")
            
            break
            
        case (dhanSelector,3):
            print("Paytm Cashback \n", terminator: "")
            dhanbarseStory = true
            self.openViewControllerBasedOnIdentifier("PaytmCashbackController")
            
            break
            
        
            
        case (empSelector,empTwoSub):
            print("Employee Details\n", terminator: "")
            
            self.openViewControllerBasedOnIdentifier("EmployeeDetailsController")
            
            break
            
        case (empSelector,empSubSelector):
            print("Employee Dashboard\n", terminator: "")
            
            self.openViewControllerBasedOnIdentifier("EmployeeBase")
            
            break
            
        case (empSelector,empThreeSub):
            print("Employee Data\n", terminator: "")
            
            self.openViewControllerBasedOnIdentifier("SearchEmployee")
            
            break
            
        case (empSelector,3):
            print("Dhanbarse MPR \n", terminator: "")
            
            self.openViewControllerBasedOnIdentifier("MPRViewController")
            
            break
            
        case (empSelector,4):
            print("Dhanbarse MPR \n", terminator: "")
            
            self.openViewControllerBasedOnIdentifier("PendingViewController")
            
            break
            
        case (aboutus,-1):
            print("About Us\n", terminator: "")
            
            self.openViewControllerBasedOnIdentifier("AboutUs")
            
            break
            
        case (termofuse,-1):
            print("Term of use\n", terminator: "")
            
            self.openViewControllerBasedOnIdentifier("TermOfUse")
            
            break
            
        case (logoutSelector,logoutSubSelector):
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
        if vendorStory {
            let storyboard = UIStoryboard(name: "VendorPurchase", bundle: nil)
            let destViewController : UIViewController = storyboard.instantiateViewController(withIdentifier: strIdentifier)
            
            let topViewController : UIViewController = self.navigationController!.topViewController!
            
            if (topViewController.restorationIdentifier! == destViewController.restorationIdentifier!){
                //print("Same VC")
            } else {
                self.navigationController!.pushViewController(destViewController, animated: true)
            }
            vendorStory = false
        }else if salesStory{
            let storyboard = UIStoryboard(name: "Sales", bundle: nil)
            let destViewController : UIViewController = storyboard.instantiateViewController(withIdentifier: strIdentifier)
            
            let topViewController : UIViewController = self.navigationController!.topViewController!
            
            if (topViewController.restorationIdentifier! == destViewController.restorationIdentifier!){
                //print("Same VC")
            } else {
                self.navigationController!.pushViewController(destViewController, animated: true)
            }
            salesStory = false
        }else if dhanbarseStory{
            let storyboard = UIStoryboard(name: "Dhanbarse", bundle: nil)
            let destViewController : UIViewController = storyboard.instantiateViewController(withIdentifier: strIdentifier)
            
            let topViewController : UIViewController = self.navigationController!.topViewController!
            
            if (topViewController.restorationIdentifier! == destViewController.restorationIdentifier!){
                //print("Same VC")
            } else {
                self.navigationController!.pushViewController(destViewController, animated: true)
            }
            dhanbarseStory = false
        }else{
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let destViewController : UIViewController = storyboard.instantiateViewController(withIdentifier: strIdentifier)
            
            let topViewController : UIViewController = self.navigationController!.topViewController!
            
            if (topViewController.restorationIdentifier! == destViewController.restorationIdentifier!){
                //print("Same VC")
            } else {
                self.navigationController!.pushViewController(destViewController, animated: true)
            }
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
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let menuVC : MenuViewController = storyboard.instantiateViewController(withIdentifier: "MenuViewController") as! MenuViewController
        menuVC.btnMenu = sender
        menuVC.delegate = self
        self.view.addSubview(menuVC.view)
        self.addChildViewController(menuVC)
        menuVC.view.layoutIfNeeded()
        
        
        menuVC.view.frame = CGRect(x: 0 - UIScreen.main.bounds.size.width, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height);
        
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            menuVC.view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height);
            sender.isEnabled = true
            }, completion:nil)
    }
}
