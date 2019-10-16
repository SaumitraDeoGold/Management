//
//  IntroScreenViewController.swift
//  DealorsApp
//
//  Created by Goldmedal on 8/29/18.
//  Copyright © 2018 Goldmedal. All rights reserved.
//

import UIKit
import FirebaseAnalytics

class IntroScreenViewController: BaseViewController {
    
    @IBOutlet weak var imageSlider: CPImageSlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        imageSlider.autoSrcollEnabled = false
        imageSlider.enableArrowIndicator = true
        self.imageSlider.images = ["intro_2","intro_3","intro_5","intro_1","intro_4"]
        imageSlider.delegate = self
        
        Analytics.setScreenName("INTRO SCREEN", screenClass: "IntroScreenViewController")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func showLoginVC() {
        DispatchQueue.main.async {
            let vcLogin = self.storyboard?.instantiateViewController(withIdentifier: "LoginScreen") as! LoginController
            self.navigationController!.pushViewController(vcLogin, animated: false)

            UserDefaults.standard.set("intro", forKey: "Intro")
        }
    }
}

extension IntroScreenViewController: CPSliderDelegate {
    func previousClick() {
        showLoginVC()
    }
    
    func nextClick() {
        showLoginVC()
    }
    
    func sliderImageTapped(slider: CPImageSlider, index: Int) {
        //Image Click event
    }
    
    func sliderImageIndex(index: Int) {
        //Slide image index
    }
    
    
}

