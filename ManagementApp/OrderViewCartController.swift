//
//  OrderViewCartController.swift
//  DealorsApp
//
//  Created by Goldmedal on 11/17/18.
//  Copyright © 2018 Goldmedal. All rights reserved.
//

import UIKit
import FirebaseAnalytics

struct OrderPlaceElement:Codable {
    let result: Bool?
    let message, servertime: String?
    let data: [OrderPlaceObj]
}

struct OrderPlaceObj: Codable {
    let type, message: String?
}


struct OrderPlacedObject:Codable{
    var CategoryId,ItemId,Qty,MRP,MRPAmt,DLP,DLPAmt,DiscountPer,DiscountAmt,PromotionalPer,PromotionalAmt,WithoutTaxAmt,WithTaxAmt,GSTPer,GSTAmt: String
    
    init(CategoryId:String,ItemId:String,MRP:String,MRPAmt:String,DLP:String,DLPAmt:String,Qty:String,
DiscountPer:String,DiscountAmt:String,PromotionalPer:String,PromotionalAmt:String,WithoutTaxAmt:String,WithTaxAmt:String,GSTPer:String,GSTAmt:String)
    {
        self.CategoryId=CategoryId
        self.ItemId=ItemId
        self.Qty=Qty
        self.MRP=MRP
        self.MRPAmt=MRPAmt
        self.DLP=DLP
        self.DLPAmt=DLPAmt
        self.DiscountPer=DiscountPer
        self.DiscountAmt=DiscountAmt
        self.PromotionalPer=PromotionalPer
        self.PromotionalAmt=PromotionalAmt
        self.WithoutTaxAmt=WithoutTaxAmt
        self.WithTaxAmt=WithTaxAmt
        self.GSTPer=GSTPer
        self.GSTAmt=GSTAmt
    }
}

class OrderViewCartController: UIViewController, UITableViewDelegate , UITableViewDataSource ,UITextFieldDelegate,UISearchBarDelegate , ShowQtyDelegate,UpdateCartDelegate{
   
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var imvBack: UIImageView!
    @IBOutlet weak var vwEmptyCart: UIView!
    @IBOutlet weak var vwHorizontalStrip: UIView!
    @IBOutlet weak var lblEmptycart: UILabel!
    
    @IBOutlet weak var lblPretaxtotal: UILabel!
    @IBOutlet weak var lblGST_5Percent: UILabel!
    @IBOutlet weak var lblGST_12Percent: UILabel!
    @IBOutlet weak var lblGST_18Percent: UILabel!
    @IBOutlet weak var lblGST_28Percent: UILabel!
    @IBOutlet weak var lblOrderAmountTotal: UILabel!
    
     @IBOutlet weak var btnCartHeader: UIButton!
    
    @IBOutlet weak var searchBar: RoundSearchBar!
    var strSearchText = ""
    
    var checkCount:Int = 0
    
    var totalItemsInCart:Int = 0
    
    var indexOfItemInCart:Int? = 0
   
    var arrTotalAmount = [Double]()
    var arr5PercentGST = [Double]()
    var arr12PercentGST = [Double]()
    var arr18PercentGST = [Double]()
    var arr28PercentGST = [Double]()
    
    var promoDiscountArray = [Double]()
    var promoQtyArray = [Double]()
    var promoArrayMain = [String]()
    var promoSeparatedArray = [String]()
    var promoString = "0-0"
    var highestPromoDiscountQty:Double = 0
    
    var OrderDetailElementMain = [OrderDetailElement]()
    var OrderDetailArray = [OrderDetailData]()
    
    var arrPlacedOrderObject = [OrderPlacedObject]()
    
    var placeOrderElementMain = [OrderPlaceElement]()
    var placeOrderObjMain = [OrderPlaceObj]()
    
    var strApiPlaceOrder = ""
    var strCin = ""
   
    var initTabPosition = 0
    var initItemPosition = -1
  
    var tabs = [ViewPagerTab]()

    var viewPager:ViewPagerController!
    var options:ViewPagerOptions!
 
    var arrDivTabs = [String]()
    
    var arrCartItemsMain = [[OrderDetailData]]()
    
    var arrCartChangedMain = [[OrderDetailData]]()
    
    var totalQty = "1"
    var edtTotalQty = "1"
 
    var mrpRate:Double = 0
    var dlpRate:Double = 0
    var discountRate:Double = 0
    var promotionalRate:Double = 0
    var GSTRate:Int = 0
    
    var mrpAmount:Double = 0
    var dlpAmount:Double = 0
    var discountAmount:Double = 0
    var promotionalAmount:Double = 0
    var GSTAmount:Double = 0
    var withOutTaxAmount:Double = 0
    var withTaxAmount:Double = 0
    
