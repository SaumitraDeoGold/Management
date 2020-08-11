//
//  TODViewController.swift
//  DealorsApp
//
//  Created by Goldmedal on 5/17/19.
//  Copyright © 2019 Goldmedal. All rights reserved.
//

import UIKit
import FirebaseAnalytics
import DropDown
 

class TodAgreementController: BaseViewController {
    
    var initTabPosition = 0
    var checkCount:Int = 0
    
    var tabs = [ViewPagerTab]()
    
    var viewPager:ViewPagerController!
    var options:ViewPagerOptions!
    
    var arrGrpTabs = [String]()
    
    @IBOutlet weak var noDataView: NoDataView!
    var strCin = ""
    var selectedGrpId = ""
    var strPartyName = ""
    var strApiTOD = ""
    var strApiSubmitTOD = ""
    
    let dropDown = DropDown()
    @IBOutlet weak var lblDropdownText: UILabel!
    @IBOutlet weak var vwDropDown: RoundView!
    
    @IBOutlet weak var vwHorizontalStrip: UIView!
    
    @IBOutlet weak var scrTODMain: UIScrollView!
    
    @IBOutlet weak var lblGrpHeader: UILabel!
  
    @IBOutlet weak var lblShortFallM1: UILabel!
    @IBOutlet weak var lblTargetM1: UILabel!
    @IBOutlet weak var lblSaleM1: UILabel!
    @IBOutlet weak var lblEarnedM1: UILabel!
    @IBOutlet weak var lblTradeM1: UILabel!
    @IBOutlet weak var lblProjM1: UILabel!
    @IBOutlet weak var lblSalesM1Percent: UILabel!
    @IBOutlet weak var lblTargetM1Percent: UILabel!
    
    @IBOutlet weak var lblShortFallM2: UILabel!
    @IBOutlet weak var lblTargetM2: UILabel!
    @IBOutlet weak var lblSaleM2: UILabel!
    @IBOutlet weak var lblEarnedM2: UILabel!
    @IBOutlet weak var lblTradeM2: UILabel!
    @IBOutlet weak var lblProjM2: UILabel!
    @IBOutlet weak var lblSalesM2Percent: UILabel!
    @IBOutlet weak var lblTargetM2Percent: UILabel!
    
    @IBOutlet weak var lblShortFallM3: UILabel!
    @IBOutlet weak var lblTargetM3: UILabel!
    @IBOutlet weak var lblSaleM3: UILabel!
    @IBOutlet weak var lblEarnedM3: UILabel!
    @IBOutlet weak var lblTradeM3: UILabel!
    @IBOutlet weak var lblProjM3: UILabel!
    @IBOutlet weak var lblSalesM3Percent: UILabel!
    @IBOutlet weak var lblTargetM3Percent: UILabel!
    
    @IBOutlet weak var lblShortFallQtr: UILabel!
    @IBOutlet weak var lblTargetQtr: UILabel!
    @IBOutlet weak var lblSaleQtr: UILabel!
    @IBOutlet weak var lblEarnedQtr: UILabel!
    @IBOutlet weak var lblTradeQtr: UILabel!
    @IBOutlet weak var lblProjQtr: UILabel!
    @IBOutlet weak var lblSalesQtrPercent: UILabel!
    @IBOutlet weak var lblTargetQtrPercent: UILabel!
    
    @IBOutlet weak var lblShortFallYr: UILabel!
    @IBOutlet weak var lblTargetYr: UILabel!
    @IBOutlet weak var lblSaleYr: UILabel!
    @IBOutlet weak var lblEarnedYr: UILabel!
    @IBOutlet weak var lblTradeYr: UILabel!
    @IBOutlet weak var lblProjYr: UILabel!
    @IBOutlet weak var lblSalesYrPercent: UILabel!
    @IBOutlet weak var lblTargetYrPercent: UILabel!
    
    @IBOutlet weak var lblMonth1Name: UILabel!
    @IBOutlet weak var lblMonth2Name: UILabel!
    @IBOutlet weak var lblMonth3Name: UILabel!
    @IBOutlet weak var lblQtrName: UILabel!
  
    @IBOutlet weak var progressM1: UIProgressView!
    @IBOutlet weak var progressM2: UIProgressView!
    @IBOutlet weak var progressM3: UIProgressView!
    @IBOutlet weak var progressQtr: UIProgressView!
    @IBOutlet weak var progressYearly: UIProgressView!
    
    //@IBOutlet weak var btnSubmit: UIButton!
    @IBOutlet weak var btnSummary: UIButton!
    
    var selectedQtr = 0
    
    var salesAmount = 0.0
    var targetAmount = 0.0
    var earnedAmount = 0.0
    
    var strGrpId = ""
    
    var slabQtrHeader = [["APR","MAY","JUN","Q1"],["JUL","AUG","SEP","Q2"],["OCT","NOV","DEC","Q3"], ["JAN","FEB","MAR","Q4"]]
    
    var TODElementMain = [TODElement]()
    var TODDataMain = [TODObj]()
    
    var TODSubmitMain = [TODSubmitElement]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
       self.noDataView.showView(view: self.noDataView, from: "LOADER")
        
        
        
        self.title = strPartyName
        
        addBackButton()
        
        dropDown.dataSource = ["Q1", "Q2","Q3", "Q4"]
        
        let gesture = UITapGestureRecognizer(target: self, action: Selector("clickDropdown:"))
        vwDropDown.addGestureRecognizer(gesture)
        
        lblDropdownText.text = dropDown.dataSource[0]
        
        dropDown.dismissMode = .onTap
        
        let loginData =  UserDefaults.standard.value(forKey: "loginData") as? Dictionary ?? [:]
     //   strCin = loginData["userlogid"] as? String ?? ""
        
        let initialData =  UserDefaults.standard.value(forKey: "initialData") as? Dictionary ?? [:]
//        strApiTOD = "https://test2.goldmedalindia.in/api/getTodList"
//        strApiSubmitTOD = "https://test2.goldmedalindia.in/api/submitGroupTOD"
        strApiTOD = (initialData["baseApi"] as? String ?? "")+""+(initialData["todList"] as? String ?? "")
        strApiSubmitTOD = (initialData["baseApi"] as? String ?? "")+""+(initialData["submitGroupTOD"] as? String ?? "")
        
        if (Utility.isConnectedToNetwork()) {
            print("Internet connection available")
            OperationQueue.main.addOperation {
                self.apiTOD()
                self.noDataView.hideView(view: self.noDataView)
            }
        }
        else {
            print("No internet connection available")
            var alert = UIAlertView(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
            self.noDataView.showView(view: self.noDataView, from: "NET")
        }
        
        Analytics.setScreenName("TOD AGREEMENT", screenClass: "TodAgreementController")
       // SQLiteDB.instance.addAnalyticsData(ScreenName: "TOD SCREEN", ScreenId: Int64(GlobalConstants.init().TOD_SCREEN))
        
    }
    
    
    
