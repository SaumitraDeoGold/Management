//
//  HomeMainController.swift
//  DealorsApp
//
//  Created by Goldmedal on 5/10/18.
//  Copyright © 2018 Goldmedal. All rights reserved.
//

import UIKit

class HomeMainController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
      let mainVC = UIViewController()
      mainVC.view.backgroundColor = .red
//
      let rootController = RootViewController(mainViewController: mainVC, topNavigationLeftImage: UIImage(named: "hamburger-menu-icon"))
     let menuVC = MenuViewController()
     menuVC.view.backgroundColor = .green
//
    let drawerVC = DrawerController(rootViewController: rootController, menuController: menuVC)

        self.addChildViewController(drawerVC)
       view.addSubview(drawerVC.view)
        drawerVC.didMove(toParentViewController: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}
