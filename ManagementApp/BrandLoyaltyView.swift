//
//  BrandLoyaltyView.swift
//  DealorsApp
//
//  Created by Goldmedal on 8/4/18.
//  Copyright © 2018 Goldmedal. All rights reserved.
//

import UIKit


@IBDesignable class BrandLoyaltyView: BaseCustomView {
    
    @IBOutlet weak var imvBrandLoyalty: UIImageView!
    
    var BrandLoyaltyMain = [BrandLoyaltyElement]()
    var BrandLoyaltyArr = [BrandLoyaltyObj]()
    
    @IBOutlet weak var btnDiscoverWorld: RoundButton!
    @IBOutlet weak var btnStarRewards: RoundButton!
    
    var imgBrandLoyaltyArr = [String]()
    var strCin = ""
    var brandLoyaltyApi = ""
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet weak var imageSlider: CPImageSlider!
   
    override func xibSetup() {
        super.xibSetup()
        
        let loginData =  UserDefaults.standard.value(forKey: "loginData") as? Dictionary ?? [:]
        strCin = loginData["userlogid"] as? String ?? ""
        
        let initialData =  UserDefaults.standard.value(forKey: "initialData") as? Dictionary ?? [:]
        brandLoyaltyApi = (initialData["baseApi"] as? String ?? "")+""+(initialData["brandingImages"] as? String ?? "")
        
        btnDiscoverWorld.imageView?.contentMode = .scaleAspectFit
        btnStarRewards.imageView?.contentMode = .scaleAspectFit
       
        apiBrandLoyalty()

        imageSlider.autoSrcollEnabled = true
    }

    
    @IBAction func clicked_star_rewards(_ sender: Any) {

        let starRewardVC = parentViewController?.storyboard?.instantiateViewController(withIdentifier: "StarReward") as! StarRewardsViewController
    parentViewController?.navigationController?.pushViewController(starRewardVC, animated: true)
  
    }
    
    @IBAction func clicked_discover_world(_ sender: Any) {
        var alert = UIAlertView(title: "Coming Soon", message: "Coming soon", delegate: nil, cancelButtonTitle: "OK")
        alert.show()
    }
    

        func apiBrandLoyalty(){
            ViewControllerUtils.sharedInstance.showViewLoader(view: view)
            
            let json: [String: Any] = ["CIN":appDelegate.sendCin,"ClientSecret":"201020"]
            
            DataManager.shared.makeAPICall(url: brandLoyaltyApi, params: json, method: .POST, success: { (response) in
                let data = response as? Data
                
                do {
                    self.BrandLoyaltyMain = try JSONDecoder().decode([BrandLoyaltyElement].self, from: data!)
                    
                    self.BrandLoyaltyArr = self.BrandLoyaltyMain[0].data
                    
                    let result = (self.BrandLoyaltyMain[0].result ?? false)!
                    
                    if result {
                      for i in 0..<self.BrandLoyaltyArr.count {
                         self.imgBrandLoyaltyArr.append(self.BrandLoyaltyArr[i].url ?? "")
                        }
                        self.imageSlider.images = self.imgBrandLoyaltyArr
                    }
                    ViewControllerUtils.sharedInstance.removeLoader()
                } catch let errorData {
                    ViewControllerUtils.sharedInstance.removeLoader()
                    print(errorData.localizedDescription)
                }
                
             
            }) { (Error) in
                ViewControllerUtils.sharedInstance.removeLoader()
                print(Error?.localizedDescription ?? "ERROR")

            }
    }
    
}

