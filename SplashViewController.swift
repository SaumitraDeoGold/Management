//
//  SplashViewController.swift
//  DealorsApp
//
//  Created by Goldmedal on 8/18/18.
//  Copyright © 2018 Goldmedal. All rights reserved.
//

import UIKit
import AVKit
import FirebaseAnalytics


enum VersionError: Error {
    case invalidResponse, invalidBundleInfo
}

class SplashViewController: AVPlayerViewController {
    var appStrorVersionNumber = ""

    var initialMain = [InitialElement]()
    var initialObj = [InitialObj]()
    var videoPlay = false
  
    override func viewDidLoad() {
        super.viewDidLoad()
      
            apiSplash()
      
        // Do any additional setup after loading the view.
        let path = Bundle.main.path(forResource: "logo_splash1", ofType: "mp4")
        let videoURL = URL(fileURLWithPath: path!)
        player = AVPlayer(url: videoURL)
        showsPlaybackControls = false
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.animationDidFinish(_:)),
                                               name: .AVPlayerItemDidPlayToEndTime,
                                               object: player?.currentItem)
        // add notification observers
        NotificationCenter.default.addObserver(self, selector: #selector(self.didBecomeActive), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.didEnterBackground), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)

        view.backgroundColor = UIColor.white
        Analytics.setScreenName("SPLASH SCREEN", screenClass: "SplashViewController")
    }
    
    
    @objc func didBecomeActive() {
        print("did become active")
        if(!videoPlay){
            player?.play()
        }
    }

    func forceUpdate(update: Bool) {
        if update {
            popupUpdateDialogue()
        }

    }
    
    @objc func didEnterBackground() {
        print("will enter background")
        player?.pause()
    }
    
    func popupUpdateDialogue(){
        
        let alertMessage = "A new version of Management Application is available,Please update to version \(self.appStrorVersionNumber)";
        let alert = UIAlertController(title: "New Version Available", message: alertMessage, preferredStyle: UIAlertControllerStyle.alert)
        
        let okBtn = UIAlertAction(title: "Update", style: .default, handler: {(_ action: UIAlertAction) -> Void in
            if let url = URL(string: "itms-apps://itunes.apple.com/us/app/id1502521627"),
                UIApplication.shared.canOpenURL(url){
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(url)
                }
            }
        })
        let noBtn = UIAlertAction(title:"Later" , style: .destructive, handler: {(_ action: UIAlertAction) -> Void in
            self.dismiss(animated: true, completion: nil)
            self.continueInsideApp()
        })
        alert.addAction(okBtn)
//        alert.addAction(noBtn)
        self.present(alert, animated: true, completion: nil)
    }
    
    func apiSplash(){

        let json: [String: Any] = ["Date": "02/17/2018"]

        DataManager.shared.makeAPICall(url: "https://api.goldmedalindia.in/api/getInitialValueManagement", params: json, method: .POST, success: { (response) in
            
            if let response = response {
                print("SPLASH",response)
            }
            
            let data = response as? Data

            do {
                let responseData =   try JSONSerialization.jsonObject(with: data!, options: .mutableContainers)
                
                self.initialMain = try JSONDecoder().decode([InitialElement].self, from: data!)
                self.initialObj = self.initialMain[0].data

                let result = self.initialMain[0].result ?? false

                if result
                {
                    OperationQueue.main.addOperation {
                        let mainData = ((responseData as? Array ?? [])[0] as? Dictionary ?? [:])["data"]
                        let initialData = ((mainData as? Array ?? [])[0] as? Dictionary ?? [:])
                        UserDefaults.standard.set(initialData, forKey: "initialData")
                        self.appStrorVersionNumber = (initialData["iosVersion"] as? String) ?? ""
                        //self.appStrorVersionNumber = "1"
                        self.forceUpdate(update: self.isUpdateAvailable(appstoreVersion: self.appStrorVersionNumber))
                    }

                }

            } catch let errorData {
                print(errorData.localizedDescription)
            }
        }) { (Error) in
            print(Error?.localizedDescription ?? "ERROR")
        }
        
    }
    
    
    func isUpdateAvailable(appstoreVersion: String) -> Bool {
        guard let info = Bundle.main.infoDictionary,
            let version = info["CFBundleShortVersionString"] as? String else {
                return false
        }

        let appVersion = Double(version)
        let appStoreVersion = Double(appstoreVersion)
        return CGFloat(appVersion ?? 0) < CGFloat(appStoreVersion ?? 0)
    }
    


    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("FOREGROUND")
        player?.play()
    }
    
    // - - - - -  initial api data parsing - - - - - -
    func continueInsideApp(){
        var initialData =  UserDefaults.standard.value(forKey: "initialData") as? Dictionary ?? [:]
        if(initialData.count > 0){
            if (UserDefaults.standard.value(forKey: "Intro") == nil){
                let vcIntro = self.storyboard?.instantiateViewController(withIdentifier: "IntroScreen") as! IntroScreenViewController
                self.navigationController!.pushViewController(vcIntro, animated: false)
            }else{
                if (UserDefaults.standard.value(forKey: "loginData") == nil){
                    // loginview controller code
                    let vcLogin = self.storyboard?.instantiateViewController(withIdentifier: "LoginScreen") as! LoginController
                    self.navigationController!.pushViewController(vcLogin, animated: false)
                }else{
                    let vcHome = self.storyboard?.instantiateViewController(withIdentifier: "Dashboard") as! DashboardController
                    vcHome.isAppLaunched = true
                    self.navigationController!.pushViewController(vcHome, animated: false)
                    
                }
            }
            self.videoPlay = true
        }else{
            let alertController = UIAlertController(title: "Server Error", message: "Server Error", preferredStyle: .alert)
            
            let OKAction = UIAlertAction(title: "OK", style: .default) {
                (action:UIAlertAction!) in
                exit(0)
            }
            
            alertController.addAction(OKAction)
            
            self.present(alertController, animated: true, completion:nil)
        }
        
    }
    
    @objc func animationDidFinish(_ notification: NSNotification) {
        print("Animation did finish")

        guard !self.isUpdateAvailable(appstoreVersion: self.appStrorVersionNumber) else {
            return
        }
        continueInsideApp()
       
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
   
}

protocol SomeMediaPlayerDelegate : class{
    func finishPlayer()
}

class SomeMediaPlayer: UIViewController {
    public var audioURL:URL!
    private var player = AVPlayer()
    private var playerLayer: AVPlayerLayer!
    weak var delegate : SomeMediaPlayerDelegate?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.playerLayer = AVPlayerLayer(player: self.player)
        self.view.layer.insertSublayer(self.playerLayer, at: 0)
        let playerItem = AVPlayerItem(url: self.audioURL)
        self.player.replaceCurrentItem(with: playerItem)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.animationDidFinish(_:)),
                                               name: .AVPlayerItemDidPlayToEndTime,
                                               object: player.currentItem)
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.player.play()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.playerLayer.frame = self.view.bounds
    }
    
    @objc func animationDidFinish(_ notification: NSNotification) {
        print("Animation did finish")
        delegate?.finishPlayer()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // Force the view into landscape mode if you need to
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        get {
            return .landscape
        }
    }
}
