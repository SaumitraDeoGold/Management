//
//  CategoryWiseCompareController.swift
//  ManagementApp
//
//  Created by Goldmedal on 12/11/19.
//  Copyright © 2019 Goldmedal. All rights reserved.
//

import UIKit

class CategoryWiseCompareController: BaseViewController {
    
    //Outlets...
    @IBOutlet weak var lblPartyName: UIButton!
    @IBOutlet weak var txtAmount: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        addSlideMenuButton()
        
    }
    
    //Button...
    @IBAction func searchParty(_ sender: Any) {
        let sb = UIStoryboard(name: "PartyStoryboard", bundle: nil)
        let popup = sb.instantiateInitialViewController()! as! PartySearchController
        popup.modalPresentationStyle = .overFullScreen
        popup.delegate = self
        popup.fromPage = "Division"
        self.present(popup, animated: true)
    }
    
    //Popup Func...
    func showParty(value: String,cin: String) {
        lblPartyName.setTitle("  \(value)", for: .normal)
    }
    
}