    var GSTPreTaxTotal:Double = 0
    var GST5PercentTotal:Double = 0
    var GST12PercentTotal:Double = 0
    var GST18PercentTotal:Double = 0
    var GST28PercentTotal:Double = 0
    var OrderAmountTotal:Double = 0
    
    var divIdToPass = ""
    var changedItemIdToPass = ""
    
    var OrderCartChangesApi = ""
    
    @IBOutlet weak var heightConstraint_5: NSLayoutConstraint!
    @IBOutlet weak var heightConstraint_12: NSLayoutConstraint!
    @IBOutlet weak var heightConstraint_18: NSLayoutConstraint!
    @IBOutlet weak var heightConstraint_28: NSLayoutConstraint!
    
    let MAX_LENGTH_QTY = 5
    let ACCEPTABLE_NUMBERS = "0123456789"
    
     var delegate: PopupDateDelegate?
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.getSavedCartData()
        
        let loginData =  UserDefaults.standard.value(forKey: "loginData") as? Dictionary ?? [:]
        strCin = loginData["userlogid"] as? String ?? ""
        //        let initialData =  UserDefaults.standard.value(forKey: "initialData") as? Dictionary ?? [:]
        //        strApiPlaceOrder = (initialData["baseApi"] as? String ?? "")+""+(initialData["comboSchemes"] as? String ?? "")
        strApiPlaceOrder = "https://api.goldmedalindia.in//api/PlaceOrder"
        
        OrderCartChangesApi = "https://api.goldmedalindia.in//api/getOrderItemDetails"
        
        // - - - - - - adding division tabs at top  - - - - - - - - - - -
        createTabs()
        
        //-- - -  - - - - - -  code for showing horizontal category strip
        self.edgesForExtendedLayout = UIRectEdge.init(rawValue: 0)
        
        options = ViewPagerOptions(viewPagerWithFrame: self.view.bounds)
        options.tabType = ViewPagerTabType.basic
        options.tabViewTextFont = UIFont.systemFont(ofSize: 13)
        options.tabViewBackgroundDefaultColor = UIColor.init(named: "primaryLight")!
        options.fitAllTabsInView = false
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
      
        // Do any additional setup after loading the view.
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.searchBar.delegate = self;
     
        let tabBack = UITapGestureRecognizer(target: self, action: #selector(self.tapFunction))
        imvBack.addGestureRecognizer(tabBack)
        
        Analytics.setScreenName("VIEW CART SCREEN", screenClass: "OrderViewCartController")
        
        checkPagerPosition()
    
    }
    
    
    //search filter
    func filterSearch(){
        let searchText = searchBar.text ?? ""
      
        var arrCartItemsFilter = arrCartItemsMain[initTabPosition].filter { item in
            let isMatchingSearchText = item.itemcode!.lowercased().contains(searchText.lowercased())
            return isMatchingSearchText
        }
        
        
            if(arrCartItemsFilter.count>0){
                indexOfItemInCart = arrCartItemsMain[initTabPosition].index{$0.itemcode == arrCartItemsFilter[0].itemcode}
                
                self.tableView.scrollToRow(at: IndexPath(row: (indexOfItemInCart ?? 0)!, section: 0), at: .top, animated: true)
            }
      
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
       
        if searchText.characters.count > 0 {
            strSearchText = searchText
            filterSearch()
        }else{
            if(arrCartItemsMain[initTabPosition].count > 0){
                self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
            }
        }
        
    }
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    
    func checkPagerPosition(){
        for i in 0...((self.arrCartItemsMain.count) - 1){
            if(self.arrCartItemsMain[i].count > 0){
                checkCount = i
                break
            }else{
                checkCount = 0
            }
        }
      
        if(viewPager != nil){
        viewPager.displayViewController(atIndex: checkCount)
        }
    }
    
    
    func createTabs(){
        arrDivTabs = ["Wiring Devices (\(arrCartItemsMain[0].count))", "Lights (\(arrCartItemsMain[1].count))", "Wire & Cables (\(arrCartItemsMain[2].count))",  "Pipes & Fitting (\(arrCartItemsMain[3].count))","Mcb & Dbs (\(arrCartItemsMain[4].count))"]
        
        tabs.removeAll()
        if(arrDivTabs.count>0){
            for i in 0...(arrDivTabs.count-1) {
                tabs.append(ViewPagerTab(title: arrDivTabs[i], image: UIImage(named: "")))
            }
        }
        
        if(viewPager != nil)
        { viewPager.invalidateTabs() }
    }
    
