//
//  TermOfUseController.swift
//  DealorsApp
//
//  Created by Goldmedal on 7/17/18.
//  Copyright © 2018 Goldmedal. All rights reserved.
//

import UIKit
import FirebaseAnalytics

class TermOfUseController: BaseViewController {
    
    var  strTermsOfUse =
    "Terms and Conditions\n" +
    "\n\n" +
    "1. By downloading and using the App, these terms will automatically apply to you.. You should make sure therefore that you read them carefully before using either app. We are offering you these apps to use for your own personal use without cost. You should be aware that you cannot send it to anyone else, nor are you allowed to copy, or modify either app, any part of the apps, or our trademarks in any way. \n" +
    "\n" +
    "2. The App stores and processes personal data that you have provided to us so. It’s your responsibility to keep your phone and access to the app secure. \n" +
    "\n" +
    "3. The Goldmedal name and logo, and other Goldmedal trademarks, service marks, graphics and logos used in connection with the App are trademarks of Goldmedal.  Other trademarks, service marks, graphics and logos used in connection with the App are the trademarks of their respective owners.  These  Trademarks may not be copied, imitated or used, in whole or in part, without the prior written permission of Goldmedal or the applicable trademark holder. The App and the content featured in the App are protected by copyright, trademark, patent and other intellectual property and proprietary rights which are reserved to Goldmedal and its licensors.\n" +
    "\n" +
    "4.. Prohibited Uses\n" +
    "\n" +
    "You agree not to use the App in any way that:\n" +
    "\n" +
    "is unlawful, illegal or unauthorised;\n" +
    "is defamatory of any other person;\n" +
    "is obscene or offensive;\n" +
    "promotes discrimination based on race, sex, religion, nationality, disability, sexual orientation or age;\n" +
    "infringes any copyright, database right or trade mark of any other person;\n" +
    "is likely to harass, upset, embarrass, alarm or annoy any other person;\n" +
    "is likely to disrupt our service in any way; or\n" +
    "advocates, promotes or assists any unlawful act such as (by way of example only) copyright infringement or computer misuse.\n" +
    "\n" +
    "5. Indemnification\n" +
    "\n" +
    "You agree to indemnify Goldmedal for any breach of these App Terms. Goldmedal reserves the right to control the defence and settlement of any third party claim for which you indemnify Goldmedal under these App Terms and you will assist us in exercising such rights.\n" +
    "\n" +
    "6. No Promises\n" +
    "\n" +
    "Goldmedal provides the App on an ‘as is’ and ‘as available’ basis without any promises or representations, express or implied. In particular, Goldmedal does not warrant or make any representation regarding the validity, accuracy, reliability or availability of the App or its content. \n" +
    "\n" +
    "To the fullest extent permitted by applicable law, Goldmedal hereby excludes all promises, whether express or implied, including any promises that the App is fit for purpose, of satisfactory quality, non-infringing, is free of defects, is able to operate on an uninterrupted basis, that the use of the App by you is in compliance with laws or that any information that you transmit in connection with this App will be successfully, accurately or securely transmitted.\n" +
    "\n" +
    "7. Reliance on Information\n" +
    "\n" +
    "The App is intended to provide general information only and, as such, should not be considered as a substitute for advice covering any specific situation. You should seek appropriate advice before taking or refraining from taking any action in reliance on any information contained in the App.\n" +
    "\n" +
    "8. Exclusion of Goldmedal's Liability\n" +
    "\n" +
    "Nothing in these App Terms shall exclude or in any way limit Goldmedal's liability for death or personal injury caused by its negligence or for fraud or any other liability to the extent the same may not be excluded or limited as a matter of law.\n" +
    "\n" +
    "To the fullest extent permitted under applicable law, in no event shall Goldmedal be liable to you with respect to use of the App and/or be liable to you for any direct, indirect, special or consequential damages including, without limitation, damages for loss of goodwill, lost profits, or loss, theft or corruption of your information, the inability to use the App, Device failure or malfunction.\n" +
    "\n" +
    "Goldmedal shall not be liable even if it has been advised of the possibility of such damages, including without limitation damages caused by error, omission, interruption, defect, failure of performance, unauthorised use, delay in operation or transmission, line failure, computer virus, worm, Trojan horse or other harm. \n" +
    "\n" +
    "9. General\n" +
    "\n" +
    "These App Terms shall be governed by the laws of India and the parties submit to the exclusive jurisdiction of the courts of Mumbai to resolve any dispute between them arising under or in connection with these App Terms.\n" +
    "\n" +
    "If any provision (or part of a provision) of these App Terms is found by any court or administrative body of competent jurisdiction to be invalid, unenforceable or illegal, such term, condition or provision will to that extent be severed from the remaining terms, conditions and provisions which will continue to be valid to the fullest extent permitted by law.\n" +
    "\n" +
    "10. Contact Us\n" +
    "\n" +
    "If you have any questions regarding our App, you can email us info@goldmedalindia.com"+"\n\n"

    @IBOutlet weak var lblTermOfUse: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        addSlideMenuButton()
        // Do any additional setup after loading the view.
        
        lblTermOfUse.text = strTermsOfUse.capitalized
        
         Analytics.setScreenName("TERMS OF USE SCREEN", screenClass: "TermOfUseController")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
