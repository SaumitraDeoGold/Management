//
//  MenuViewController.swift
//  AKSwiftSlideMenu
//
//  Created by Ashish on 21/09/15.
//  Copyright (c) 2015 Kode. All rights reserved.
//

import UIKit

protocol SlideMenuDelegate {
    func slideMenuItemSelectedAtIndex(_ sectionIndex : Int,_ itemIndex : Int)
    
}

class MenuViewController: UIViewController {
    
    /**
     *  Array to display menu options
     */
    @IBOutlet var tblMenuOptions : UITableView!
    
    /**
     *  Transparent button to hide menu
     */
    @IBOutlet var btnCloseMenuOverlay : UIButton!
    
    /**
     *  Array containing menu options
     */
    //  var arrayMenuOptions = [Dictionary<String,String>]()
    
    //var arrayMenuOptions = [NSMutableDictionary]()
    
    var expandData = [NSMutableDictionary]()
    
    /**
     *  Menu button which was tapped to display the menu
     */
    var btnMenu : UIButton!
    
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var imvProfileImage: UIImageView!
    @IBOutlet weak var vwProfile: UIView!
    @IBOutlet weak var vwMenu: UIView!
    
    var imageData: Data? = nil
    var strUserName = ""
    
    /**
     *  Delegate of the MenuVC
     */
    var delegate : SlideMenuDelegate?
    
    var itemIndex = -1
    var sectionIndex = -1
    var menuSection = 9
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tblMenuOptions.tableFooterView = UIView()
        // Do any additional setup after loading the view.
        if(UserDefaults.standard.value(forKey: "userCategory") != nil && UserDefaults.standard.value(forKey: "userCategory") as! String == "Management"){
            menuSection = 10
        }
        self.imvProfileImage.layer.borderWidth = 2
        self.imvProfileImage.layer.masksToBounds = false
        self.imvProfileImage.layer.borderColor = UIColor.black.cgColor
        self.imvProfileImage.layer.cornerRadius = self.imvProfileImage.frame.size.width/2
        self.imvProfileImage.clipsToBounds = true
        
        //ADD SHADOW TO NAVIGATION VIEWS...
        vwMenu.layer.masksToBounds = false
        vwMenu.layer.shadowOffset = CGSize(width: 0, height: 0)
        vwMenu.layer.shadowRadius = 2
        vwMenu.layer.shadowOpacity = 1
        vwMenu.layer.shadowColor = UIColor.gray.cgColor
        
        vwProfile.layer.masksToBounds = false
        vwProfile.layer.shadowOffset = CGSize(width: 0, height: 0)
        vwProfile.layer.shadowRadius = 2
        vwProfile.layer.shadowOpacity = 1
        vwProfile.layer.shadowColor = UIColor.gray.cgColor
        
        
        if(imageData == nil)
        {
            imageData = UserDefaults.standard.object(forKey: "SavedImage") as? Data ?? nil
        }
        
        if(imageData != nil)
        {
            imvProfileImage.image = UIImage(data:imageData as! Data)
        }
        
        let loginData =  UserDefaults.standard.value(forKey: "loginData") as? Dictionary ?? [:]
        strUserName = loginData["usernm"] as! String
        
        lblName.text = strUserName
        
        //        for family in UIFont.familyNames {
        //            let sName = family
        //            print("family: \(sName)")
        //            for name in UIFont.fontNames(forFamilyName: sName) {
        //                print("name: \(name)")
        //            }
        //        }
        
        
        tblMenuOptions.sectionHeaderHeight = 50
        
        
        
