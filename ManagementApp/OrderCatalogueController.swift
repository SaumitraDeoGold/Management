//
//  OrderCatalogueController.swift
//  DealorsApp
//
//  Created by Goldmedal on 12/7/18.
//  Copyright © 2018 Goldmedal. All rights reserved.
//

import UIKit
import FirebaseAnalytics


class OrderCatalogueController: UIViewController, UISearchBarDelegate,UITableViewDelegate,UITableViewDataSource,CatalogueListDelegate,PopupDateDelegate{
    
    @IBOutlet weak var noDataView: NoDataView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btnViewCart: UIButton!
     @IBOutlet weak var imvBack: UIImageView!
     @IBOutlet weak var imvcatalogueImage: UIImageView!
     @IBOutlet weak var vwHorizontalStrip: UIView!
    @IBOutlet weak var searchBar: RoundSearchBar!
     var strSearchText = ""
    
    var OrderCatalogueElementMain = [CatalogueListElement]()
    var OrderCatalogueArray = [CatalogueObj]()
    var OrderCatalogueArrayMain = [[CatalogueObj]]()
    var OrderCatalogueSection = [String]()
  
    var OrderCatalogueApi = ""
    var strCin = ""
    var divId = Int()
    var catId = Int()
    
    var tabs = [ViewPagerTab]()
    var viewPager:ViewPagerController!
    var options:ViewPagerOptions!
    
    var sectionPos = 0
    var tempSection = -1
   
    var sectionOfItem:Int? = 0
    var rowOfItem:Int? = 0
    var searchClicked = false
    
    var totalItemsInCart = 0
   
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.noDataView.hideView(view: self.noDataView)
        
        let loginData =  UserDefaults.standard.value(forKey: "loginData") as? Dictionary ?? [:]
        strCin = loginData["userlogid"] as? String ?? ""
        
        //        let initialData =  UserDefaults.standard.value(forKey: "initialData") as? Dictionary ?? [:]
        //        OrderDetailApi = (initialData["baseApi"] as? String ?? "")+""+(initialData["comboSchemes"] as? String ?? "")
        OrderCatalogueApi = "https://api.goldmedalindia.in//api/getOrderCatItemDetails"
        