    // - - - - - - - - - - -  Retrieving cart data - - - -  - - - --  -
    func getSavedCartData(){
      
        if let arrViewCartData = UserDefaults.standard.object(forKey: "addToCart") as? Data {
            let decoder = JSONDecoder()
            if var decodedData = try? decoder.decode([[OrderDetailData]].self, from: arrViewCartData) {
                
                if(decodedData.count == 0){
                    arrCartItemsMain.removeAll()
                    arrCartItemsMain = Array(repeating:[OrderDetailData](), count:5)
                }
                
                print("RETRIEVED CART OG ------- ",arrCartItemsMain)
                print("RETRIEVED CART ARR ------- ",decodedData)
                
                if(arrCartItemsMain.count > arrDivTabs.count){
                    arrCartItemsMain = Array(repeating:[OrderDetailData](), count:5)
                    arrCartItemsMain.append(contentsOf: decodedData)
                }
                
                if(arrCartItemsMain.count == 0)
                {
                    arrCartItemsMain.append(contentsOf: decodedData)
                }
                
                if(decodedData.count > arrDivTabs.count){
                    decodedData = Array(repeating:[OrderDetailData](), count:5)
                    decodedData.append(contentsOf: arrCartItemsMain)
                }
                
                print("RETRIEVED CART ARR LENGHT ------- ",arrCartItemsMain.count,"- - - - - - -",decodedData.count)
            }
        }
        print("arrCartItemsMain 00- - - -",arrCartItemsMain)
        if(arrCartItemsMain.count == 0){
            arrCartItemsMain.removeAll()
            arrCartItemsMain = Array(repeating:[OrderDetailData](), count:5)
            print("arrCartItemsMain - - - -",arrCartItemsMain)
        }
      
        print("arrCartItemsMain 43 - - - -",arrCartItemsMain)
        if(arrCartItemsMain[initTabPosition].count > 0){
            hideEmptyCart()
        }else{
            showEmptyCart()
        }
    }
    
    
    func showEmptyCart(){
        tableView.isHidden = true
        vwEmptyCart.isHidden = false
        
        print("ARRAY - - - -",arrCartItemsMain)
        
        // -- check here app crashes
        let joined = Array(arrCartItemsMain.joined())
        totalItemsInCart = joined.count
        
        btnCartHeader.setTitle(String(totalItemsInCart), for: .normal)
   
    }
    
    func hideEmptyCart(){
        
        print("ARRAY - - - -HIDE")
        
        tableView.isHidden = false
        vwEmptyCart.isHidden = true
    }
    