        self.expandData.append(["isCollapsible":"0","isOpen":"1","title":"DASHBOARD", "icon":"icon_dashboard","data":[""]])
       // self.expandData.append(["isCollapsible":"1","isOpen":"1","title":"ORDER", "icon":"dashboard_order_icon","data":["PLACE ORDER","ORDER SUMMARY"]])
//        self.expandData.append(["isCollapsible":"1","isOpen":"1","title":"BRAND LOYALTY", "icon":"brand_loyalty_club_icon","data":["STAR REWARD PROGRAM","DISCOVER THE WORLD","DOCUMENTS"]])
        if(UserDefaults.standard.value(forKey: "userCategory") != nil && UserDefaults.standard.value(forKey: "userCategory") as! String == "Management"){
          self.expandData.append(["isCollapsible":"1","isOpen":"1","title":"SALES REPORTS", "icon":"icon_reports","data":["DIVISION WISE SALES","DEALER APPOINTMENT","OUTSTANDING ABOVE","SALES AND PURCHASES","DEALER SEARCH","DIVISIONWISE COMPARE","CATEGORYWISE COMPARE","BRANCHWISE OUTSTANDING","INSURANCE REPORT","EXPENSE BILL","AGENT LIMIT","EXECUTIVE TARGET TRACKING"]])
        }else{
            self.expandData.append(["isCollapsible":"1","isOpen":"1","title":"SALES REPORTS", "icon":"icon_reports","data":["DIVISION WISE SALES","DEALER APPOINTMENT","OUTSTANDING ABOVE","SALES AND PURCHASES","DEALER SEARCH","DIVISIONWISE COMPARE","CATEGORYWISE COMPARE","BRANCHWISE OUTSTANDING","INSURANCE REPORT","EXPENSE BILL","EXECUTIVE TARGET TRACKING"]])
        }
        
        if(UserDefaults.standard.value(forKey: "userCategory") != nil && UserDefaults.standard.value(forKey: "userCategory") as! String == "Management"){
                    
                    self.expandData.append(["isCollapsible":"1","isOpen":"1","title":"PURCHASE REPORTS", "icon":"icon_reports","data":["SEARCH EXPENSE SUPPLIER","RAW MATERIAL PURCHASE VENDOR/SUPPLIER","CATEGORYWISE PURCHASE","PURCHASE INVOICE","SALE/PURCHASE PARTY LEDGER","THIRD PARTY ORDER","VENDOR/SUPPLIER AGING"]])
        //        self.expandData.append(["isCollapsible":"0","isOpen":"1","title":"SEARCH SUPPLIER", "icon":"dash_search","data":[""]])
        //        self.expandData.append(["isCollapsible":"0","isOpen":"1","title":"SEARCH VENDOR", "icon":"dash_search","data":[""]])
                    
                }
        self.expandData.append(["isCollapsible":"1","isOpen":"1","title":"DOCUMENTS", "icon":"icon_documents","data":["PRICE LIST","CATALOGUE","ACTIVE SCHEME","POLICY","TECH SPECIFICATION","DHANBARSE","QWIKPAY"]])
//        self.expandData.append(["isCollapsible":"1","isOpen":"1","title":"ENQUIRY", "icon":"icon_enquiry","data":["ENQUIRY","CALL SERVICE (EXECUTIVE)"]])
//        self.expandData.append(["isCollapsible":"0","isOpen":"1","title":"SALES RETURN REQUEST", "icon":"icon_sales_return","data":[""]])
//        self.expandData.append(["isCollapsible":"1","isOpen":"1","title":"COMBO SCHEME", "icon":"icon_combo","data":["COMBO SUMMARY REPORT","SPIN AND WIN","COMBO SCHEME"]])
        self.expandData.append(["isCollapsible":"1","isOpen":"1","title":"VIDEOS", "icon":"icon_video","data":["VIDEO","DHANBARSE","QWIKPAY"]])
        //self.expandData.append(["isCollapsible":"0","isOpen":"1","title":"FEEDBACK", "icon":"icon_feedback","data":[""]])
       // self.expandData.append(["isCollapsible":"0","isOpen":"1","title":"CONTACT US", "icon":"icon_contact_us","data":[""]])
        