        // Do any additional setup after loading the view.
        if (Utility.isConnectedToNetwork()) {
            print("Internet connection available")
            self.apiOrderCatalogueList()
            self.noDataView.hideView(view: self.noDataView)
        }
        else{
            print("No internet connection available")
            
            let alert = UIAlertView(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
            self.noDataView.showView(view: self.noDataView, from: "NET")
        }
        
        let tabBack = UITapGestureRecognizer(target: self, action: #selector(self.tapFunction))
        imvBack.addGestureRecognizer(tabBack)
        
        if let arrViewCartData = UserDefaults.standard.object(forKey: "addToCart") as? Data {
            let decoder = JSONDecoder()
            if var decodedData = try? decoder.decode([[OrderDetailData]].self, from: arrViewCartData) {
                print("RETRIEVED CART ARR ------- ",decodedData)
                if(decodedData.count > 0){
                    let joined = Array(decodedData.joined())
                    totalItemsInCart = joined.count
                    
                    btnViewCart.setTitle(String(totalItemsInCart), for: .normal)
                }
            }
        }
        
        // Do any additional setup after loading the view.
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.searchBar.delegate = self;
     
        Analytics.setScreenName("VIEW CATALOGUE SCREEN", screenClass: "OrderCatalogueController")
    }
    
    @objc func tapFunction(sender:UITapGestureRecognizer) {
        print("back")
        self.dismiss(animated: true, completion: nil)
    }
    
    
    //  - - - - - - -  search filter for catalogue list  - - - - - - -
    func filterSearch(){
        let searchText = searchBar.text ?? ""
        
        var arrCatalogueItemsFilter = OrderCatalogueArray.filter { item in
            let isMatchingSearchText = item.itemnm!.lowercased().contains(searchText.lowercased())
            
            return isMatchingSearchText
        }
        
        
        if(arrCatalogueItemsFilter.count>0){
            sectionOfItem = OrderCatalogueSection.index{$0 == arrCatalogueItemsFilter[0].subcategorynm}
            rowOfItem = OrderCatalogueArrayMain[sectionOfItem!].index{$0.itemnm == arrCatalogueItemsFilter[0].itemnm}
            
            searchClicked = true
       
            self.tableView.scrollToRow(at: IndexPath(row: (rowOfItem ?? 0)!, section: (sectionOfItem ?? 0)!), at: .top, animated: true)
            
            sectionPos = (sectionOfItem ?? 0)!
            rowOfItem = (rowOfItem ?? 0)!
            
            checkPagerPosition()
        }else{
            searchClicked = false
        }
        
    }
    
   
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

        if searchText.characters.count > 0 {
            strSearchText = searchText
            filterSearch()
        }else{
            searchClicked = false
            sectionPos = 0
            checkPagerPosition()
        }

    }
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    
    func showCartValue(value: String) {
        btnViewCart.setTitle(value, for: .normal)
    }
    
    
    func apiOrderCatalogueList(){
        ViewControllerUtils.sharedInstance.showLoader()
        
       let json: [String: Any] = ["CIN":strCin,"ClientSecret":"ClientSecret","DivisionId":divId,"CategoryId":catId]
        
        DataManager.shared.makeAPICall(url: OrderCatalogueApi, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            DispatchQueue.main.async {
                do {
                    self.OrderCatalogueElementMain = try JSONDecoder().decode([CatalogueListElement].self, from: data!)
                    self.OrderCatalogueArray = self.OrderCatalogueElementMain[0].data
                   
                    let groupedDictionary = Dictionary(grouping: self.OrderCatalogueArray, by: { (order) -> String in
                        return order.subcategorynm!
                    })
                    
                    let keys = groupedDictionary.keys.sorted()
                    
                    self.OrderCatalogueSection.append(contentsOf: keys)
                    
                    keys.forEach({ (key) in
                        self.OrderCatalogueArrayMain.append(groupedDictionary[key]!)
                    })
                    
                    self.setCatalogueImage(section: self.sectionPos)
                  
                } catch let errorData {
                    print(errorData.localizedDescription)
                }
                
                if(self.OrderCatalogueSection.count>0){
                    if(self.tableView != nil)
                    {
                        self.tableView.reloadData()
                    }
                    self.addCatalogueTabs()
                    self.noDataView.hideView(view: self.noDataView)
                }else{
                    self.noDataView.showView(view: self.noDataView, from: "NDA")
                }
                
                ViewControllerUtils.sharedInstance.removeLoader()
                
            }
        }) { (Error) in
            ViewControllerUtils.sharedInstance.removeLoader()
            print(Error?.localizedDescription)
            self.noDataView.showView(view: self.noDataView, from: "ERR")
        }
        
    }



    func addCatalogueTabs(){
        // - - - - - - adding catalogue tabs - - - - - - - - - - -
        if(OrderCatalogueSection.count > 0){
            for i in 0...(OrderCatalogueSection.count - 1) {
                tabs.append(ViewPagerTab(title: OrderCatalogueSection[i], image: UIImage(named: "")))
            }
        }
        
        
        //-- - -  - - - - - -  code for showing horizontal category strip
        if(tabs.count > 0)
        {
            self.edgesForExtendedLayout = UIRectEdge.init(rawValue: 0)
            
            options = ViewPagerOptions(viewPagerWithFrame: self.view.bounds)
            options.tabType = ViewPagerTabType.basic
            options.tabViewTextFont = UIFont.systemFont(ofSize: 13)
            options.tabViewBackgroundDefaultColor = UIColor.init(named: "primaryLight")!
            
            if(tabs.count > 2){
                options.fitAllTabsInView = false
            }else{
                options.fitAllTabsInView = true
            }
            options.tabViewPaddingLeft = 20
            options.tabViewPaddingRight = 20
            options.isTabHighlightAvailable = true
            options.isTabIndicatorAvailable = false
            options.tabViewBackgroundHighlightColor = UIColor.red
            
            viewPager = ViewPagerController()
            viewPager.options = options
            viewPager.dataSource = self
            viewPager.delegate = self
            
            self.addChildViewController(viewPager)
            self.vwHorizontalStrip.addSubview(viewPager.view)
            viewPager.didMove(toParentViewController: self)
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return OrderCatalogueArrayMain[section].count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CatalogueListItemCell", for: indexPath) as! CatalogueListItemCell
        
        cell.lblCatalogueCode.text = OrderCatalogueArrayMain[indexPath.section][indexPath.row].itemcode ?? "-"
        cell.lblCatalogueName.text = OrderCatalogueArrayMain[indexPath.section][indexPath.row].itemnm?.capitalized ?? "-"
        
        cell.delegate = self
        
        return cell
    }
    

    // - - - - -  Event to figure out if scrolling has stopped completely  - - - - - - - - -
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        perform(#selector(UIScrollViewDelegate.scrollViewDidEndScrollingAnimation(_:)), with: nil, afterDelay: 0.5)
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
  
        NSObject.cancelPreviousPerformRequests(withTarget: self)
     
                let topVisibleIndexPath:IndexPath = self.tableView.indexPathsForVisibleRows![0]
        
                sectionPos = topVisibleIndexPath.section
        
                if(tempSection !=  sectionPos){
                    tempSection = sectionPos
        
                    setCatalogueImage(section: sectionPos)
                    checkPagerPosition()
        
                    print("Index Path \(topVisibleIndexPath.section)")
                }
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerCell = tableView.dequeueReusableCell(withIdentifier: "CatalogueListHeaderCell") as! CatalogueListHeaderCell
        
        headerCell.lblCatalogueHeader.text = OrderCatalogueSection[section].capitalized
     
        return headerCell
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return OrderCatalogueSection.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 45
    }
    
   
    func btnAddTapped(cell: CatalogueListItemCell) {
        let indexPath = self.tableView.indexPath(for: cell)
        
        let sb = UIStoryboard(name: "AddCatalogueItemPopup", bundle: nil)
        let popup = sb.instantiateInitialViewController()  as? AddCatalogueController
        popup?.strItemName = OrderCatalogueArrayMain[(indexPath?.section)!][(indexPath?.row)!].itemnm!
        popup?.strItemCode = OrderCatalogueArrayMain[(indexPath?.section)!][(indexPath?.row)!].itemcode!
        popup?.delegate = self
        popup?.strCin =  strCin
        
        sectionPos = (indexPath?.section)!
        setCatalogueImage(section: sectionPos)
        checkPagerPosition()
        
        self.present(popup!, animated: true)
    }
    
    
    func setCatalogueImage(section:Int)
    {
        print("SECTION IMAGE - - - - ",section ," - - - - - - -",OrderCatalogueArrayMain[section][0].subcategoryurl)
        if OrderCatalogueArrayMain[section][0].subcategoryurl != ""
        {
            imvcatalogueImage.sd_setImage(with: URL(string: OrderCatalogueArrayMain[section][0].subcategoryurl ?? ""), placeholderImage: UIImage(named: "no_image_icon.png"))
        }
    }
    
    
    
    func checkPagerPosition(){

        if(viewPager != nil){
            viewPager.displayViewController(atIndex: sectionPos)
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
   
    // - - - - - - - --  -- -- - - - - - - --  -- - -- -  -- -  clicked view cart - - - - - - -- - - - - - - --  -- - -- -  -- 
    @IBAction func clicked_viewCart(_ sender: UIButton) {
        
        weak var pvc = self.presentingViewController
        
        self.dismiss(animated: false, completion: {
            let vcViewCart = self.storyboard?.instantiateViewController(withIdentifier: "OrderViewCart") as! OrderViewCartController
            ViewControllerUtils.sharedInstance.removeLoader()
            pvc?.present(vcViewCart, animated: false, completion: nil)
        })
    }
    
}


extension OrderCatalogueController: ViewPagerControllerDataSource {
    
    func numberOfPages() -> Int {
        return tabs.count
    }
    
    func viewControllerAtPosition(position:Int) -> UIViewController {
        let vc = UIViewController()
     
        if(OrderCatalogueArrayMain[position].count > 0 ){
            if(searchClicked){
             self.tableView.scrollToRow(at: IndexPath(row: rowOfItem!, section: sectionOfItem!), at: .top, animated: true)
             strSearchText = ""
            }
            else{
             self.tableView.scrollToRow(at: IndexPath(row: 0, section: position), at: .top, animated: true)
            }
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

extension OrderCatalogueController: ViewPagerControllerDelegate {
    
    func willMoveToControllerAtIndex(index:Int) {
        print("Moving to page \(index)")
    }
    
    func didMoveToControllerAtIndex(index: Int) {
        print("Moved to page \(index)")
    }
}


