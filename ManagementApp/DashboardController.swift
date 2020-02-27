
import UIKit
import FirebaseAnalytics

class DashboardController: BaseViewController {
    
    //Outlets...
    @IBOutlet weak var menuDashboard: UIBarButtonItem!
    
    //Declarations...
    var tabs = [
        ViewPagerTab(title: "SALES", image: UIImage(named: "dashboard_outstanding_icon")),
        ViewPagerTab(title: "ORDERS", image: UIImage(named: "dashboard_order_icon")),
        ViewPagerTab(title: "STOCK", image: UIImage(named: "dashboard_sales_icon")),
        ViewPagerTab(title: "ACCOUNT", image: UIImage(named: "dashboard_scheme_icon")),
        ]
    var viewPager:ViewPagerController!
    var options:ViewPagerOptions!
    var searchData = [SearchDealers]()
    var searchDealers = [SearchDealersObj]()
    var isAppLaunched = Bool()
    
    override func viewDidLoad() {
        apiGetAllDealers()
        super.viewDidLoad()
        let imageView = UIImageView(image:UIImage(named: "dashboard_logo.png"))
        self.navigationItem.titleView = imageView
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        Analytics.setScreenName("DASHBOARD SCREEN", screenClass: "DashboardController")
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        
        if(isAppLaunched){
            
            var prevDate = UserDefaults.standard.object(forKey: "mpinTime") as? Date ?? nil
            
            let currDate = Date()
            let lastTime = currDate.addingTimeInterval(-1800)
            
            print("DATE  1 - - - ",prevDate) // 2016-12-19 21:52:04 +0000
            print("DATE  2 - - - ",lastTime) // 2016-12-19 20:52:04 +0000
            
            if(prevDate != nil)
            {
                if(lastTime > (prevDate)!){
                    print("SHOW MPIN")
                    appDelegate.checkMpin()
                }else{
                    print("HIDE MPIN")
                }
                
            }else{
                print("SHOW MPIN")
                appDelegate.checkMpin()
            }
            
        }
        
        addSlideMenuButton()
        
        // Do any additional setup after loading the view.
        self.edgesForExtendedLayout = UIRectEdge.init(rawValue: 0)
        
        options = ViewPagerOptions(viewPagerWithFrame: self.view.bounds)
        options.tabType = ViewPagerTabType.imageWithText
        options.tabViewImageSize = CGSize(width: 20, height: 20)
        options.tabViewTextFont = UIFont.systemFont(ofSize: 13)
        options.isEachTabEvenlyDistributed = true
        options.tabViewBackgroundDefaultColor = UIColor.white
        if #available(iOS 11.0, *) {
            options.tabIndicatorViewBackgroundColor = UIColor.init(named: "ColorRed")!
        } else {
            options.tabIndicatorViewBackgroundColor = UIColor.red
        }
        options.fitAllTabsInView = true
        options.tabViewPaddingLeft = 20
        options.tabViewPaddingRight = 20
        options.isTabHighlightAvailable = false
        //options.viewPagerTransitionStyle = .pageCurl
        viewPager = ViewPagerController()
        viewPager.options = options
        viewPager.dataSource = self
        viewPager.delegate = self
        
        self.addChildViewController(viewPager)
        self.view.addSubview(viewPager.view)
        viewPager.didMove(toParentViewController: self)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //API Function...
    func apiGetAllDealers(){
        let json: [String: Any] = ["CIN":UserDefaults.standard.value(forKey: "userCIN") as! String,"Category":UserDefaults.standard.value(forKey: "userCategory") as! String,"ClientSecret":"ClientSecret"]
        let manager =  DataManager.shared
        
        manager.makeAPICall(url: "https://api.goldmedalindia.in/api/getManagementDealerDetails", params: json, method: .POST, success: { (response) in
            let data = response as? Data
            
            do {
                self.searchData = try JSONDecoder().decode([SearchDealers].self, from: data!)
                self.searchDealers  = self.searchData[0].data!
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.dealerData = self.searchDealers
                ViewControllerUtils.sharedInstance.removeLoader()
            } catch let errorData {
                print(errorData.localizedDescription)
                ViewControllerUtils.sharedInstance.removeLoader()
            }
        }) { (Error) in
            print(Error?.localizedDescription as Any)
            ViewControllerUtils.sharedInstance.removeLoader()
        }
        
    }
    
}


extension DashboardController: ViewPagerControllerDataSource {
    
    func numberOfPages() -> Int {
        return tabs.count
    }
    
    func viewControllerAtPosition(position:Int) -> UIViewController {
        var vc = UIViewController()
        if position == 0
        {
            vc = self.storyboard?.instantiateViewController(withIdentifier: "SalesPay") as! SalesPaymentViewController
        }
        else if position == 1
        {
            vc = self.storyboard?.instantiateViewController(withIdentifier: "DashboardOrder") as! DashboardOrderViewController
        }
        else if position == 2
        {
            vc = self.storyboard?.instantiateViewController(withIdentifier: "StockReport") as! StockViewController
        }
        else if position == 3
        {
            vc = self.storyboard?.instantiateViewController(withIdentifier: "ExpenseComparison") as! ExpenseComparisonController
        }
        return vc
    }
    
    func tabsForPages() -> [ViewPagerTab] {
        return tabs
    }
    
    func startViewPagerAtIndex() -> Int {
        return 0
    }
}

extension DashboardController: ViewPagerControllerDelegate {
    func willMoveToControllerAtIndex(index:Int) {
        print("Moving to page \(index)")
    }
    
    func didMoveToControllerAtIndex(index: Int) {
        print("Moved to page \(index)")
    }
}