        self.expandData.append(["isCollapsible":"0","isOpen":"1","title":"INCREASE LIMITS", "icon":"dashboard_sales_icon","data":[""]])
        
        self.expandData.append(["isCollapsible":"1","isOpen":"1","title":"DHANBARSE", "icon":"icon_about_us","data":["DHANBARSE DASHBOARD","SEARCH PROFILE","POINT BALANCE","PAYTM CASHBACK"]])
        self.expandData.append(["isCollapsible":"1","isOpen":"1","title":"HR", "icon":"icon_about_us","data":["EMPLOYEE DASHBOARD","EMPLOYEE DETAILS","EMPLOYEE SEARCH","MPR","PENDING/CLOSED MPR"]])
        self.expandData.append(["isCollapsible":"0","isOpen":"1","title":"ABOUT US", "icon":"icon_about_us","data":[""]])
        self.expandData.append(["isCollapsible":"0","isOpen":"1","title":"TERMS OF USE", "icon":"dashboard_order_icon","data":[""]])
        self.expandData.append(["isCollapsible":"0","isOpen":"1","title":"LOGOUT", "icon":"icon_logout","data":[""]])
        
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        imvProfileImage.isUserInteractionEnabled = true
        imvProfileImage.addGestureRecognizer(tapGestureRecognizer)
        
        // let loginData =  UserDefaults.standard.value(forKey: "loginData") as? Dictionary ?? [:]
        self.tblMenuOptions.contentInset = UIEdgeInsetsMake(0, 0, 64, 0);
        
    }
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        let tappedImage = tapGestureRecognizer.view as! UIImageView
        let btn = UIButton(type: UIButtonType.custom)
        itemIndex = -2
        sectionIndex = -2
        self.onCloseMenuClick(btn)
        // Your action
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onCloseMenuClick(_ button:UIButton!){
        btnMenu.tag = 0
        
        if (self.delegate != nil) {
            //  var index = Int32(button.tag)
            if(button == self.btnCloseMenuOverlay){
                //  index = -1
                sectionIndex = -1
                itemIndex = -1
            }
            delegate?.slideMenuItemSelectedAtIndex(sectionIndex,itemIndex)
        }
        
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.view.frame = CGRect(x: -UIScreen.main.bounds.size.width, y: 0, width: UIScreen.main.bounds.size.width,height: UIScreen.main.bounds.size.height)
            self.view.layoutIfNeeded()
            self.view.backgroundColor = UIColor.clear
        }, completion: { (finished) -> Void in
            self.view.removeFromSuperview()
            self.removeFromParentViewController()
        })
    }
    
    class ExpandCell:UITableViewCell{
        @IBOutlet weak var expandLbl: UILabel!
    }
    
}

extension MenuViewController : UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.expandData[section].value(forKey: "isOpen") as! String == "1"{
            return 0
        }else{
            let dataarray = self.expandData[section].value(forKey: "data") as! NSArray
            return dataarray.count
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.expandData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cellMenu")!
        
        let dataarray = self.expandData[indexPath.section].value(forKey: "data") as! NSArray
        
        let lblTitle : UILabel = cell.contentView.viewWithTag(101) as! UILabel
        
        let vwMainRow : UIView = cell.contentView.viewWithTag(100) as! UIView
        
        lblTitle.text = (dataarray[indexPath.row] as? String)?.capitalized
  
        if(dataarray[indexPath.row] as? String == "CALL SERVICE (EXECUTIVE)" || dataarray[indexPath.row] as? String == "DISCOVER THE WORLD")
        {
            if #available(iOS 11.0, *) {
                vwMainRow.backgroundColor = UIColor(named: "Primary")
            } else {
               vwMainRow.backgroundColor = UIColor.gray
            }
        }else{
          vwMainRow.backgroundColor = UIColor.white
        }
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 50))
        headerView.backgroundColor = UIColor.white
        let separatorView = UIView(frame: CGRect(x: 10, y: 0, width: tableView.bounds.size.width - 10, height: 1))
        separatorView.layer.masksToBounds = false
        separatorView.layer.shadowOffset = CGSize(width: 0, height: 0)
        separatorView.layer.shadowRadius = 1
        separatorView.layer.shadowOpacity = 0.3
        separatorView.layer.shadowColor = UIColor.gray.cgColor
