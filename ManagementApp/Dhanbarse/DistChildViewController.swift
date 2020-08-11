//
//  DistChildViewController.swift
//  ManagementApp
//
//  Created by Goldmedal on 06/07/20.
//  Copyright © 2020 Goldmedal. All rights reserved.
//

import UIKit
struct DistChild: Codable {
    let result: Bool?
    let message, servertime: String?
    let data: [DistChildObj]?
}

// MARK: - Datum
struct DistChildObj: Codable {
    let slNo, name, email, mobileNo: String?
    let category: String?
    let address, city: String?
    let state: String?
    let district: String?
    let shopName, joinDate: String?
}
class DistChildViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