    //- - - - - - - - - - - click on place order - - - - - - - - -  - -
    @IBAction func clicked_placeOrder(_ sender: UIButton) {
        if (Utility.isConnectedToNetwork()) {
            self.apiPlaceOrder()
        }
        else {
            var alert = UIAlertView(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
        }
    }
    
    
    func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    //  - - - - - - - - - - - - - - - API for place order  - - - - - - - - - - -  - - - - -
    func apiPlaceOrder(){
        arrPlacedOrderObject.removeAll()
        for i in 0...((self.arrCartItemsMain[self.initTabPosition].count) - 1){
            arrPlacedOrderObject.append(OrderPlacedObject(CategoryId: (self.arrCartItemsMain[self.initTabPosition][i].categoryId ?? "-")!,
                                                               ItemId: String((self.arrCartItemsMain[self.initTabPosition][i].itemid ?? 0)!),
                                                               MRP: (self.arrCartItemsMain[self.initTabPosition][i].mrp ?? "0")!,
                                                               MRPAmt: (self.arrCartItemsMain[self.initTabPosition][i].mrpAmnt ?? "0")!,
                                                               DLP: (self.arrCartItemsMain[self.initTabPosition][i].dlp ?? "0")!,
                                                               DLPAmt: (self.arrCartItemsMain[self.initTabPosition][i].dlpAmnt ?? "0")!,
                                                               Qty: String((self.arrCartItemsMain[self.initTabPosition][i].itemQty ?? 1)!),
                                                               DiscountPer: (self.arrCartItemsMain[self.initTabPosition][i].discount ?? "0")!,
                                                               DiscountAmt: (self.arrCartItemsMain[self.initTabPosition][i].discountAmnt ?? "0")!,
                                                               PromotionalPer: (self.arrCartItemsMain[self.initTabPosition][i].actualPromoDiscount ?? "0")!,
                                                               PromotionalAmt: (self.arrCartItemsMain[self.initTabPosition][i].promoAmnt ?? "0")!,
                                                               WithoutTaxAmt: (self.arrCartItemsMain[self.initTabPosition][i].totalAmount ?? "0")!,
                                                               WithTaxAmt: (self.arrCartItemsMain[self.initTabPosition][i].withTaxAmnt ?? "0")!,
                                                               GSTPer: (self.arrCartItemsMain[self.initTabPosition][i].taxpercent ?? "0")!,
                                                               GSTAmt: (self.arrCartItemsMain[self.initTabPosition][i].taxAmount ?? "0")!))
        }
        
        let encoderToPass = JSONEncoder()
        encoderToPass.outputFormatting = []
        
        var cartJsonObj: [String: Any] = [:]
        var strCartObj = ""
     
        if let data = try? encoderToPass.encode(self.arrPlacedOrderObject) {
            print(String(data: data, encoding: .utf8)!)
            
              strCartObj = String(data: data, encoding: .utf8)!
          
              strCartObj = strCartObj.components(separatedBy: .whitespacesAndNewlines).joined()
              strCartObj = strCartObj.replacingOccurrences(of: "\\", with: "", options: .literal, range: nil)
        }
     
        divIdToPass = arrCartItemsMain[initTabPosition][0].divisionId ?? "0"
        
        let json: [String: Any] =

            ["CIN":strCin,"ClientSecret":"ClientSecret","DivisionId":divIdToPass,"OrderDetails":strCartObj,"Amount":OrderAmountTotal]
        
        print("ORDER PLACED ------ ",json)
        
        DataManager.shared.makeAPICall(url: strApiPlaceOrder, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            
            DispatchQueue.main.async {
                do {
                    self.placeOrderElementMain = try JSONDecoder().decode([OrderPlaceElement].self, from: data!)
                    self.placeOrderObjMain = self.placeOrderElementMain[0].data
                    
                    if (self.placeOrderElementMain[0].result ?? false){
                        
                        var alert = UIAlertView(title: "Success!!!", message: "Order Placed Successfully!!! Your Order ID is \(self.placeOrderObjMain[0].message ?? "-")", delegate: nil, cancelButtonTitle: "OK")
                        alert.show()
                        
                        self.getSavedCartData()
                
                        self.arrCartItemsMain[self.initTabPosition] = []
                        
                        let defaults = UserDefaults.standard
                        let encoder = JSONEncoder()
                        defaults.removeObject(forKey: "addToCart")
                        if let encoded = try? encoder.encode(self.arrCartItemsMain) {
                            defaults.set(encoded, forKey: "addToCart")
                            defaults.synchronize()
                        }
                    
                        self.tableView.reloadData()
                        
                        if(self.arrCartItemsMain[self.initTabPosition].count == 0){
                            self.showEmptyCart()
                        }
                        
                    }else{
                        if(self.placeOrderObjMain[0].type?.isEqual("Item"))!{
                          
                            let alertRateChange = UIAlertController(title: "Some Rates have changed!!!", message: "Rates of \(self.placeOrderElementMain[0].message). Please Update to changed rates!", preferredStyle: .alert)
                            
                            self.changedItemIdToPass = self.placeOrderElementMain[0].message!
                            
                            alertRateChange.addAction(UIAlertAction(title: "OK", style: .default, handler: { (alertAction) -> Void in
                                if (Utility.isConnectedToNetwork()) {
                                    print("Internet connection available")
                                    self.apiChangedRates()
                                }
                                else {
                                    print("No internet connection available")
                                    var alert = UIAlertView(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", delegate: nil, cancelButtonTitle: "OK")
                                    alert.show()
                                }
                            }))
                            
                            alertRateChange.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
                                alertRateChange.dismiss(animated: true, completion: nil)
                            }))
                            
                            self.present(alertRateChange, animated: true, completion: nil)
                        }
                    }
                } catch let errorData {
                    print(errorData.localizedDescription)
                }
                
            }
        }) { (Error) in
            print(Error?.localizedDescription)
        }
    }
    
    
    // - -  - - - - - - - - - - - - - - - - -  If cart product values changes   - - - - - - - - - - - - - - -
    func apiChangedRates(){
            ViewControllerUtils.sharedInstance.showLoader()
            
            let json: [String: Any] = ["CIN":strCin,"ClientSecret":"ClientSecret","DivisionId":divIdToPass,"CategoryId":"0","ItemId":changedItemIdToPass]
        
            print("CHANGED CART JSON- - - ", json)
        
            DataManager.shared.makeAPICall(url: OrderCartChangesApi, params: json, method: .POST, success: { (response) in
                let data = response as? Data
                
                DispatchQueue.main.async {
                    do {
                        self.OrderDetailElementMain = try JSONDecoder().decode([OrderDetailElement].self, from: data!)
                        self.OrderDetailArray = self.OrderDetailElementMain[0].data
                  
                        
                        for i in 0...((self.arrCartItemsMain[self.initTabPosition].count) - 1){
                            
                            if (self.OrderDetailArray.contains(where: {$0.itemid == self.arrCartItemsMain[self.initTabPosition][i].itemid})) {
                              
                                
                                 self.arrCartItemsMain[self.initTabPosition][i].mrp = self.OrderDetailArray[i].mrp
                                 self.arrCartItemsMain[self.initTabPosition][i].dlp = self.OrderDetailArray[i].dlp
                                 self.arrCartItemsMain[self.initTabPosition][i].discount = self.OrderDetailArray[i].discount
                                 self.arrCartItemsMain[self.initTabPosition][i].taxpercent = self.OrderDetailArray[i].taxpercent
                                 self.arrCartItemsMain[self.initTabPosition][i].pramotionaldiscount = self.OrderDetailArray[i].pramotionaldiscount
                                
                                self.calculateRates(orderQty: "1",index: i)
                            
                            }
                         
                        }
                        
                        if(self.OrderDetailArray.count>0){

                            let defaults = UserDefaults.standard
                            let encoder = JSONEncoder()
                            defaults.removeObject(forKey: "addToCart")
                            if let encoded = try? encoder.encode(self.arrCartItemsMain) {
                                defaults.set(encoded, forKey: "addToCart")
                                defaults.synchronize()
                            }

                        }
                     
                        
                    } catch let errorData {
                        print(errorData.localizedDescription)
                    }
                    
                    if(self.OrderDetailArray.count>0){
                        if(self.tableView != nil)
                        {
                            self.tableView.reloadData()
                        }
                    }
                    
                    ViewControllerUtils.sharedInstance.removeLoader()
                    
                }
            }) { (Error) in
                ViewControllerUtils.sharedInstance.removeLoader()
                print(Error?.localizedDescription as Any)
            }
    }
    
    
    @objc func tapFunction(sender:UITapGestureRecognizer) {
        print("back")
        self.dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrCartItemsMain[initTabPosition].count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CartRowCell", for: indexPath) as! CartRowCell
        
        cell.lblItemCategory.text = arrCartItemsMain[initTabPosition][indexPath.row].categorynm
        cell.lblItemName.text = arrCartItemsMain[initTabPosition][indexPath.row].itemcode
        cell.lblItemBillingRate.text = Utility.formatRupeeWithDecimal(amount: Double(arrCartItemsMain[initTabPosition][indexPath.row].dlp ?? "0")!)
        cell.lblItemGST.text = String(arrCartItemsMain[initTabPosition][indexPath.row].taxpercent!)+"%"
        cell.btnEdtQty.setTitle(String(describing: arrCartItemsMain[initTabPosition][indexPath.row].itemQty!), for: .normal)
        cell.lblItemAmount.text = Utility.formatRupeeWithDecimal(amount:Double(arrCartItemsMain[initTabPosition][indexPath.row].totalAmount ?? "0")!)
        cell.lblItemPromoAmnt.text = Utility.formatRupeeWithDecimal(amount: Double(arrCartItemsMain[initTabPosition][indexPath.row].promoAmnt ?? "0")!) + "  ("+(arrCartItemsMain[initTabPosition][indexPath.row].actualPromoDiscount ?? "0")+"%)"
        cell.lblItemDiscountAmnt.text = Utility.formatRupeeWithDecimal(amount: Double(arrCartItemsMain[initTabPosition][indexPath.row].discountAmnt ?? "0")!) + "  ("+(arrCartItemsMain[initTabPosition][indexPath.row].discount ?? "0")+"%)"
       
        cell.delegate = self
        
        cell.btnRemove.addTarget(self, action: #selector(self.clicked_Remove(sender:)), for: .touchUpInside)
        cell.btnRemove.tag = indexPath.row

        return cell
    }
    
    
    func ShowTotalQty(cell: CartRowCell) {
        
        var indexPath = self.tableView.indexPath(for: cell)
        
        let alertController = UIAlertController(title: "ENTER QUANTITY", message: "", preferredStyle: .alert)
      
        //the confirm action taking the inputs
        let confirmAction = UIAlertAction(title: "Enter", style: .default) { (_) in
            
            //getting the input values from user
            self.edtTotalQty = (alertController.textFields?[0].text)!
            
            if(self.edtTotalQty.count == 0){
                self.edtTotalQty = "1"
            }
            
            self.ShowTotalQty(orderQty: self.edtTotalQty, cell: cell)
            
            self.highestPromoDiscountQty = Double(self.arrCartItemsMain[self.initTabPosition][indexPath!.row].highestPromoAmnt ?? "0")!
            
            print("HIGHEST - - -  - -",self.highestPromoDiscountQty,"- - - - - ",Double(self.edtTotalQty)!)
            
            if(Double(self.edtTotalQty)! >= self.highestPromoDiscountQty)
            {
               
            }else{
                // - - - - - - Show pop up for promotional rates  - - - - - - - - -
                let sb = UIStoryboard(name: "PromotionalRatePopup", bundle: nil)
                let popup = sb.instantiateInitialViewController() as? PromotionalRateController
                popup?.promoDiscountArray = self.promoDiscountArray
                popup?.promoQtyArray = self.promoQtyArray
                popup?.callFrom = "cart"
                popup?.delegate = self
                self.present(popup!, animated: true)
            }
           
        }
        
        //the cancel action doing nothing
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        
        //adding textfields to our dialog box
        alertController.addTextField { (textField) in
            textField.placeholder = "Enter Qty"
            textField.delegate = self
        }
        
        //adding the action to dialogbox
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        //finally presenting the dialog box
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    func UpdateCartPopup() {
        
    }
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        print("TEXT RANGE")
       
        if textField.text?.count == 0 && string == "0" {
            return false
        }
        
        let newLength: Int = textField.text!.characters.count + string.characters.count - range.length
        let numberOnly = NSCharacterSet.init(charactersIn: ACCEPTABLE_NUMBERS).inverted
        let strValid = string.rangeOfCharacter(from: numberOnly) == nil
        
        return (strValid && (newLength <= MAX_LENGTH_QTY))
        
    }
    
    
    
    //  --  - - - - - - - - - called when edit text for qty changes - - -  - - - - - - - - - - --
    func ShowTotalQty(orderQty: String, cell: CartRowCell) {
        let indexPath = self.tableView.indexPath(for: cell)
        
        totalQty = orderQty
        
        cell.btnEdtQty.setTitle(orderQty, for: .normal)
      
        if(!orderQty.isEmpty && Int(orderQty)! > 0){
            calculateRates(orderQty: orderQty,index: (indexPath?.row)!)
            cell.lblItemAmount.text = Utility.formatRupeeWithDecimal(amount:withOutTaxAmount)
            cell.lblItemPromoAmnt.text = Utility.formatRupeeWithDecimal(amount: promotionalAmount) + "  ("+String(promotionalRate ?? 0)+"%)"
            cell.lblItemDiscountAmnt.text = Utility.formatRupeeWithDecimal(amount: discountAmount) + "  ("+String(discountRate ?? 0)+"%)"
        }
    }
    
   
    
    // - - - - - - - - - - -  common calculation for initial and changes rates  - - - - - - - - -
    func calculateRates(orderQty: String,index:Int){
        mrpRate = Double(arrCartItemsMain[initTabPosition][index].mrp ?? "0")!
        dlpRate = Double(arrCartItemsMain[initTabPosition][index].dlp ?? "0")!

            //- - - -  - -  - - Logic for calculating promotional amnt and rate - - -  - - - - - - -
            promoString = arrCartItemsMain[initTabPosition][index].pramotionaldiscount ?? "0-0"
            print("PROMO STRING -- ",promoString)
        
            if (promoString.range(of:",") != nil) {
                promoArrayMain = promoString.components(separatedBy: ",")
                promoArrayMain = promoArrayMain.reversed()
            }else{
                promoArrayMain = [promoString]
            }
    
        promoQtyArray.removeAll()
        promoDiscountArray.removeAll()
        
        for i in 0...(promoArrayMain.count - 1)
        {
            promoSeparatedArray =  (promoArrayMain[i].components(separatedBy: "-"))
            
            print("PROMO promoSeparatedArray - - - ",promoSeparatedArray)
            
            promoQtyArray.append(Double(promoSeparatedArray[0].components(separatedBy: .whitespaces).joined())!)
            promoDiscountArray.append(Double(promoSeparatedArray[1].components(separatedBy: .whitespaces).joined())!)
            
            promoQtyArray =  promoQtyArray.sorted(by: >)
            promoDiscountArray =  promoDiscountArray.sorted(by: >)
        }
        
         highestPromoDiscountQty = promoQtyArray[0]
        
        for i in 0...(promoQtyArray.count - 1){
            if (Double(totalQty)! >= promoQtyArray[i])
            {
                promotionalRate = promoDiscountArray[i]
                break
            }else{
                promotionalRate = 0
            }
        }
        
        print("PROMO RATE  -- - - ",promotionalRate)

        GSTRate = Int(arrCartItemsMain[initTabPosition][index].taxpercent ?? "0")!
        discountRate = Double(arrCartItemsMain[initTabPosition][index].discount ?? "0")!
        mrpAmount = mrpRate * Double(orderQty)!
        dlpAmount = dlpRate * Double(orderQty)!
        if(discountRate>0){
            discountAmount = dlpAmount * (discountRate/100)
        }else{
            discountAmount = 0
        }
        
        if(promotionalRate>0){
            promotionalAmount = (dlpAmount - discountAmount) * (promotionalRate/100)
        }else{
            promotionalAmount = 0
        }
        withOutTaxAmount = dlpAmount - discountAmount - promotionalAmount
        if(GSTRate > 0){
            GSTAmount = withOutTaxAmount * Double(GSTRate)/100
        }else{
            GSTAmount = 0
        }
        withTaxAmount = GSTAmount + withOutTaxAmount
        
        arrCartItemsMain[initTabPosition][index].totalAmount = String(withOutTaxAmount)
        arrCartItemsMain[initTabPosition][index].itemQty = Int(orderQty)
        arrCartItemsMain[initTabPosition][index].dlp = String(dlpRate)
        arrCartItemsMain[initTabPosition][index].dlpAmnt = String(dlpAmount)
        arrCartItemsMain[initTabPosition][index].mrp = String(mrpRate)
        arrCartItemsMain[initTabPosition][index].mrpAmnt = String(mrpAmount)
        arrCartItemsMain[initTabPosition][index].taxAmount = String(GSTAmount)
        arrCartItemsMain[initTabPosition][index].taxpercent = String(GSTRate)
        arrCartItemsMain[initTabPosition][index].actualPromoDiscount = String(promotionalRate)
        arrCartItemsMain[initTabPosition][index].promoAmnt = String(promotionalAmount)
        arrCartItemsMain[initTabPosition][index].discount = String(discountRate)
        arrCartItemsMain[initTabPosition][index].discountAmnt = String(discountAmount)
        arrCartItemsMain[initTabPosition][index].withTaxAmnt = String(withTaxAmount)
        
        
        showAmountWithGSTAdded(itemPosition: index, removeClicked: false)
    }
    
    
    //  --  - - - - - - - -  - -  click on remove of object inside cart - - - -  - - - - - - - - - - -
    @objc func clicked_Remove(sender: UIButton){
        let buttonTag = sender.tag
        showCartData(tabPosition:initTabPosition,itemPosition: buttonTag)
    }
    
    
    func showCartData(tabPosition:Int,itemPosition:Int){
        initTabPosition = tabPosition
        initItemPosition = itemPosition
        
        if(!(initItemPosition == -1)){
            arrCartItemsMain[initTabPosition].remove(at: initItemPosition)

            let defaults = UserDefaults.standard
            let encoder = JSONEncoder()
            defaults.removeObject(forKey: "addToCart")
            if let encoded = try? encoder.encode(self.arrCartItemsMain) {
                defaults.set(encoded, forKey: "addToCart")
                defaults.synchronize()
            }
            
            showAmountWithGSTAdded(itemPosition: initItemPosition,removeClicked:true)
            
            if(arrCartItemsMain[initTabPosition].count > 0){
            self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
            }
            createTabs()
        }
        
        let joined = Array(arrCartItemsMain.joined())
        totalItemsInCart = joined.count
        
        btnCartHeader.setTitle(String(totalItemsInCart), for: .normal)
        
        
        if(arrCartItemsMain[initTabPosition].count > 0){
            hideEmptyCart()
            
            if(self.tableView != nil)
            {
                self.tableView.reloadData()
            }
            
        }else{
            showEmptyCart()
        }
   
    }
    
   
    
    // - - - - - - -  Calculation for with GST amount - -  - - -
    func showAmountWithGSTAdded(itemPosition:Int,removeClicked:Bool){
        arrTotalAmount.removeAll()
        arr5PercentGST.removeAll()
        arr12PercentGST.removeAll()
        arr18PercentGST.removeAll()
        arr28PercentGST.removeAll()
    
        if(arrCartItemsMain[initTabPosition].count > 0){
            for index in 0...(arrCartItemsMain[initTabPosition].count-1) {
                arrTotalAmount.append(Double(arrCartItemsMain[initTabPosition][index].totalAmount ?? "0")!)
                
                if((arrCartItemsMain[initTabPosition][index].taxpercent ?? "0").isEqual("5")){
                    arr5PercentGST.append(Double(arrCartItemsMain[initTabPosition][index].taxAmount ?? "0")!)
                    
                    arr12PercentGST.append(0)
                    arr18PercentGST.append(0)
                    arr28PercentGST.append(0)
                }else if((arrCartItemsMain[initTabPosition][index].taxpercent ?? "0").isEqual("12")){
                    arr12PercentGST.append(Double(arrCartItemsMain[initTabPosition][index].taxAmount ?? "0")!)
                    
                    arr5PercentGST.append(0)
                    arr18PercentGST.append(0)
                    arr28PercentGST.append(0)
                }else if((arrCartItemsMain[initTabPosition][index].taxpercent ?? "0").isEqual("18")){
                    arr18PercentGST.append(Double(arrCartItemsMain[initTabPosition][index].taxAmount ?? "0")!)
                    
                    arr5PercentGST.append(0)
                    arr12PercentGST.append(0)
                    arr28PercentGST.append(0)
                }else if((arrCartItemsMain[initTabPosition][index].taxpercent ?? "0").isEqual("28")){
                    arr28PercentGST.append(Double(arrCartItemsMain[initTabPosition][index].taxAmount ?? "0")!)
                    
                    arr12PercentGST.append(0)
                    arr18PercentGST.append(0)
                    arr5PercentGST.append(0)
                }
          
            }
            
            if(itemPosition != -1 && !removeClicked){
        
                arrCartItemsMain[initTabPosition][itemPosition].itemQty = Int(totalQty)
                arrCartItemsMain[initTabPosition][itemPosition].mrpAmnt = String(mrpAmount)
                arrCartItemsMain[initTabPosition][itemPosition].dlpAmnt = String(dlpAmount)
                arrCartItemsMain[initTabPosition][itemPosition].promoAmnt = String(promotionalAmount)
                arrCartItemsMain[initTabPosition][itemPosition].withTaxAmnt = String(withTaxAmount)
                arrCartItemsMain[initTabPosition][itemPosition].discountAmnt = String(discountAmount)
                arrCartItemsMain[initTabPosition][itemPosition].taxAmount = String(GSTAmount)
                
                if((arrCartItemsMain[initTabPosition][itemPosition].taxpercent ?? "0").isEqual("5")){
                    arr5PercentGST[itemPosition] = GSTAmount
                }else if((arrCartItemsMain[initTabPosition][itemPosition].taxpercent ?? "0").isEqual("12")){
                    arr12PercentGST[itemPosition] = GSTAmount
                }else if((arrCartItemsMain[initTabPosition][itemPosition].taxpercent ?? "0").isEqual("18")){
                    arr18PercentGST[itemPosition] = GSTAmount
                }else if((arrCartItemsMain[initTabPosition][itemPosition].taxpercent ?? "0").isEqual("28")){
                    arr28PercentGST[itemPosition] = GSTAmount
                }
            }
    
            GSTPreTaxTotal = arrTotalAmount.reduce(0,+)
            GST5PercentTotal = arr5PercentGST.reduce(0,+)
            GST12PercentTotal = arr12PercentGST.reduce(0,+)
            GST18PercentTotal = arr18PercentGST.reduce(0,+)
            GST28PercentTotal = arr28PercentGST.reduce(0,+)
            OrderAmountTotal = GSTPreTaxTotal + GST5PercentTotal + GST12PercentTotal + GST18PercentTotal + GST28PercentTotal
            
            lblPretaxtotal.text = Utility.formatRupeeWithDecimal(amount:GSTPreTaxTotal)
            lblGST_5Percent.text = Utility.formatRupeeWithDecimal(amount:GST5PercentTotal)
            lblGST_12Percent.text = Utility.formatRupeeWithDecimal(amount:GST12PercentTotal)
            lblGST_18Percent.text = Utility.formatRupeeWithDecimal(amount:GST18PercentTotal)
            lblGST_28Percent.text = Utility.formatRupeeWithDecimal(amount:GST28PercentTotal)
            lblOrderAmountTotal.text = Utility.formatRupeeWithDecimal(amount:OrderAmountTotal)
            
            if(GST5PercentTotal == Double(0)){
                heightConstraint_5.constant = CGFloat(0)
            }else{
                 heightConstraint_5.constant = CGFloat(30)
            }
            
            if(GST12PercentTotal == Double(0)){
                 heightConstraint_12.constant = CGFloat(0)
            }else{
                heightConstraint_12.constant = CGFloat(30)
            }
            
            if(GST18PercentTotal == Double(0)){
                 heightConstraint_18.constant = CGFloat(0)
            }else{
                heightConstraint_18.constant = CGFloat(30)
            }
            
            if(GST28PercentTotal == Double(0)){
                 heightConstraint_28.constant = CGFloat(0)
            }else{
                heightConstraint_28.constant = CGFloat(30)
            }
            
            
            
        }else{
            lblPretaxtotal.text = "-"
            lblGST_5Percent.text = "-"
            lblGST_12Percent.text = "-"
            lblGST_18Percent.text = "-"
            lblGST_28Percent.text = "-"
            lblOrderAmountTotal.text = "-"
        }
    }
    
   

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}


extension OrderViewCartController: ViewPagerControllerDataSource {
    
    func numberOfPages() -> Int {
        return tabs.count
    }
    
    func viewControllerAtPosition(position:Int) -> UIViewController {
        let vc = UIViewController()
        
        initItemPosition = -1
        showCartData(tabPosition: position,itemPosition:initItemPosition)
        showAmountWithGSTAdded(itemPosition: -1, removeClicked: false)
        filterSearch()
        
        return vc
    }
    
    func tabsForPages() -> [ViewPagerTab] {
        return tabs
    }
    
    func startViewPagerAtIndex() -> Int {
        return checkCount
    }
    
}

extension OrderViewCartController: ViewPagerControllerDelegate {
    
    func willMoveToControllerAtIndex(index:Int) {
        print("Moving to page \(index)")
    }
    
    func didMoveToControllerAtIndex(index: Int) {
        print("Moved to page \(index)")
    }
}