//        if #available(iOS 11.0, *) {
           separatorView.backgroundColor = UIColor.init(named: "Primary")
//        } else {
//           separatorView.backgroundColor = UIColor.gray
//        }
        if section != 0 {
            headerView.addSubview(separatorView)
        }
        
        let imgIcon = UIImageView(frame: CGRect(x: 15, y: 15, width: 20, height: 20))
        let imageIcon = UIImage(named: self.expandData[section].value(forKey: "icon") as! String);
        imgIcon.image = imageIcon;
        headerView.addSubview(imgIcon)
        
        let imgDropdownArrow = UIImageView(frame: CGRect(x: headerView.frame.size.width - 35, y: 17.5, width: 15, height: 15))
        
        if (section == 1 || section == 2 || section == 3 || section == (menuSection-3) || section == (menuSection-4))
        {
            let imageArrow = UIImage(named: "arrow_down");
            imgDropdownArrow.image = imageArrow;
            headerView.addSubview(imgDropdownArrow)
        }
        
        if (section == menuSection)
        {
            let imageArrow = UIImage(named: "icon_lock");
            imgDropdownArrow.image = imageArrow;
            headerView.addSubview(imgDropdownArrow)
        }
        
        let label = UILabel(frame: CGRect(x: 50, y: 15, width: headerView.frame.size.width - 40, height: 20))
        label.text = (expandData[section]["title"]! as? String)?.capitalized
        label.font = UIFont(name: "Roboto-Regular", size: 13)
        headerView.addSubview(label)
        
        headerView.tag = section
        
        let tapgesture = UITapGestureRecognizer(target: self , action: #selector(self.sectionTapped(_:)))
        
        headerView.addGestureRecognizer(tapgesture)
        
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    
    @objc func sectionTapped(_ sender: UITapGestureRecognizer){
        
        print("---------------INDEX FOR HEADER----------",(sender.view?.tag)!)
        
        if self.expandData[(sender.view?.tag)!].value(forKey: "isCollapsible") as! String == "1"{
            if(self.expandData[(sender.view?.tag)!].value(forKey: "isOpen") as! String == "1"){
                self.expandData[(sender.view?.tag)!].setValue("0", forKey: "isOpen")
            }else{
                self.expandData[(sender.view?.tag)!].setValue("1", forKey: "isOpen")
            }
            self.tblMenuOptions.reloadSections(IndexSet(integer: (sender.view?.tag)!), with: .automatic)
        }else{
            let btn = UIButton(type: UIButtonType.custom)
            btn.tag = (sender.view?.tag)!
            sectionIndex = (sender.view?.tag)!
            
            if (sectionIndex == 100){
                var alert = UIAlertView(title: "Coming Soon", message: "Coming Soon", delegate: nil, cancelButtonTitle: "OK")
                alert.show()
            }else{
                self.onCloseMenuClick(btn)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let btn = UIButton(type: UIButtonType.custom)
        itemIndex = indexPath.row
        sectionIndex = indexPath.section
        
        print("---------------INDEX SECTION ----------",indexPath.row)
        
//        if ((sectionIndex == 2 && itemIndex == 1) || (sectionIndex == 5 && itemIndex == 1)){
//
//            var alert = UIAlertView(title: "Coming Soon", message: "Coming Soon", delegate: nil, cancelButtonTitle: "OK")
//            alert.show()
//
//        }else{
            self.onCloseMenuClick(btn)
        //}
    }
    
}
