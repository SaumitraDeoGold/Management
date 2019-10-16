//
//  AboutUsController.swift
//  DealorsApp
//
//  Created by Goldmedal on 7/17/18.
//  Copyright © 2018 Goldmedal. All rights reserved.
//

import UIKit
import FirebaseAnalytics

class AboutUsController: BaseViewController {
    
    @IBOutlet weak var lblAboutUs: UILabel!
    
    var strAboutUs = "Goldmedal Electricals Pvt. Ltd. was established in the year 1979 with a vision to create switches and electrical systems that made a difference to the lives of the Indian consumer. Since then, Goldmedal has successfully launched a range of switching and accessory products. Today, the company manufactures a vast range of products including Switches, Sockets, Door bells, Flex Boxes, MCBs, Distribution Boards, Wires & Cables, CFLs and LEDs. Goldmedal is thus able to meet almost all the necessary electrical needs of a modern home or office. \n" +
    "\n" +
    "The Goldmedal brand is considered as one of the leading brands in the electrical segment. With a presence in more than 20 states in India with over 10,000 dealers across the country, Goldmedal is taking giant leaps to become one of the biggest brands in the electrical industry.\n" +
    "\n" +
    "The Company has a strong focus on design and R&D to create products that are considered path breaking in the Indian market. Acknowledged in the industry for its product innovation and overall quality, the company has received the coveted ISO 9001:2000 certification from BVQI-London for various processes including design, plus the ANAB-USA, ANSI-ASQ, and certifications from the Bureau of Indian Standards, the CE (European Standards Conformity), and the IEC6691 (International Electro-technical Commission).\n" +
    "\n" +
    "With its headquarters in Mumbai, the financial capital of the country, the company has manufacturing set ups across India in Mumbai, Vijaywada and Bhiwadi. \n" +
    "\n"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addSlideMenuButton()

        // Do any additional setup after loading the view.
        self.lblAboutUs.text = strAboutUs.capitalized
        
        Analytics.setScreenName("ABOUT US SCREEN", screenClass: "AboutUsController")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  
}
