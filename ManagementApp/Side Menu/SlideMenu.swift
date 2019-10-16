//
//  ViewController.swift
//  SliderMenu
//
//  Created by Uber - Abdul on 21/02/17.
//  Copyright © 2017 example.com. All rights reserved.
//

import UIKit

class SlideMenu: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
  
    
   // let arrOfMenus:[Menu] = (configurationData?.menu)! //["Fixtures","News","Photos","Videos"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationController?.isNavigationBarHidden = true
        custamizeMenu()
        
    }
   func custamizeMenu() {
        SideMenuManager.menuAddPanGestureToPresent(toView: self.navigationController!.navigationBar)
        SideMenuManager.menuAddScreenEdgePanGesturesToPresent(toView: self.navigationController!.view)
        
        SideMenuManager.menuWidth =  (UIScreen.main.bounds.size.width/4)*3
        SideMenuManager.menuFadeStatusBar = false
        SideMenuManager.menuPresentMode = .menuSlideIn
        
        
    }
    
    
//
//    /// TableView Datasource Method
//
//    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
//    {
//        return arrOfMenus.count;
//    }
//
//
//    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
//    {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
//        let  name = cell?.contentView.viewWithTag(1) as! UILabel
//        name.text = arrOfMenus[indexPath.row].displayName
//        cell?.selectionStyle = .none
//        return cell!
//    }
//
//
//
//   public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
//   {
//
//    if arrOfMenus[indexPath.row].menuId == 1{
//        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "fixtureView")
//        navigationController?.pushViewController(viewController!, animated: false)
//    }
//    else if arrOfMenus[indexPath.row].menuId == 2
//    {
//        self.detailsScreen(strOfUrl: configurationData?.landing_News_API, index: indexPath.row, image: #imageLiteral(resourceName: "news"))
//    }
//    else if arrOfMenus[indexPath.row].menuId == 3
//    {
//        self.detailsScreen(strOfUrl: configurationData?.landing_Photo_API, index: indexPath.row, image: #imageLiteral(resourceName: "photo"))
//    }
//    else if arrOfMenus[indexPath.row].menuId == 4
//    {
//        self.detailsScreen(strOfUrl: configurationData?.landing_Video_API, index: indexPath.row, image: #imageLiteral(resourceName: "video"))
//    }
//    else if arrOfMenus[indexPath.row].menuId == 5
//    {
//        self.detailsWebScreen(strOfUrl: configurationData?.about_WebView_URL)
//    }
//    else if arrOfMenus[indexPath.row].menuId == 6
//    {
//        self.detailsWebScreen(strOfUrl: configurationData?.terms_WebView_URL)
//    }
//    else{
//
//    }
//
//
//    }
//    func detailsWebScreen(strOfUrl:String?)  {
//        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "detailsView") as! DetailsViewController
//        viewController.webUrl = strOfUrl
//        navigationController?.pushViewController(viewController, animated: false)
//    }
//
//    func detailsScreen(strOfUrl:String?,index:Int,image:UIImage?)  {
//        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "news") as! NewsViewController
//        viewController.pageUrl = strOfUrl
//        viewController.pageStatusImage = image
//        viewController.titleLabel = arrOfMenus[index].displayName
//        navigationController?.pushViewController(viewController, animated: false)
//    }
    


}

