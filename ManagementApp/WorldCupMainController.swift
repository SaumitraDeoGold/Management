//
//  tpController.swift
//  DealorsApp
//
//  Created by Goldmedal on 4/30/19.
//  Copyright © 2019 Goldmedal. All rights reserved.
//

import UIKit
import FirebaseAnalytics

class WorldCupMainController: BaseViewController {
    
    @IBOutlet weak var vwLeague: LeagueMatchListDetailView!
    @IBOutlet weak var vwSemi: SemiFinalView!
    @IBOutlet weak var vwFinal: FinalView!
    
     @IBOutlet weak var scrollMain: UIScrollView!
   
    
    @IBOutlet weak var viewHeightLayout: NSLayoutConstraint!
    @IBOutlet weak var vwBase: UIView!
    
    
    @IBOutlet weak var vwSchemeA: UIView!
    @IBOutlet weak var vwSchemeB: UIView!
    
    @IBOutlet weak var lblSchemeA: UILabel!
    @IBOutlet weak var lblSchemeB: UILabel!
    
    @IBOutlet weak var svSchemeA: UIStackView!
    @IBOutlet weak var svSchemeB: UIStackView!
    
    @IBOutlet var tabButtons: [UIButton]!
    @IBOutlet var lineLabels: [UILabel]!
    
    var leagueHeight = 800
    var semiHeight = 710
    var finalHeight = 675
    
    var isSemiFinalMain = Bool()
    var isFinalMain = Bool()
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        addSlideMenuButton()
        
        let tapSchemeA = UITapGestureRecognizer(target: self, action: #selector(self.handleTapA(_:)))
        let tapSchemeB = UITapGestureRecognizer(target: self, action: #selector(self.handleTapB(_:)))
        
        vwSchemeA.addGestureRecognizer(tapSchemeA)
        vwSchemeB.addGestureRecognizer(tapSchemeB)
        
        viewHeightLayout.constant = CGFloat(leagueHeight)
        vwLeague =  LeagueMatchListDetailView(frame: CGRect(x:0,y:0, width: UIScreen.main.bounds.width, height:viewHeightLayout.constant))
        
        vwBase.subviews.forEach { $0.removeFromSuperview() }
        
        if(vwLeague != nil){
            vwBase.addSubview(vwLeague)
        }
        
        
        Analytics.setScreenName("WORLD CUP DETAIL SCREEN", screenClass: "WorldCupMainController")
        //SQLiteDB.instance.addAnalyticsData(ScreenName: "WORLD CUP DETAIL SCREEN", ScreenId: Int64(GlobalConstants.init().WORLDCUP_DETAIL))
        
    }
    
    @objc func handleTapA(_ sender: UITapGestureRecognizer) {
        print("Hello World A")
        svSchemeA.isHidden = false
        svSchemeB.isHidden = true
        lblSchemeA.isHidden = false
        lblSchemeB.isHidden = true
        scrollMain.isScrollEnabled = true
    }
    
    @objc func handleTapB(_ sender: UITapGestureRecognizer) {
        print("Hello World B")
        scrollMain.setContentOffset(.zero, animated: true)
        scrollMain.scrollsToTop = true
        svSchemeA.isHidden = true
        svSchemeB.isHidden = false
        lblSchemeB.isHidden = false
        lblSchemeA.isHidden = true
        scrollMain.isScrollEnabled = false
    }
    
    @IBAction func tabAction(sender: UIButton) {
      
        for (index, button) in tabButtons.enumerated() {
            let labelLine = lineLabels[index]
            labelLine.backgroundColor = (button == sender) ? UIColor.red : UIColor.clear
        }
        
       
            switch sender.tag {
            case 0:
                viewHeightLayout.constant = CGFloat(leagueHeight)
                 vwBase.subviews.forEach { $0.removeFromSuperview() }
                vwLeague =  LeagueMatchListDetailView(frame: CGRect(x:0,y:0, width: UIScreen.main.bounds.width, height:viewHeightLayout.constant))
               
               if(vwLeague != nil){
                vwBase.addSubview(vwLeague)
                }
                break
            case 1:
             
                viewHeightLayout.constant = CGFloat(semiHeight)
                vwBase.subviews.forEach { $0.removeFromSuperview() }
                vwSemi =  SemiFinalView(frame: CGRect(x:0,y:0, width: UIScreen.main.bounds.width, height:viewHeightLayout.constant))
                
                if(vwSemi != nil){
                    vwBase.addSubview(vwSemi)
                }
                
                break
            case 2:
                viewHeightLayout.constant = CGFloat(finalHeight)
                 vwBase.subviews.forEach { $0.removeFromSuperview() }
                
                vwFinal =  FinalView(frame: CGRect(x:0,y:0, width: UIScreen.main.bounds.width, height:viewHeightLayout.constant))
               
                if(vwFinal != nil){
                    vwBase.addSubview(vwFinal)
                }
                break
                
            default:
                viewHeightLayout.constant = CGFloat(leagueHeight)
                vwLeague =  LeagueMatchListDetailView(frame: CGRect(x:0,y:0, width: UIScreen.main.bounds.width, height:viewHeightLayout.constant))
                vwBase.subviews.forEach { $0.removeFromSuperview() }
                
                vwBase.addSubview(vwLeague)
                break
            }
      
    }
    
    
    
}