    @IBAction func SummarySelected(_ sender: UIButton) {
        if (Utility.isConnectedToNetwork()) {
            print("Internet connection available")
           
            let sb = UIStoryboard(name: "TodDetailPopup", bundle: nil)
            let popup = sb.instantiateInitialViewController() as? TodDetailPopupController
            popup?.strCin = strCin
            self.present(popup!, animated: true)
            
        }
        else {
            print("No internet connection available")
            var alert = UIAlertView(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
        }
    }
    
   
    @objc func clickDropdown(_ sender:UITapGestureRecognizer){
        
        dropDown.show()
        
        // The view to which the drop down will appear on
        dropDown.anchorView = vwDropDown // UIView or UIBarButtonItem
        
        
        // Action triggered on selection
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            print("Selected item: \(item) at index: \(index)")
            self.lblDropdownText.text = item
            self.selectedQtr = index
            
            self.dropDown.hide()
            
            self.setQtrMnths()
            
        }
    }
    
    
    // - - -  - - - - - - - - API to get list of TOD  - - - - - - --  - - - - -
    func apiTOD(){
        ViewControllerUtils.sharedInstance.showLoader()
        
        
        let json: [String: Any] =
            ["CIN":strCin,"ClientSecret":"ClientSecret"]
        
        print("TOD JSON ------ ",json)
        
        DataManager.shared.makeAPICall(url: strApiTOD, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            print("strApiTOD - - - - - ",self.strApiTOD,"-----",json)
            
            DispatchQueue.main.async {
                do {
                    self.TODElementMain = try JSONDecoder().decode([TODElement].self, from: data!)
                    self.TODDataMain = self.TODElementMain[0].data
                    
                    if(self.TODDataMain.count > 0){
                        print("Inside TOD")
                    
                        for i in 0...(self.TODDataMain.count - 1){
                           
                            if(Int(self.TODDataMain[i].groupId ?? "0") == 4){
                                self.TODDataMain[i].groupImage = "icon_cables"
                            }
                           else if(Int(self.TODDataMain[i].groupId ?? "0") == 5){
                                self.TODDataMain[i].groupImage = "icon_lights"
                            }
                           else if(Int(self.TODDataMain[i].groupId ?? "0") == 7){
                              self.TODDataMain[i].groupImage = "icon_wiring_devices"
                            }
                           else if(Int(self.TODDataMain[i].groupId ?? "0") == 8){
                                self.TODDataMain[i].groupImage = "icon_pipes"
                            }
                           else{
                                 self.TODDataMain[i].groupImage = ""
                            }
                        }
                        
                        
                        self.addGrpTabs()
                        self.setQtrMnths()
                    }
                    
                    if(self.TODDataMain.count>0){
                        self.noDataView.hideView(view: self.noDataView)
                    }else{
                        self.noDataView.showView(view: self.noDataView, from: "NDA")
                    }
                    
                    ViewControllerUtils.sharedInstance.removeLoader()
                } catch let errorData {
                    print(errorData.localizedDescription)
                    self.noDataView.showView(view: self.noDataView, from: "NDA")
                    ViewControllerUtils.sharedInstance.removeLoader()
                }
                
                
            }
        }) { (Error) in
            ViewControllerUtils.sharedInstance.removeLoader()
            print(Error?.localizedDescription)
            self.noDataView.showView(view: self.noDataView, from: "ERR")
        }
    }
    
    
    // - - -  - - - - - - - - API to submit TOD obj - - - - - - --  - - - - -
    func apiSubmitTOD(){
        ViewControllerUtils.sharedInstance.showLoader()
        
        
        let json: [String: Any] =
            ["CIN":strCin,"ClientSecret":"ClientSecret","groupid":strGrpId]
        
        print("TOD SUBMIT JSON ------ ",json)
        
        DataManager.shared.makeAPICall(url: strApiSubmitTOD, params: json, method: .POST, success: { (response) in
            let data = response as? Data
             print("strApiSubmitTOD - - - - - ",self.strApiSubmitTOD,"-----",json)
            
            DispatchQueue.main.async {
                do {
                    self.TODSubmitMain = try JSONDecoder().decode([TODSubmitElement].self, from: data!)
                    
                    let result = self.TODSubmitMain[0].result
                    let msg = self.TODSubmitMain[0].message
                    
                    if(result ?? false){
                        var alert = UIAlertView(title: "Success!!!", message: msg, delegate: nil, cancelButtonTitle: "OK")
                        alert.show()
                        
                        //  btnSubmit.isHidden = true
                       // self.btnSubmit.setTitle("Accepted", for: .normal)
                      //  self.btnSubmit.setTitleColor(UIColor.green, for: .normal)
                       // self.btnSubmit.backgroundColor = UIColor.clear
                      //  self.btnSubmit.isEnabled = false
                      
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { self.TODDataMain.removeAll()
                            self.apiTOD()
                        }
                       
                    }else{
                        var alert = UIAlertView(title: "Failed", message: msg, delegate: nil, cancelButtonTitle: "OK")
                        alert.show()
                    }
                    
                    ViewControllerUtils.sharedInstance.removeLoader()
                } catch let errorData {
                    print(errorData.localizedDescription)
                    
                    ViewControllerUtils.sharedInstance.removeLoader()
                    
                    var alert = UIAlertView(title: "Server Error", message: "Data not available", delegate: nil, cancelButtonTitle: "OK")
                    alert.show()
                }
                
            }
        }) { (Error) in
            ViewControllerUtils.sharedInstance.removeLoader()
            print(Error?.localizedDescription)
            
            var alert = UIAlertView(title: "Server Error", message: "Server Error", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
        }
    }
    
    
    func addGrpTabs(){
        tabs.removeAll()
        // - - - - - - adding catalogue tabs - - - - - - - - - - -
        if(TODDataMain.count > 0){
            for i in 0...(TODDataMain.count - 1) {
                
                if(TODDataMain[i].groupId == selectedGrpId){
                    initTabPosition = i
                }
                tabs.append(ViewPagerTab(title: TODDataMain[i].groupName ?? "-", image: UIImage(named: TODDataMain[i].groupImage ?? "-")))
            }
        }
        
        
        //-- - -  - - - - - -  code for showing horizontal category strip
        if(tabs.count > 0)
        {
            //self.edgesForExtendedLayout = UIRectEdge.init(rawValue: 0)
            
            options = ViewPagerOptions(viewPagerWithFrame: self.view.bounds)
            options.tabType = ViewPagerTabType.image
            options.tabViewTextFont = UIFont.systemFont(ofSize: 14)
            options.tabViewBackgroundDefaultColor = UIColor.init(named: "primaryLight")!
            options.fitAllTabsInView = true
            options.tabViewPaddingLeft = 20
            options.tabViewPaddingRight = 20
            options.isTabHighlightAvailable = false
            options.isTabIndicatorAvailable = true
            if #available(iOS 11.0, *) {
                options.tabIndicatorViewBackgroundColor = UIColor.init(named: "ColorRed")!
            } else {
                options.tabIndicatorViewBackgroundColor = UIColor.red
            }
            
            viewPager = ViewPagerController()
            viewPager.options = options
            viewPager.dataSource = self
            viewPager.delegate = self
            
            self.addChildViewController(viewPager)
            self.vwHorizontalStrip.addSubview(viewPager.view)
            viewPager.didMove(toParentViewController: self)
        }
        
    }
    
    
    
    func setQtrMnths(){
        print("selectedQtr - - ------",selectedQtr,"-----",initTabPosition)
        
        self.scrTODMain.setContentOffset(CGPoint(x: 0,y: 0), animated: true)
        
        self.lblMonth1Name.text = slabQtrHeader[selectedQtr][0]
        self.lblMonth2Name.text = slabQtrHeader[selectedQtr][1]
        self.lblMonth3Name.text = slabQtrHeader[selectedQtr][2]
        self.lblQtrName.text = slabQtrHeader[selectedQtr][3]
        
        strGrpId = (self.TODDataMain[initTabPosition].groupId ?? "-")!
        
        lblGrpHeader.text = (self.TODDataMain[initTabPosition].groupName ?? "-")!
        
        print("TOD IS-ACCEPT - - - - -",self.TODDataMain[initTabPosition].isAccept)
        
       
        //*****************  setting yearly data here - - - -
        self.lblTargetYr.text = "\u{20B9}" + (self.TODDataMain[self.initTabPosition].yearlyTargetAmt ?? "0.0")!
        self.lblSaleYr.text = "\u{20B9}" + (self.TODDataMain[self.initTabPosition].yearlySalesAmt ?? "0.0")!
        
        var shortFallYr = 0.0
        shortFallYr = Double(self.TODDataMain[initTabPosition].yearlyTargetAmt ?? "0.0")! - Double(self.TODDataMain[initTabPosition].yearlySalesAmt  ?? "0.0")!
        
        if(shortFallYr > 0){
            self.lblShortFallYr.text = "Short Fall - \u{20B9}" + String(Int(shortFallYr))
        }else{
            self.lblShortFallYr.text = "Short Fall - \u{20B9}" + "0"
        }
        
        self.lblEarnedYr.text = "\u{20B9}" + ( self.TODDataMain[self.initTabPosition].yearlyearnedAmt ?? "0.0")!
        
        var targetYr = Double(self.TODDataMain[self.initTabPosition].yearlyTargetAmt ?? "0.0")!
        var saleYr = Double(self.TODDataMain[self.initTabPosition].yearlySalesAmt ?? "0.0")!
        
        
        var salePercentYr = 0.0
        var targetPercentYr = 0.0
        if(saleYr < targetYr){
            salePercentYr = Double((saleYr/targetYr))
            targetYr = (1.0 - salePercentYr)
        }else{
            salePercentYr = 1.0
            targetYr = 0.0
        }
        
        
        self.lblProjYr.text = "\u{20B9}" + (self.TODDataMain[self.initTabPosition].yearlyprojectSale ?? "0.0")!
        self.lblTradeYr.text = "\u{20B9}" + (self.TODDataMain[self.initTabPosition].yearlytradeSale ?? "0.0")!
        
        self.progressYearly.setProgress(Float(salePercentYr), animated: false)
       
        self.lblSalesYrPercent.text = String(Int(round(salePercentYr*100)))+"%"
        self.lblTargetYrPercent.text = String(Int(round(targetYr*100)))+"%"
        
        // *********************  data for qtr 1 **********************
        if(selectedQtr == 0){
            
            self.lblTargetM1.text = "\u{20B9}" + (self.TODDataMain[initTabPosition].apramt ?? "0.0")!
                //"\u{20B9}" + (self.TODDataMain[initTabPosition].apramt ?? "0.0")!)
            self.lblSaleM1.text = "\u{20B9}" + (self.TODDataMain[initTabPosition].apramts ?? "0.0")!
            
            var shortFallM1 = 0.0
            shortFallM1 = Double(self.TODDataMain[initTabPosition].apramt ?? "0.0")! - Double(self.TODDataMain[initTabPosition].apramts ?? "0.0")!
            
            if(shortFallM1 > 0){
                 self.lblShortFallM1.text = "Short Fall - \u{20B9}" + String(Int(shortFallM1))
            }else{
                self.lblShortFallM1.text = "Short Fall - \u{20B9}" + "0"
            }
            
            
            self.lblEarnedM1.text = "\u{20B9}" + (self.TODDataMain[initTabPosition].aprearnedamt ?? "0.0")!
            var target1 = Double(self.TODDataMain[initTabPosition].apramt ?? "0.0")!
            var sale1 = Double(self.TODDataMain[initTabPosition].apramts ?? "0.0")!
            
            var salePercentM1 = 0.0
            var targetPercentM1 = 0.0
            if(sale1 < target1){
                salePercentM1 = Double((sale1/target1))
                targetPercentM1 = (1.0 - salePercentM1)
            }else{
                salePercentM1 = 1.0
                targetPercentM1 = 0.0
            }
            
            
            self.lblTargetM2.text = "\u{20B9}" + (self.TODDataMain[initTabPosition].mayamt ?? "0.0")!
            self.lblSaleM2.text = "\u{20B9}" + (self.TODDataMain[initTabPosition].mayamts ?? "0.0")!
            
            var shortFallM2 = 0.0
            shortFallM2 = Double(self.TODDataMain[initTabPosition].mayamt ?? "0.0")! - Double(self.TODDataMain[initTabPosition].mayamts ?? "0.0")!
            
            if(shortFallM2 > 0){
                self.lblShortFallM2.text = "Short Fall - \u{20B9}" + String(Int(shortFallM2))
            }else{
                self.lblShortFallM2.text = "Short Fall - \u{20B9}" + "0"
            }
            
            var target2 = Double(self.TODDataMain[initTabPosition].mayamt ?? "0.0")!
            var sale2 = Double(self.TODDataMain[initTabPosition].mayamts ?? "0.0")!
            self.lblEarnedM2.text = "\u{20B9}" + (self.TODDataMain[initTabPosition].mayearnedamt ?? "0.0")!
       
            var salePercentM2 = 0.0
            var targetPercentM2 = 0.0
            if(sale2 < target2){
                salePercentM2 = Double((sale2/target2))
                targetPercentM2 = (1.0 - salePercentM2)
            }else{
                salePercentM2 = 1.0
                targetPercentM2 = 0.0
            }
            
            
            self.lblTargetM3.text = "\u{20B9}" + (self.TODDataMain[initTabPosition].junamt ?? "0.0")!
            self.lblSaleM3.text = "\u{20B9}" + (self.TODDataMain[initTabPosition].junamts ?? "0.0")!
            
            var shortFallM3 = 0.0
            shortFallM3 = Double(self.TODDataMain[initTabPosition].junamt ?? "0.0")! - Double(self.TODDataMain[initTabPosition].junamts ?? "0.0")!
            
            if(shortFallM3 > 0){
                self.lblShortFallM3.text = "Short Fall - \u{20B9}" + String(Int(shortFallM3))
            }else{
                self.lblShortFallM3.text = "Short Fall - \u{20B9}" + "0"
            }
            
            var target3 = Double(self.TODDataMain[initTabPosition].junamt ?? "0.0")!
            var sale3 = Double(self.TODDataMain[initTabPosition].junamts ?? "0.0")!
            self.lblEarnedM3.text = "\u{20B9}" + (self.TODDataMain[initTabPosition].junearnedamt ?? "0.0")!
      
            var salePercentM3 = 0.0
            var targetPercentM3 = 0.0
            if(sale3 < target3){
                salePercentM3 = Double((sale3/target3))
                targetPercentM3 = (1.0 - salePercentM3)
            }else{
                salePercentM3 = 1.0
                targetPercentM3 = 0.0
            }
            
            self.lblSaleQtr.text = "\u{20B9}" + (self.TODDataMain[initTabPosition].q1amts ?? "0.0")!
            self.lblTargetQtr.text = "\u{20B9}" + (self.TODDataMain[initTabPosition].q1amt ?? "0.0")!
            
            var shortFallQtr = 0.0
            shortFallQtr = Double(self.TODDataMain[initTabPosition].q1amt ?? "0.0")! - Double(self.TODDataMain[initTabPosition].q1amts ?? "0.0")!
            
            if(shortFallQtr > 0){
                self.lblShortFallQtr.text = "Short Fall - \u{20B9}" + String(Int(shortFallQtr))
            }else{
                self.lblShortFallQtr.text = "Short Fall - \u{20B9}" + "0"
            }
            
            self.lblEarnedQtr.text = "\u{20B9}" + (self.TODDataMain[initTabPosition].q1earnedamt ?? "0.0")!
            
            
            var targetQ = Double(self.TODDataMain[initTabPosition].q1amt ?? "0.0")!
            var saleQ = Double(self.TODDataMain[initTabPosition].q1amts ?? "0.0")!
      
            var salePercentQ = 0.0
            var targetPercentQ = 0.0
            if(saleQ < targetQ){
                salePercentQ = Double((saleQ/targetQ))
                targetPercentQ = (1.0 - salePercentQ)
            }else{
                salePercentQ = 1.0
                targetPercentQ = 0.0
            }
            
            
            self.lblProjM1.text = "\u{20B9}" + (self.TODDataMain[initTabPosition].aprprojectsale ?? "0.0")!
            self.lblTradeM1.text = "\u{20B9}" + (self.TODDataMain[initTabPosition].aprtradesale ?? "0.0")!
            
            self.lblProjM2.text = "\u{20B9}" + (self.TODDataMain[initTabPosition].mayprojectsale ?? "0.0")!
            self.lblTradeM2.text = "\u{20B9}" + (self.TODDataMain[initTabPosition].maytradesale ?? "0.0")!
            
            self.lblProjM3.text = "\u{20B9}" + (self.TODDataMain[initTabPosition].junprojectsale ?? "0.0")!
            self.lblTradeM3.text = "\u{20B9}" + (self.TODDataMain[initTabPosition].juntradesale ?? "0.0")!
            
            self.lblProjQtr.text = "\u{20B9}" + (self.TODDataMain[initTabPosition].q1projectsale ?? "0.0")!
            self.lblTradeQtr.text = "\u{20B9}" + (self.TODDataMain[initTabPosition].q1tradesale ?? "0.0")!
            
            print("Percentage 1 - - -  ",salePercentM1,"---",salePercentM2,"---",salePercentM3,"---",salePercentQ)
            self.progressM1.setProgress(Float(salePercentM1), animated: false)
            self.progressM2.setProgress(Float(salePercentM2), animated: false)
            self.progressM3.setProgress(Float(salePercentM3), animated: false)
            self.progressQtr.setProgress(Float(salePercentQ), animated: false)
            
            self.lblSalesM1Percent.text = String(Int(round(salePercentM1*100)))+"%"
            self.lblTargetM1Percent.text = String(Int(round(targetPercentM1*100)))+"%"
            
            self.lblSalesM2Percent.text = String(Int(round(salePercentM2*100)))+"%"
            self.lblTargetM2Percent.text = String(Int(round(targetPercentM2*100)))+"%"
            
            self.lblSalesM3Percent.text = String(Int(round(salePercentM3*100)))+"%"
            self.lblTargetM3Percent.text = String(Int(round(targetPercentM3*100)))+"%"
            
            self.lblSalesQtrPercent.text = String(Int(round(salePercentQ*100)))+"%"
            self.lblTargetQtrPercent.text = String(Int(round(targetPercentQ*100)))+"%"
            
            
             // *********************  data for qtr 2 **********************
        }else if(selectedQtr == 1){
            self.lblTargetM1.text = "\u{20B9}" + (self.TODDataMain[initTabPosition].julamt ?? "0.0")!
            self.lblSaleM1.text = "\u{20B9}" + (self.TODDataMain[initTabPosition].julamts ?? "0.0")!
            
            var shortFallM1 = 0.0
            shortFallM1 = Double(self.TODDataMain[initTabPosition].julamt ?? "0.0")! - Double(self.TODDataMain[initTabPosition].julamts ?? "0.0")!
            
            if(shortFallM1 > 0){
                self.lblShortFallM1.text = "Short Fall - \u{20B9}" + String(Int(shortFallM1))
            }else{
                self.lblShortFallM1.text = "Short Fall - \u{20B9}" + "0"
            }
            
            self.lblEarnedM1.text = "\u{20B9}" + (self.TODDataMain[initTabPosition].julearnedamt ?? "0.0")!
            
            var target1 = Double(self.TODDataMain[initTabPosition].julamt ?? "0.0")!
            var sale1 = Double(self.TODDataMain[initTabPosition].julamts ?? "0.0")!
            
            var salePercentM1 = 0.0
            var targetPercentM1 = 0.0
            if(sale1 < target1){
                salePercentM1 = Double((sale1/target1))
                targetPercentM1 = (1.0 - salePercentM1)
            }else{
                salePercentM1 = 1.0
                targetPercentM1 = 0.0
            }
            
            
            
            self.lblTargetM2.text = "\u{20B9}" + (self.TODDataMain[initTabPosition].augamt ?? "0.0")!
            self.lblSaleM2.text = "\u{20B9}" + (self.TODDataMain[initTabPosition].augamts ?? "0.0")!
            
            var shortFallM2 = 0.0
            shortFallM2 = Double(self.TODDataMain[initTabPosition].augamt ?? "0.0")! - Double(self.TODDataMain[initTabPosition].augamts ?? "0.0")!
            
            if(shortFallM2 > 0){
                self.lblShortFallM2.text = "Short Fall - \u{20B9}" + String(Int(shortFallM2))
            }else{
                self.lblShortFallM2.text = "Short Fall - \u{20B9}" + "0"
            }
            
            self.lblEarnedM2.text = "\u{20B9}" + (self.TODDataMain[initTabPosition].augearnedamt ?? "0.0")!
            
            var target2 = Double(self.TODDataMain[initTabPosition].augamt ?? "0.0")!
            var sale2 = Double(self.TODDataMain[initTabPosition].augamts ?? "0.0")!
            
            var salePercentM2 = 0.0
            var targetPercentM2 = 0.0
            if(sale2 < target2){
                salePercentM2 = Double((sale2/target2))
                targetPercentM2 = (1.0 - salePercentM2)
            }else{
                salePercentM2 = 1.0
                targetPercentM2 = 0.0
            }
            
            
            
            self.lblTargetM3.text = "\u{20B9}" + (self.TODDataMain[initTabPosition].sepamt ?? "0.0")!
            self.lblSaleM3.text = "\u{20B9}" + (self.TODDataMain[initTabPosition].sepamts ?? "0.0")!
            
            var shortFallM3 = 0.0
            shortFallM3 = Double(self.TODDataMain[initTabPosition].sepamt ?? "0.0")! - Double(self.TODDataMain[initTabPosition].sepamts ?? "0.0")!
            
            if(shortFallM3 > 0){
                self.lblShortFallM3.text = "Short Fall - \u{20B9}" + String(Int(shortFallM3))
            }else{
                self.lblShortFallM3.text = "Short Fall - \u{20B9}" + "0"
            }
            
            var target3 = Double(self.TODDataMain[initTabPosition].sepamt ?? "0.0")!
            var sale3 = Double(self.TODDataMain[initTabPosition].sepamts ?? "0.0")!
            self.lblEarnedM3.text = "\u{20B9}" + (self.TODDataMain[initTabPosition].sepearnedamt ?? "0.0")!
            
            var salePercentM3 = 0.0
            var targetPercentM3 = 0.0
            if(sale3 < target3){
                salePercentM3 = Double((sale3/target3))
                targetPercentM3 = (1.0 - salePercentM3)
            }else{
                salePercentM3 = 1.0
                targetPercentM3 = 0.0
            }
            
            
            self.lblSaleQtr.text = "\u{20B9}" + (self.TODDataMain[initTabPosition].q2amts ?? "0.0")!
            self.lblTargetQtr.text = "\u{20B9}" + (self.TODDataMain[initTabPosition].q2amt ?? "0.0")!
            
            var shortFallQtr = 0.0
            shortFallQtr = Double(self.TODDataMain[initTabPosition].q2amt ?? "0.0")! - Double(self.TODDataMain[initTabPosition].q2amts ?? "0.0")!
            
            if(shortFallQtr > 0){
                self.lblShortFallQtr.text = "Short Fall - \u{20B9}" + String(Int(shortFallQtr))
            }else{
                self.lblShortFallQtr.text = "Short Fall - \u{20B9}" + "0"
            }
            
            self.lblEarnedQtr.text = "\u{20B9}" + (self.TODDataMain[initTabPosition].q2earnedamt ?? "0.0")!
            
            var targetQ = Double(self.TODDataMain[initTabPosition].q2amt ?? "0.0")!
            var saleQ = Double(self.TODDataMain[initTabPosition].q2amts ?? "0.0")!
            
            var salePercentQ = 0.0
            var targetPercentQ = 0.0
            if(saleQ < targetQ){
                salePercentQ = Double((saleQ/targetQ))
                targetPercentQ = (1.0 - salePercentQ)
            }else{
                salePercentQ = 1.0
                targetPercentQ = 0.0
            }
            
            
            
            self.lblProjM1.text = "\u{20B9}" + (self.TODDataMain[initTabPosition].julprojectsale ?? "0.0")!
            self.lblTradeM1.text = "\u{20B9}" + (self.TODDataMain[initTabPosition].jultradesale ?? "0.0")!
            
            self.lblProjM2.text = "\u{20B9}" + (self.TODDataMain[initTabPosition].augprojectsale ?? "0.0")!
            self.lblTradeM2.text = "\u{20B9}" + (self.TODDataMain[initTabPosition].augtradesale ?? "0.0")!
            
            self.lblProjM3.text = "\u{20B9}" + (self.TODDataMain[initTabPosition].sepprojectsale ?? "0.0")!
            self.lblTradeM3.text = "\u{20B9}" + (self.TODDataMain[initTabPosition].septradesale ?? "0.0")!
            
            self.lblProjQtr.text = "\u{20B9}" + (self.TODDataMain[initTabPosition].q2projectsale ?? "0.0")!
            self.lblTradeQtr.text = "\u{20B9}" + (self.TODDataMain[initTabPosition].q2tradesale ?? "0.0")!
            
             print("Percentage 2- - -  ",salePercentM1,"---",salePercentM2,"---",salePercentM3,"---",salePercentQ)
            
            self.progressM1.setProgress(Float(salePercentM1), animated: false)
            self.progressM2.setProgress(Float(salePercentM2), animated: false)
            self.progressM3.setProgress(Float(salePercentM3), animated: false)
            self.progressQtr.setProgress(Float(salePercentQ), animated: false)
            
            self.lblSalesM1Percent.text = String(Int(round(salePercentM1*100)))+"%"
            self.lblTargetM1Percent.text = String(Int(round(targetPercentM1*100)))+"%"
            
            self.lblSalesM2Percent.text = String(Int(round(salePercentM2*100)))+"%"
            self.lblTargetM2Percent.text = String(Int(round(targetPercentM2*100)))+"%"
            
            self.lblSalesM3Percent.text = String(Int(round(salePercentM3*100)))+"%"
            self.lblTargetM3Percent.text = String(Int(round(targetPercentM3*100)))+"%"
            
            self.lblSalesQtrPercent.text = String(Int(round(salePercentQ*100)))+"%"
            self.lblTargetQtrPercent.text = String(Int(round(targetPercentQ*100)))+"%"
        
            
             // *********************  data for qtr 3 **********************
        }else if(selectedQtr == 2){
            self.lblTargetM1.text = "\u{20B9}" + (self.TODDataMain[initTabPosition].octamt ?? "0.0")!
            self.lblSaleM1.text = "\u{20B9}" + (self.TODDataMain[initTabPosition].octamts ?? "0.0")!
            
            
            var shortFallM1 = 0.0
            shortFallM1 = Double(self.TODDataMain[initTabPosition].octamt ?? "0.0")! - Double(self.TODDataMain[initTabPosition].octamts ?? "0.0")!
            
            if(shortFallM1 > 0){
                self.lblShortFallM1.text = "Short Fall - \u{20B9}" + String(Int(shortFallM1))
            }else{
                self.lblShortFallM1.text = "Short Fall - \u{20B9}" + "0"
            }
            
            self.lblEarnedM1.text = "\u{20B9}" + (self.TODDataMain[initTabPosition].octearnedamt ?? "0.0")!
            
            var target1 = Double(self.TODDataMain[initTabPosition].octamt ?? "0.0")!
            var sale1 = Double(self.TODDataMain[initTabPosition].octamts ?? "0.0")!
            
            var salePercentM1 = 0.0
            var targetPercentM1 = 0.0
            if(sale1 < target1){
                salePercentM1 = Double((sale1/target1))
                targetPercentM1 = (1.0 - salePercentM1)
            }else{
                salePercentM1 = 1.0
                targetPercentM1 = 0.0
            }
            
            
            
            self.lblTargetM2.text = "\u{20B9}" + (self.TODDataMain[initTabPosition].novamt ?? "0.0")!
            self.lblSaleM2.text = "\u{20B9}" + (self.TODDataMain[initTabPosition].novamts ?? "0.0")!
            
            var shortFallM2 = 0.0
            shortFallM2 = Double(self.TODDataMain[initTabPosition].novamt ?? "0.0")! - Double(self.TODDataMain[initTabPosition].novamts ?? "0.0")!
            
            if(shortFallM2 > 0){
                self.lblShortFallM2.text = "Short Fall - \u{20B9}" + String(Int(shortFallM2))
            }else{
                self.lblShortFallM2.text = "Short Fall - \u{20B9}" + "0"
            }
            
            self.lblEarnedM2.text = "\u{20B9}" + (self.TODDataMain[initTabPosition].novearnedamt ?? "0.0")!
            
            var target2 = Double(self.TODDataMain[initTabPosition].novamt ?? "0.0")!
            var sale2 = Double(self.TODDataMain[initTabPosition].novamts ?? "0.0")!
            
            var salePercentM2 = 0.0
            var targetPercentM2 = 0.0
            if(sale2 < target2){
                salePercentM2 = Double((sale2/target2))
                targetPercentM2 = (1.0 - salePercentM2)
            }else{
                salePercentM2 = 1.0
                targetPercentM2 = 0.0
            }
            
            
            
            self.lblTargetM3.text = "\u{20B9}" + (self.TODDataMain[initTabPosition].decamt ?? "0.0")!
            self.lblSaleM3.text = "\u{20B9}" + (self.TODDataMain[initTabPosition].decamts ?? "0.0")!
            
            var shortFallM3 = 0.0
            shortFallM3 = Double(self.TODDataMain[initTabPosition].decamt ?? "0.0")! - Double(self.TODDataMain[initTabPosition].decamts ?? "0.0")!
            
            if(shortFallM3 > 0){
                self.lblShortFallM3.text = "Short Fall - \u{20B9}" + String(Int(shortFallM3))
            }else{
                self.lblShortFallM3.text = "Short Fall - \u{20B9}" + "0"
            }
            
            self.lblEarnedM3.text = "\u{20B9}" + (self.TODDataMain[initTabPosition].decearnedamt ?? "0.0")!
            
            var target3 = Double(self.TODDataMain[initTabPosition].decamt ?? "0.0")!
            var sale3 = Double(self.TODDataMain[initTabPosition].decamts ?? "0.0")!
            
            var salePercentM3 = 0.0
            var targetPercentM3 = 0.0
            if(sale3 < target3){
                salePercentM3 = Double((sale3/target3))
                targetPercentM3 = (1.0 - salePercentM3)
            }else{
                salePercentM3 = 1.0
                targetPercentM3 = 0.0
            }
            
            
            
            self.lblSaleQtr.text = "\u{20B9}" + (self.TODDataMain[initTabPosition].q3amts ?? "0.0")!
            self.lblTargetQtr.text = "\u{20B9}" + (self.TODDataMain[initTabPosition].q3amt ?? "0.0")!
            
            var shortFallQtr = 0.0
            shortFallQtr = Double(self.TODDataMain[initTabPosition].q3amt ?? "0.0")! - Double(self.TODDataMain[initTabPosition].q3amts ?? "0.0")!
            
            if(shortFallQtr > 0){
                self.lblShortFallQtr.text = "Short Fall - \u{20B9}" + String(Int(shortFallQtr))
            }else{
                self.lblShortFallQtr.text = "Short Fall - \u{20B9}" + "0"
            }
            
            self.lblEarnedQtr.text = "\u{20B9}" + (self.TODDataMain[initTabPosition].q3earnedamt ?? "0.0")!
            
            var targetQ = Double(self.TODDataMain[initTabPosition].q3amt ?? "0.0")!
            var saleQ = Double(self.TODDataMain[initTabPosition].q3amts ?? "0.0")!
            
            var salePercentQ = 0.0
            var targetPercentQ = 0.0
            if(saleQ < targetQ){
                salePercentQ = Double((saleQ/targetQ))
                targetPercentQ = (1.0 - salePercentQ)
            }else{
                salePercentQ = 1.0
                targetPercentQ = 0.0
            }
            
            
            
            self.lblProjM1.text = "\u{20B9}" + (self.TODDataMain[initTabPosition].octprojectsale ?? "0.0")!
            self.lblTradeM1.text = "\u{20B9}" + (self.TODDataMain[initTabPosition].octtradesale ?? "0.0")!
            
            self.lblProjM2.text = "\u{20B9}" + (self.TODDataMain[initTabPosition].novprojectsale ?? "0.0")!
            self.lblTradeM2.text = "\u{20B9}" + (self.TODDataMain[initTabPosition].novtradesale ?? "0.0")!
            
            self.lblProjM3.text = "\u{20B9}" + (self.TODDataMain[initTabPosition].decprojectsale ?? "0.0")!
            self.lblTradeM3.text = "\u{20B9}" + (self.TODDataMain[initTabPosition].dectradesale ?? "0.0")!
            
            self.lblProjQtr.text = "\u{20B9}" + (self.TODDataMain[initTabPosition].q4projectsale ?? "0.0")!
            self.lblTradeQtr.text = "\u{20B9}" + (self.TODDataMain[initTabPosition].q4tradesale ?? "0.0")!
            
             print("Percentage 3 - - -  ",salePercentM1,"---",salePercentM2,"---",salePercentM3,"---",salePercentQ)
            
            self.progressM1.setProgress(Float(salePercentM1), animated: false)
            self.progressM2.setProgress(Float(salePercentM2), animated: false)
            self.progressM3.setProgress(Float(salePercentM3), animated: false)
            self.progressQtr.setProgress(Float(salePercentQ), animated: false)
            
            self.lblSalesM1Percent.text = String(Int(round(salePercentM1*100)))+"%"
            self.lblTargetM1Percent.text = String(Int(round(targetPercentM1*100)))+"%"
            
            self.lblSalesM2Percent.text = String(Int(round(salePercentM2*100)))+"%"
            self.lblTargetM2Percent.text = String(Int(round(targetPercentM2*100)))+"%"
            
            self.lblSalesM3Percent.text = String(Int(round(salePercentM3*100)))+"%"
            self.lblTargetM3Percent.text = String(Int(round(targetPercentM3*100)))+"%"
            
            self.lblSalesQtrPercent.text = String(Int(round(salePercentQ*100)))+"%"
            self.lblTargetQtrPercent.text = String(Int(round(targetPercentQ*100)))+"%"
       
            
             // *********************  data for qtr 4 **********************
        }else if(selectedQtr == 3){
            self.lblTargetM1.text = "\u{20B9}" + (self.TODDataMain[initTabPosition].janamt ?? "0.0")!
            self.lblSaleM1.text = "\u{20B9}" + (self.TODDataMain[initTabPosition].janamts ?? "0.0")!
            
            var shortFallM1 = 0.0
            shortFallM1 = Double(self.TODDataMain[initTabPosition].janamt ?? "0.0")! - Double(self.TODDataMain[initTabPosition].janamts ?? "0.0")!
            
            if(shortFallM1 > 0){
                self.lblShortFallM1.text = "Short Fall - \u{20B9}" + String(Int(shortFallM1))
            }else{
                self.lblShortFallM1.text = "Short Fall - \u{20B9}" + "0"
            }
            
            self.lblEarnedM1.text = "\u{20B9}" + (self.TODDataMain[initTabPosition].janearnedamt ?? "0.0")!
            
            var target1 = Double(self.TODDataMain[initTabPosition].janamt ?? "0.0")!
            var sale1 = Double(self.TODDataMain[initTabPosition].janamts ?? "0.0")!
            
            var salePercentM1 = 0.0
            var targetPercentM1 = 0.0
            if(sale1 < target1){
                salePercentM1 = Double((sale1/target1))
                targetPercentM1 = (1.0 - salePercentM1)
            }else{
                salePercentM1 = 1.0
                targetPercentM1 = 0.0
            }
            
            
            self.lblTargetM2.text = self.TODDataMain[initTabPosition].febamt
            self.lblSaleM2.text = self.TODDataMain[initTabPosition].febamts
            
            var shortFallM2 = 0.0
            shortFallM2 = Double(self.TODDataMain[initTabPosition].febamt ?? "0.0")! - Double(self.TODDataMain[initTabPosition].febamts ?? "0.0")!
            
            if(shortFallM2 > 0){
                self.lblShortFallM2.text = "Short Fall - \u{20B9}" + String(Int(shortFallM2))
            }else{
                self.lblShortFallM2.text = "Short Fall - \u{20B9}" + "0"
            }
            
            self.lblEarnedM2.text = "\u{20B9}" + (self.TODDataMain[initTabPosition].febearnedamt ?? "0.0")!
            
            var target2 = Double(self.TODDataMain[initTabPosition].febamt ?? "0.0")!
            var sale2 = Double(self.TODDataMain[initTabPosition].febamts ?? "0.0")!
            
            var salePercentM2 = 0.0
            var targetPercentM2 = 0.0
            if(sale2 < target2){
                salePercentM2 = Double((sale2/target2))
                targetPercentM2 = (1.0 - salePercentM2)
            }else{
                salePercentM2 = 1.0
                targetPercentM2 = 0.0
            }
            
            self.lblTargetM3.text = "\u{20B9}" + (self.TODDataMain[initTabPosition].maramt ?? "0.0")!
            self.lblSaleM3.text = "\u{20B9}" + (self.TODDataMain[initTabPosition].maramts ?? "0.0")!
            
            var shortFallM3 = 0.0
            shortFallM3 = Double(self.TODDataMain[initTabPosition].maramt ?? "0.0")! - Double(self.TODDataMain[initTabPosition].maramts ?? "0.0")!
            
            if(shortFallM3 > 0){
                self.lblShortFallM3.text = "Short Fall - \u{20B9}" + String(Int(shortFallM3))
            }else{
                self.lblShortFallM3.text = "Short Fall - \u{20B9}" + "0"
            }
            
            self.lblEarnedM3.text = "\u{20B9}" + (self.TODDataMain[initTabPosition].marearnedamt ?? "0.0")!
            
            var target3 = Double(self.TODDataMain[initTabPosition].maramt ?? "0.0")!
            var sale3 = Double(self.TODDataMain[initTabPosition].maramts ?? "0.0")!
            
            var salePercentM3 = 0.0
            var targetPercentM3 = 0.0
            if(sale3 < target3){
                salePercentM3 = Double((sale3/target3))
                targetPercentM3 = (1.0 - salePercentM3)
            }else{
                salePercentM3 = 1.0
                targetPercentM3 = 0.0
            }
            
            
            self.lblSaleQtr.text = "\u{20B9}" + (self.TODDataMain[initTabPosition].q4amts ?? "0.0")!
            self.lblTargetQtr.text = "\u{20B9}" + (self.TODDataMain[initTabPosition].q4amt ?? "0.0")!
            
            var shortFallQtr = 0.0
            shortFallQtr = Double(self.TODDataMain[initTabPosition].q4amt ?? "0.0")! - Double(self.TODDataMain[initTabPosition].q4amts ?? "0.0")!
            
            if(shortFallQtr > 0){
                self.lblShortFallQtr.text = "Short Fall - \u{20B9}" + String(Int(shortFallQtr))
            }else{
                self.lblShortFallQtr.text = "Short Fall - \u{20B9}" + "0"
            }
            
            self.lblEarnedQtr.text = "\u{20B9}" + (self.TODDataMain[initTabPosition].q4earnedamt ?? "0.0")!
            
            var targetQ = Double(self.TODDataMain[initTabPosition].q4amt ?? "0.0")!
            var saleQ = Double(self.TODDataMain[initTabPosition].q4amts ?? "0.0")!
            
            var salePercentQ = 0.0
            var targetPercentQ = 0.0
            if(saleQ < targetQ){
                salePercentQ = Double((saleQ/targetQ))
                targetPercentQ = (1.0 - salePercentQ)
            }else{
                salePercentQ = 1.0
                targetPercentQ = 0.0
            }
            
            
            
            self.lblProjM1.text = "\u{20B9}" + (self.TODDataMain[initTabPosition].janprojectsale ?? "0.0")!
            self.lblTradeM1.text = "\u{20B9}" + (self.TODDataMain[initTabPosition].jantradesale ?? "0.0")!
            
            self.lblProjM2.text = "\u{20B9}" + (self.TODDataMain[initTabPosition].febprojectsale ?? "0.0")!
            self.lblTradeM2.text = "\u{20B9}" + (self.TODDataMain[initTabPosition].febtradesale ?? "0.0")!
            
            self.lblProjM3.text = "\u{20B9}" + (self.TODDataMain[initTabPosition].marprojectsale ?? "0.0")!
            self.lblTradeM3.text = "\u{20B9}" + (self.TODDataMain[initTabPosition].martradesale ?? "0.0")!
            
            self.lblProjQtr.text = "\u{20B9}" + (self.TODDataMain[initTabPosition].q4projectsale ?? "0.0")!
            self.lblTradeQtr.text = "\u{20B9}" + (self.TODDataMain[initTabPosition].q4tradesale ?? "0.0")!
            
             print("Percentage - - -  ",salePercentM1,"---",salePercentM2,"---",salePercentM3,"---",salePercentQ)
            
            self.progressM1.setProgress(Float(salePercentM1), animated: false)
            self.progressM2.setProgress(Float(salePercentM2), animated: false)
            self.progressM3.setProgress(Float(salePercentM3), animated: false)
            self.progressQtr.setProgress(Float(salePercentQ), animated: false)
            
            self.lblSalesM1Percent.text = String(Int(round(salePercentM1*100)))+"%"
            self.lblTargetM1Percent.text = String(Int(round(targetPercentM1*100)))+"%"
            
            self.lblSalesM2Percent.text = String(Int(round(salePercentM2*100)))+"%"
            self.lblTargetM2Percent.text = String(Int(round(targetPercentM2*100)))+"%"
            
            self.lblSalesM3Percent.text = String(Int(round(salePercentM3*100)))+"%"
            self.lblTargetM3Percent.text = String(Int(round(targetPercentM3*100)))+"%"
            
            self.lblSalesQtrPercent.text = String(Int(round(salePercentQ*100)))+"%"
            self.lblTargetQtrPercent.text = String(Int(round(targetPercentQ*100)))+"%"
            
        }
        
       
       // if((self.TODDataMain[initTabPosition].isAccept ?? true))
       // {
         
       //     btnSubmit.setTitle("Accepted", for: .normal)
        //    btnSubmit.setTitleColor(UIColor.green, for: .normal)
       //     btnSubmit.backgroundColor = UIColor.clear
       //     btnSubmit.isEnabled = false
     //   }else{
           // btnSubmit.isHidden = false
      //      self.btnSubmit.setTitle("Accept", for: .normal)
      //      self.btnSubmit.setTitleColor(UIColor.white, for: .normal)
       //     self.btnSubmit.backgroundColor = UIColor.red
      //      self.btnSubmit.isEnabled = true
      //  }
        
         //print("IS ACCEPT  - - - ",self.TODDataMain[initTabPosition].isAccept," - - - - ",btnSubmit.isHidden)
        
    }
    
    
    @IBAction func AcceptSelected(_ sender: UIButton) {
        if (Utility.isConnectedToNetwork()) {
            print("Internet connection available")
            if(strGrpId.isEmpty){
                var alert = UIAlertView(title: "Invalid", message: "Invalid Group Id", delegate: nil, cancelButtonTitle: "OK")
                alert.show()
            }else{
                
                let alertCancel = UIAlertController(title: "ACCEPT", message: "Are you sure you want to accept TOD for \((self.TODDataMain[initTabPosition].groupName ?? "-")!)?", preferredStyle: .alert)
                
                alertCancel.addAction(UIAlertAction(title: "OK", style: .default, handler: { (alertAction) -> Void in
                    if (Utility.isConnectedToNetwork()) {
                       self.apiSubmitTOD()
                    }
                    else{
                        var alert = UIAlertView(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", delegate: nil, cancelButtonTitle: "OK")
                        alert.show()
                    }
                }))
                
                
                alertCancel.addAction(UIAlertAction(title: "CANCEL", style: .default, handler: { (alertAction) -> Void in
                    
                }))
                
                
                
                self.present(alertCancel, animated: true, completion: nil)
               
            }
            
        }
        else {
            print("No internet connection available")
            var alert = UIAlertView(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
        }
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}


extension TodAgreementController: ViewPagerControllerDataSource {
    
    func numberOfPages() -> Int {
        return tabs.count
    }
    
    func viewControllerAtPosition(position:Int) -> UIViewController {
        let vc = UIViewController()
        
        initTabPosition = position
        
      //  self.lblDropdownText.text = dropDown.dataSource[0]
       // selectedQtr = 0
        
        setQtrMnths()
        
        return vc
    }
    
    func tabsForPages() -> [ViewPagerTab] {
        return tabs
    }
    
    func startViewPagerAtIndex() -> Int {
        return initTabPosition
    }
    
}

extension TodAgreementController: ViewPagerControllerDelegate {
    
    func willMoveToControllerAtIndex(index:Int) {
        print("Moving to page \(index)")
    }
    
    func didMoveToControllerAtIndex(index: Int) {
        print("Moved to page \(index)")
    }
}


