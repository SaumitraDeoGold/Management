import IQKeyboardManagerSwift
import UIKit
import Firebase
import Crashlytics
import Fabric
import UserNotifications
import FirebaseInstanceID
import FirebaseMessaging

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate,UNUserNotificationCenterDelegate, MessagingDelegate {
    
    var window: UIWindow?
    
    var wasAppKilled :Bool = false
    var isSemiFinalOpen = false
    var isFinalOpen = false
    var tokenString = String()
    var dealerData = [SearchDealersObj]()
    
    static var appDelegate:AppDelegate!
    
    var cin = ""
    var notificationId = "123"
    var sendCin = String()
    var userCategory = String()
    var userCIN = String()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        //Keyboard Manager
        IQKeyboardManager.sharedManager().enable = true
        var navigationBarAppearance = UINavigationBar.appearance()
        navigationBarAppearance.tintColor = UIColor.darkGray
        
        if #available(iOS 11.0, *) {
            
            navigationBarAppearance.titleTextAttributes =  [NSAttributedStringKey.foregroundColor: UIColor.init(named: "FontDarkText") , NSAttributedStringKey.font: UIFont(name: "Roboto-Regular", size: 16)!]
        } else {
            navigationBarAppearance.titleTextAttributes =  [NSAttributedStringKey.foregroundColor: UIColor.darkGray , NSAttributedStringKey.font: UIFont(name: "Roboto-Regular", size: 16)!]
            
        }
        if #available(iOS 11.0, *) {
            navigationBarAppearance.barTintColor = UIColor.init(named: "Primary")
            
        } else {
            navigationBarAppearance.barTintColor = UIColor.gray
        }
        
        let statusBar: UIView = UIApplication.shared.value(forKey: "statusBar") as! UIView
        
        if statusBar.responds(to:#selector(setter: UIView.backgroundColor)) {
            if #available(iOS 11.0, *) {
                statusBar.backgroundColor = UIColor.init(named: "Primary")
            } else {
                statusBar.backgroundColor = UIColor.gray
                
            }
            
        }
        
        
        UIApplication.shared.statusBarStyle = .lightContent
   
        let loginData =  UserDefaults.standard.value(forKey: "loginData") as? Dictionary ?? [:]
        
        if(!loginData.isEmpty){
            let strCin = loginData["userlogid"] as! String
            Crashlytics.sharedInstance().setUserIdentifier(strCin)
        }
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert,.sound,.badge]){
            (granted,error) in
            if granted{
                DispatchQueue.main.async(execute: {
                    application.registerForRemoteNotifications()
                })
                
            } else {
                // print("User Notification permission denied: \(error?.localizedDescription)")
            }
            
        }
        
        
        // set the delegate in didFinishLaunchingWithOptions
        UNUserNotificationCenter.current().delegate = self
  
        //called when app is killed
        
        if launchOptions != nil{
            let userInfo = launchOptions?[UIApplicationLaunchOptionsKey.remoteNotification]
            if userInfo != nil {
                
                wasAppKilled = true
                
                print("LAUNCH OPTIONS called")
         
            }
        }
        
        application.registerForRemoteNotifications()
        
        Messaging.messaging().shouldEstablishDirectChannel = true
        
        FirebaseApp.configure()
        
        Fabric.with([Crashlytics.self])
        
        Fabric.sharedSDK().debug = true
        
        return true
        
    }
    
    
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
       // tokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        //tokenString = InstanceID.instanceID().token() ?? "-"
        print("InstanceID token: \(tokenString)")
     
    }
    
    
    func application(received remoteMessage: MessagingRemoteMessage) {
        
        //print(remoteMessage.appData)
    
    }
    
    
    func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String) {
        
      // tokenString = InstanceID.instanceID().token()
       tokenString = fcmToken
        print("TOKEN STRING- - - - - ",fcmToken)
        
        Messaging.messaging().shouldEstablishDirectChannel = true
        
    }
    
    
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        Messaging.messaging().shouldEstablishDirectChannel = false
    }
    
    
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        Messaging.messaging().shouldEstablishDirectChannel = true
        
        var navigationBarAppearance = UINavigationBar.appearance()
        navigationBarAppearance.tintColor = UIColor.darkGray
        
        if #available(iOS 11.0, *) {
            
            navigationBarAppearance.titleTextAttributes =  [NSAttributedStringKey.foregroundColor: UIColor.init(named: "FontDarkText") , NSAttributedStringKey.font: UIFont(name: "Roboto-Regular", size: 16)!]
        } else {
            navigationBarAppearance.titleTextAttributes =  [NSAttributedStringKey.foregroundColor: UIColor.darkGray , NSAttributedStringKey.font: UIFont(name: "Roboto-Regular", size: 16)!]
            
        }
        if #available(iOS 11.0, *) {
            navigationBarAppearance.barTintColor = UIColor.init(named: "Primary")
            
        } else {
            navigationBarAppearance.barTintColor = UIColor.gray
        }
        
        let statusBar: UIView = UIApplication.shared.value(forKey: "statusBar") as! UIView
        
        if statusBar.responds(to:#selector(setter: UIView.backgroundColor)) {
            if #available(iOS 11.0, *) {
                statusBar.backgroundColor = UIColor.init(named: "Primary")
            } else {
                statusBar.backgroundColor = UIColor.gray
                
            }
            UIApplication.shared.statusBarStyle = .lightContent
        }
    }
    
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
    }
    
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        
    }
    
    // This method will be called when app received push notifications in foreground
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void)
        
    {
        
        completionHandler([.alert, .badge, .sound])
        
    }
    
    @available(iOS 10.0, *)
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        //write your action here
        if let notification = response.notification.request.content.userInfo as? [String:AnyObject] {
            
            //let message = parseRemoteNotification(notification: notification)
            //print(message as Any)
            let aps = notification["aps"] as? [String:AnyObject]
            
            let informToServer = notification["informToServer"] as? String ?? "0"
             cin = notification["cin"] as? String ?? ""
            let redirectToActivity = notification["redirectToActivity"] as? String ?? ""
            let redirecturl = notification["redirecturl"] as? String ?? ""
            let imageUrl = notification["attachment-url"] as? String ?? ""
             notificationId = notification["notificationId"] as? String ?? "0"
            let mediaType = notification["media_type"] as? String ?? "image"
            
            let alert = aps?["alert"] as? [String:AnyObject]
            let title = alert?["title"] as? String ?? ""
            let body = alert?["body"] as? String ?? ""
            
            let state = UIApplication.shared.applicationState
        
            
            let rootViewController = self.window!.rootViewController as! UINavigationController
            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            
            if (UserDefaults.standard.value(forKey: "loginData") == nil){
                let topViewController : UIViewController = (rootViewController.topViewController)!
                let vcLogin = mainStoryboard.instantiateViewController(withIdentifier: "LoginScreen") as! LoginController
                
                if (topViewController.restorationIdentifier! == vcLogin.restorationIdentifier!){
                    // print("Same VC")
                } else {
                    rootViewController.pushViewController(vcLogin, animated: true)
                }
            }else{
                switch(redirectToActivity){
                case ("division wise sales"):
                    
                    if(wasAppKilled){
                        let vcHome = mainStoryboard.instantiateViewController(withIdentifier: "Dashboard") as! DashboardController
                        let destViewController : UIViewController = mainStoryboard.instantiateViewController(withIdentifier: "DivisionWiseSales")
                        rootViewController.pushViewController(vcHome, animated: true)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { // change 2 to desired number of seconds
                            rootViewController.pushViewController(destViewController, animated: true)
                        }
                        
                        wasAppKilled = false
                        
                        
                    }else{
                        let topViewController : UIViewController = (rootViewController.topViewController)!
                        let destViewController : UIViewController = mainStoryboard.instantiateViewController(withIdentifier: "DivisionWiseSales")
                        if (topViewController.restorationIdentifier! == destViewController.restorationIdentifier!){
                            // print("Same VC")
                        } else {
                            rootViewController.pushViewController(destViewController, animated: true)
                        }
                    }
                    break
                    
                case ("dispatched material"):
                    
                    if(wasAppKilled){
                        let vcHome = mainStoryboard.instantiateViewController(withIdentifier: "Dashboard") as! DashboardController
                        let destViewController : UIViewController = mainStoryboard.instantiateViewController(withIdentifier: "DispatchedMaterial")
                        rootViewController.pushViewController(vcHome, animated: true)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { // change 2 to desired number of seconds
                            rootViewController.pushViewController(destViewController, animated: true)
                        }
                      
                        wasAppKilled = false
                        
                        
                    }else{
                        let topViewController : UIViewController = (rootViewController.topViewController)!
                        let destViewController : UIViewController = mainStoryboard.instantiateViewController(withIdentifier: "DispatchedMaterial")
                        if (topViewController.restorationIdentifier! == destViewController.restorationIdentifier!){
                            // print("Same VC")
                        } else {
                            rootViewController.pushViewController(destViewController, animated: true)
                        }
                    }
             
                    break
                    
                case ("pending order"):
                    
                    if(wasAppKilled){
                        let vcHome = mainStoryboard.instantiateViewController(withIdentifier: "Dashboard") as! DashboardController
                        let destViewController : UIViewController = mainStoryboard.instantiateViewController(withIdentifier: "PendingOrder")
                        rootViewController.pushViewController(vcHome, animated: true)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { // change 2 to desired number of seconds
                            rootViewController.pushViewController(destViewController, animated: true)
                        }
                        
                        wasAppKilled = false
                        
                        
                    }else{
                        let topViewController : UIViewController = (rootViewController.topViewController)!
                        let destViewController : UIViewController = mainStoryboard.instantiateViewController(withIdentifier: "PendingOrder")
                        if (topViewController.restorationIdentifier! == destViewController.restorationIdentifier!){
                            // print("Same VC")
                        } else {
                            rootViewController.pushViewController(destViewController, animated: true)
                        }
                    }
                    
                    break
                    
                case ("outstanding"):
                    
                    if(wasAppKilled){
                        let vcHome = mainStoryboard.instantiateViewController(withIdentifier: "Dashboard") as! DashboardController
                        let destViewController : UIViewController = mainStoryboard.instantiateViewController(withIdentifier: "Outstanding")
                        rootViewController.pushViewController(vcHome, animated: true)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { // change 2 to desired number of seconds
                            rootViewController.pushViewController(destViewController, animated: true)
                        }
                        
                        wasAppKilled = false
                        
                        
                    }else{
                        let topViewController : UIViewController = (rootViewController.topViewController)!
                        let destViewController : UIViewController = mainStoryboard.instantiateViewController(withIdentifier: "Outstanding")
                        if (topViewController.restorationIdentifier! == destViewController.restorationIdentifier!){
                            // print("Same VC")
                        } else {
                            rootViewController.pushViewController(destViewController, animated: true)
                        }
                    }
                    
                    break
                    
                case ("payment receipt"):
                    
                    if(wasAppKilled){
                        let vcHome = mainStoryboard.instantiateViewController(withIdentifier: "Dashboard") as! DashboardController
                        let destViewController : UIViewController = mainStoryboard.instantiateViewController(withIdentifier: "SalesPaymentReceipt")
                        rootViewController.pushViewController(vcHome, animated: true)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { // change 2 to desired number of seconds
                            rootViewController.pushViewController(destViewController, animated: true)
                        }
                        
                        wasAppKilled = false
                        
                        
                    }else{
                        let topViewController : UIViewController = (rootViewController.topViewController)!
                        let destViewController : UIViewController = mainStoryboard.instantiateViewController(withIdentifier: "SalesPaymentReceipt")
                        if (topViewController.restorationIdentifier! == destViewController.restorationIdentifier!){
                            // print("Same VC")
                        } else {
                            rootViewController.pushViewController(destViewController, animated: true)
                        }
                    }
                    
                    break
                    
                case ("credit debit note"):
                    
                    if(wasAppKilled){
                        let vcHome = mainStoryboard.instantiateViewController(withIdentifier: "Dashboard") as! DashboardController
                        let destViewController : UIViewController = mainStoryboard.instantiateViewController(withIdentifier: "CreditDebitNote")
                        rootViewController.pushViewController(vcHome, animated: true)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { // change 2 to desired number of seconds
                            rootViewController.pushViewController(destViewController, animated: true)
                        }
                        
                        wasAppKilled = false
                        
                        
                    }else{
                        let topViewController : UIViewController = (rootViewController.topViewController)!
                        let destViewController : UIViewController = mainStoryboard.instantiateViewController(withIdentifier: "CreditDebitNote")
                        if (topViewController.restorationIdentifier! == destViewController.restorationIdentifier!){
                            // print("Same VC")
                        } else {
                            rootViewController.pushViewController(destViewController, animated: true)
                        }
                    }
                    
                    break
                    
                case ("view combo"):
                    
                    if(wasAppKilled){
                        let vcHome = mainStoryboard.instantiateViewController(withIdentifier: "Dashboard") as! DashboardController
                        let destViewController : UIViewController = mainStoryboard.instantiateViewController(withIdentifier: "ComboScheme")
                        rootViewController.pushViewController(vcHome, animated: true)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { // change 2 to desired number of seconds
                            rootViewController.pushViewController(destViewController, animated: true)
                        }
                        
                        wasAppKilled = false
                        
                        
                    }else{
                        let topViewController : UIViewController = (rootViewController.topViewController)!
                        let destViewController : UIViewController = mainStoryboard.instantiateViewController(withIdentifier: "ComboScheme")
                        if (topViewController.restorationIdentifier! == destViewController.restorationIdentifier!){
                            // print("Same VC")
                        } else {
                            rootViewController.pushViewController(destViewController, animated: true)
                        }
                    }
                    
                    break
                    
                case ("combo summary"):
                    
                    if(wasAppKilled){
                        let vcHome = mainStoryboard.instantiateViewController(withIdentifier: "Dashboard") as! DashboardController
                        let destViewController : UIViewController = mainStoryboard.instantiateViewController(withIdentifier: "ComboSummaryController")
                        rootViewController.pushViewController(vcHome, animated: true)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { // change 2 to desired number of seconds
                            rootViewController.pushViewController(destViewController, animated: true)
                        }
                        
                        wasAppKilled = false
                        
                        
                    }else{
                        let topViewController : UIViewController = (rootViewController.topViewController)!
                        let destViewController : UIViewController = mainStoryboard.instantiateViewController(withIdentifier: "ComboSummaryController")
                        if (topViewController.restorationIdentifier! == destViewController.restorationIdentifier!){
                            // print("Same VC")
                        } else {
                            rootViewController.pushViewController(destViewController, animated: true)
                        }
                    }
                    
                    break
                    
                case ("price list"):
                    
                    if(wasAppKilled){
                        let vcHome = mainStoryboard.instantiateViewController(withIdentifier: "Dashboard") as! DashboardController
                        let destViewController : UIViewController = mainStoryboard.instantiateViewController(withIdentifier: "PriceList")
                        rootViewController.pushViewController(vcHome, animated: true)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { // change 2 to desired number of seconds
                            rootViewController.pushViewController(destViewController, animated: true)
                        }
                        
                        wasAppKilled = false
                        
                        
                    }else{
                        let topViewController : UIViewController = (rootViewController.topViewController)!
                        let destViewController : UIViewController = mainStoryboard.instantiateViewController(withIdentifier: "PriceList")
                        if (topViewController.restorationIdentifier! == destViewController.restorationIdentifier!){
                            // print("Same VC")
                        } else {
                            rootViewController.pushViewController(destViewController, animated: true)
                        }
                    }
                    
                    break
                    
                case ("catalogue"):
                    
                    if(wasAppKilled){
                        let vcHome = mainStoryboard.instantiateViewController(withIdentifier: "Dashboard") as! DashboardController
                        let destViewController : UIViewController = mainStoryboard.instantiateViewController(withIdentifier: "CatalogueList")
                        rootViewController.pushViewController(vcHome, animated: true)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { // change 2 to desired number of seconds
                            rootViewController.pushViewController(destViewController, animated: true)
                        }
                        
                        wasAppKilled = false
                        
                        
                    }else{
                        let topViewController : UIViewController = (rootViewController.topViewController)!
                        let destViewController : UIViewController = mainStoryboard.instantiateViewController(withIdentifier: "CatalogueList")
                        if (topViewController.restorationIdentifier! == destViewController.restorationIdentifier!){
                            // print("Same VC")
                        } else {
                            rootViewController.pushViewController(destViewController, animated: true)
                        }
                    }
                    
                    break
                    
                case ("active scheme"):
                    
                    if(wasAppKilled){
                        let vcHome = mainStoryboard.instantiateViewController(withIdentifier: "Dashboard") as! DashboardController
                        let destViewController : UIViewController = mainStoryboard.instantiateViewController(withIdentifier: "ActiveScheme")
                        rootViewController.pushViewController(vcHome, animated: true)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { // change 2 to desired number of seconds
                            rootViewController.pushViewController(destViewController, animated: true)
                        }
                        
                        wasAppKilled = false
                        
                        
                    }else{
                        let topViewController : UIViewController = (rootViewController.topViewController)!
                        let destViewController : UIViewController = mainStoryboard.instantiateViewController(withIdentifier: "ActiveScheme")
                        if (topViewController.restorationIdentifier! == destViewController.restorationIdentifier!){
                            // print("Same VC")
                        } else {
                            rootViewController.pushViewController(destViewController, animated: true)
                        }
                    }
                    
                    break
                    
                case ("policy"):
                    
                    if(wasAppKilled){
                        let vcHome = mainStoryboard.instantiateViewController(withIdentifier: "Dashboard") as! DashboardController
                        let destViewController : UIViewController = mainStoryboard.instantiateViewController(withIdentifier: "Policy")
                        rootViewController.pushViewController(vcHome, animated: true)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { // change 2 to desired number of seconds
                            rootViewController.pushViewController(destViewController, animated: true)
                        }
                        
                        wasAppKilled = false
                        
                        
                    }else{
                        let topViewController : UIViewController = (rootViewController.topViewController)!
                        let destViewController : UIViewController = mainStoryboard.instantiateViewController(withIdentifier: "Policy")
                        if (topViewController.restorationIdentifier! == destViewController.restorationIdentifier!){
                            // print("Same VC")
                        } else {
                            rootViewController.pushViewController(destViewController, animated: true)
                        }
                    }
                    
                    break
                    
                case ("Technical Specs"):
                    
                    if(wasAppKilled){
                        let vcHome = mainStoryboard.instantiateViewController(withIdentifier: "Dashboard") as! DashboardController
                        let destViewController : UIViewController = mainStoryboard.instantiateViewController(withIdentifier: "TechnicalSpecs")
                        rootViewController.pushViewController(vcHome, animated: true)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { // change 2 to desired number of seconds
                            rootViewController.pushViewController(destViewController, animated: true)
                        }
                        
                        wasAppKilled = false
                        
                        
                    }else{
                        let topViewController : UIViewController = (rootViewController.topViewController)!
                        let destViewController : UIViewController = mainStoryboard.instantiateViewController(withIdentifier: "TechnicalSpecs")
                        if (topViewController.restorationIdentifier! == destViewController.restorationIdentifier!){
                            // print("Same VC")
                        } else {
                            rootViewController.pushViewController(destViewController, animated: true)
                        }
                    }
                    
                    break
                    
                default:
                    let vcHome = mainStoryboard.instantiateViewController(withIdentifier: "Dashboard") as! DashboardController
                    rootViewController.pushViewController(vcHome, animated: true)
                }
            }
            
            if(redirectToActivity.isEqual("Web")){
                let vcWebView = mainStoryboard.instantiateViewController(withIdentifier: "WebScreen") as! WebViewController
                vcWebView.strUrl = redirecturl
                rootViewController.navigationBar.backItem?.title = "";
                rootViewController.present(vcWebView, animated: true)
            }
          
            if(informToServer.isEqual("1")){
                if (Utility.isConnectedToNetwork()) {
                    informToServerApi()
                }
            }
            
        }
        completionHandler()
    }
    
    
    func informToServerApi(){
        var urlNotifyToServer = "https://api.goldmedalindia.in/api/AddLogToServer";
    
        let json: [String: Any] =
            ["CIN":cin,"ClientSecret":"sgupta","DeviceId":("\(tokenString)"),"NotificationId":notificationId]
        
        print("INFORM SERVER JSON - - - ",json)
        
        let manager =  DataManager.shared
        
        manager.makeAPICall(url: urlNotifyToServer, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            
            do {
            
                let responseData =   try JSONSerialization.jsonObject(with: data!, options: .mutableContainers)
                
            } catch let errorData {
                print(errorData.localizedDescription)
            }
        }) { (Error) in
            print(Error?.localizedDescription)
        }
     
    }
    
 
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
    }
    
}
