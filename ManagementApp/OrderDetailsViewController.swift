//
//  OrderDetailsViewController.swift
//  DealorsApp
//
//  Created by Goldmedal on 11/16/18.
//  Copyright © 2018 Goldmedal. All rights reserved.
//

import UIKit
import FirebaseAnalytics

class OrderDetailsViewController: UIViewController, UITableViewDelegate , UITableViewDataSource ,UISearchBarDelegate,UITextFieldDelegate,UpdateCartDelegate{
   
     @IBOutlet weak var noDataView: NoDataView!
     @IBOutlet weak var tableView: UITableView!
     @IBOutlet weak var searchBar: RoundSearchBar!
     @IBOutlet weak var edtQuantity: UITextField!
     @IBOutlet weak var imvBack: UIImageView!
    
    @IBOutlet weak var vwCalculateAmount: UIView!
    
    //variable for amount calculations
    @IBOutlet weak var lblMrpRate : UILabel!
    @IBOutlet weak var lblDlpRate : UILabel!
    @IBOutlet weak var lblDiscountRate : UILabel!
    @IBOutlet weak var lblPromotionalRate : UILabel!
    @IBOutlet weak var lblWithoutTaxRate : UILabel!
    @IBOutlet weak var lblGSTRate : UILabel!
    @IBOutlet weak var lblWithTaxRate : UILabel!
    
    @IBOutlet weak var lblMrpAmount : UILabel!
    @IBOutlet weak var lblDlpAmount : UILabel!
    @IBOutlet weak var lblDiscountAmount : UILabel!
    @IBOutlet weak var lblPromotionalAmount : UILabel!
    @IBOutlet weak var lblWithoutTaxAmount : UILabel!
    @IBOutlet weak var lblGSTAmount : UILabel!
    @IBOutlet weak var lblWithTaxAmount : UILabel!
 
    @IBOutlet weak var lblItemQtyUnit : UILabel!
    @IBOutlet weak var lblBoxQty : UILabel!
    @IBOutlet weak var lblCartonQty : UILabel!
    @IBOutlet weak var lblApprovedOrder : UILabel!
    @IBOutlet weak var lblUnapprovedOrder : UILabel!
    
    @IBOutlet weak var btnViewCart: UIButton!
    
    var totalQty = "1"
    
    var cartonQty:Double = 0
    var mrpRate:Double = 0
    var dlpRate:Double = 0
    var discountRate:Double = 0
    var promotionalRate:Double = 0
    var promotionalQty:Double = 0
    var GSTRate:Double = 0
    
    var mrpAmount:Double = 0
    var dlpAmount:Double = 0
    var discountAmount:Double = 0
    var promotionalAmount:Double = 0
    var GSTAmount:Double = 0
    var withOutTaxAmount:Double = 0
    var withTaxAmount:Double = 0
    
    var promoDiscountArray = [Double]()
    var promoQtyArray = [Double]()
    var promoArrayMain = [String]()
    var promoSeparatedArray = [String]()
    var promoString = "0-0"
    var highestPromoDiscountQty:Double = 0
   
    var divId = Int()
    var catId = Int()
    var strCin = ""
    var OrderDetailApi=""
    var strSearchText = ""
    
    var OrderDetailElementMain = [OrderDetailElement]()
    var OrderDetailArray = [OrderDetailData]()
    
    var OrderFilteredDetailArray = [OrderDetailData]()
    
    var selectedCategory:OrderDetailData?
    var arrAddToCart = [OrderDetailData]()
    
     var arrAddToCartMain = [[OrderDetailData]]()
    
     var arrDivTabsId = [String]()
    
    let MAX_LENGTH_QTY = 5
    let ACCEPTABLE_NUMBERS = "0123456789"
    
    var totalItemsInCart = 0
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.noDataView.hideView(view: self.noDataView)
        
        arrDivTabsId = ["1","2","4","6","7"]
        
        let loginData =  UserDefaults.standard.value(forKey: "loginData") as? Dictionary ?? [:]
        strCin = loginData["userlogid"] as? String ?? ""
       
        //        let initialData =  UserDefaults.standard.value(forKey: "initialData") as? Dictionary ?? [:]
        //        OrderDetailApi = (initialData["baseApi"] as? String ?? "")+""+(initialData["comboSchemes"] as? String ?? "")
        OrderDetailApi = "https://api.goldmedalindia.in//api/getOrderItemDetails"
        
        hideAmount()
      
        let placeholderAppearance = UILabel.appearance(whenContainedInInstancesOf: [UISearchBar.self])
        placeholderAppearance.font = UIFont(name: "Roboto-Regular", size: 12)
        placeholderAppearance.textColor = UIColor.init(named: "FontLightText")
        
        let searchTextAppearance = UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self])
        searchTextAppearance.font = UIFont(name: "Roboto-Regular", size: 12)
        searchTextAppearance.textColor = UIColor.init(named: "FontDarkText")
        
        edtQuantity.text = totalQty
        
        
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
        if (Utility.isConnectedToNetwork()) {
            print("Internet connection available")
            self.apiOrderDetailList()
            self.noDataView.hideView(view: self.noDataView)
        }
        else{
            print("No internet connection available")
            
            let alert = UIAlertView(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
            self.noDataView.showView(view: self.noDataView, from: "NET")
        }
        
        
        edtQuantity.addTarget(self, action: #selector(self.textFieldDidChange(_:)),
                            for: UIControlEvents.editingChanged)
      
        
        edtQuantity.delegate = self
        
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.searchBar.delegate = self;
        
        let tabBack = UITapGestureRecognizer(target: self, action: #selector(self.tapFunction))
        imvBack.addGestureRecognizer(tabBack)
        
        Analytics.setScreenName("ORDER DETAIL SCREEN", screenClass: "OrderViewController")
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        print("TEXT DID CHANGE")
         totalQty = textField.text!
        
        if(Int(totalQty) == 0){
            textField.text! = "1"
            totalQty = textField.text!
        }
        
        
        
        if(!totalQty.isEmpty && !(Double(totalQty)?.isNaN)!  && !vwCalculateAmount.isHidden){
            calculateAmount()
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        print("TEXT RANGE")
        let newLength: Int = textField.text!.characters.count + string.characters.count - range.length
        let numberOnly = NSCharacterSet.init(charactersIn: ACCEPTABLE_NUMBERS).inverted
        let strValid = string.rangeOfCharacter(from: numberOnly) == nil

        return (strValid && (newLength <= MAX_LENGTH_QTY))
      
    }
    
    
    @objc func tapFunction(sender:UITapGestureRecognizer) {
        print("back")
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func showCartonQtyAlert(){
        if(Int(cartonQty) > 0 && Int(totalQty ?? "0")! > 0){
            
            var i = (Int(totalQty)!/Int(cartonQty))+1
            
            var lowerRange = (Int(cartonQty)-(Int(cartonQty*0.05))*Int(i))
            var upperRange = (Int(cartonQty)*Int(i))
            
            if case lowerRange...upperRange = Int(totalQty)! {
                let alert = UIAlertView(title: "Carton Box Range", message: "Please make your carton in next slot of  \(String(cartonQty))", delegate: nil, cancelButtonTitle: "OK")
                alert.show()
            }
        }
    }

    //search filter
    func filterSearch(){
        self.OrderFilteredDetailArray.removeAll()
        
        let searchText = searchBar.text ?? ""
        OrderFilteredDetailArray = OrderDetailArray.filter { item in
            let isMatchingSearchText = item.itemcode!.lowercased().contains(searchText.lowercased()) || searchText.lowercased().characters.count == 0
            return isMatchingSearchText
        }
        tableView.reloadData()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText.characters.count > 0 {
            strSearchText = searchText
            filterSearch()
        }else{
            totalQty = "1"
            edtQuantity.text = totalQty
            lblItemQtyUnit.text = ""
            cartonQty = 0
            
            self.OrderFilteredDetailArray.removeAll()
             tableView.reloadData()
             hideAmount()
        }
       
    }
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    
    
    func apiOrderDetailList(){
         ViewControllerUtils.sharedInstance.showLoader()
        
        let json: [String: Any] = ["CIN":strCin,"ClientSecret":"ClientSecret","DivisionId":divId,"CategoryId":catId]
        
        DataManager.shared.makeAPICall(url: OrderDetailApi, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            
            DispatchQueue.main.async {
                do {
                    self.OrderDetailElementMain = try JSONDecoder().decode([OrderDetailElement].self, from: data!)
                    self.OrderDetailArray = self.OrderDetailElementMain[0].data
                    
                    //Adding item qty in array
                    for i in 0...(self.OrderDetailArray.count-1){
                         self.OrderDetailArray[i].itemQty = 1
                         self.OrderDetailArray[i].totalAmount = "0"
                         self.OrderDetailArray[i].taxAmount = "0"
                         self.OrderDetailArray[i].mrpAmnt = "0"
                         self.OrderDetailArray[i].dlpAmnt = "0"
                         self.OrderDetailArray[i].promoAmnt = "0"
                         self.OrderDetailArray[i].withTaxAmnt = "0"
                         self.OrderDetailArray[i].actualPromoDiscount = "0"
                         self.OrderDetailArray[i].highestPromoAmnt = "0"
                    }
               
                } catch let errorData {
                    print(errorData.localizedDescription)
                }
                
                if(self.OrderDetailArray.count>0){
                    if(self.tableView != nil)
                    {
                        self.tableView.reloadData()
                    }
                    self.noDataView.hideView(view: self.noDataView)
                }else{
                    self.noDataView.showView(view: self.noDataView, from: "NDA")
                }
    
            }
        }) { (Error) in
            print(Error?.localizedDescription as Any)
            self.noDataView.showView(view: self.noDataView, from: "ERR")
             ViewControllerUtils.sharedInstance.removeLoader()
        }
        
         ViewControllerUtils.sharedInstance.removeLoader()
    }
    
    func showAmount(){
        vwCalculateAmount.isHidden = false
        tableView.isHidden = true
        edtQuantity.isUserInteractionEnabled = true
    }
    
    func hideAmount(){
        vwCalculateAmount.isHidden = true
        tableView.isHidden = false
        edtQuantity.isUserInteractionEnabled = false
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return OrderFilteredDetailArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchOrderRowCell", for: indexPath) as! SearchOrderRowCell
        cell.lblCategory.text = OrderFilteredDetailArray[indexPath.row].itemcode
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if(!totalQty.isEmpty){
            searchBar.text = OrderFilteredDetailArray[indexPath.row].itemcode
            selectedCategory = OrderFilteredDetailArray[indexPath.row]
            OrderFilteredDetailArray.removeAll()
            tableView.reloadData()
            
            calculateAmount()
            showAmount()
        }else{
            let alert = UIAlertView(title: "No Quantity", message: "Please select appropriate quantity", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
        }
        
    }
    
    // - - - - - - - --  -- -- - - - - - - --  -- - -- -  -- -  clicked view cart - - - - - - -- - - - - - - --  -- - -- -  --  -- - -- -
    @IBAction func clicked_viewCart(_ sender: UIButton) {

        weak var pvc = self.presentingViewController
        
        self.dismiss(animated: false, completion: {
            let vcViewCart = self.storyboard?.instantiateViewController(withIdentifier: "OrderViewCart") as! OrderViewCartController
             ViewControllerUtils.sharedInstance.removeLoader()
            pvc?.present(vcViewCart, animated: false, completion: nil)
        })
    }
    
    
    func addToCart(){
        selectedCategory?.itemQty = Int(totalQty)
        selectedCategory?.totalAmount = String(withOutTaxAmount)
        selectedCategory?.taxAmount = String(GSTAmount)
        selectedCategory?.mrpAmnt = String(mrpAmount)
        selectedCategory?.dlpAmnt = String(dlpAmount)
        selectedCategory?.promoAmnt = String(promotionalAmount)
        selectedCategory?.withTaxAmnt = String(withTaxAmount)
        selectedCategory?.discountAmnt = String(discountAmount)
        selectedCategory?.actualPromoDiscount = String(promotionalRate)
        selectedCategory?.highestPromoAmnt = String(highestPromoDiscountQty)
        
        arrAddToCartMain.removeAll()
        arrAddToCartMain = Array(repeating:[OrderDetailData](), count:arrDivTabsId.count)
        
        let indexOfDiv = arrDivTabsId.index{$0 == (selectedCategory?.divisionId)!}
        print("Index of - - - - ",indexOfDiv!)
        
        if(indexOfDiv! < arrDivTabsId.count){
            arrAddToCartMain[indexOfDiv!].append(selectedCategory!)
        }
        
        if let arrViewCartData = UserDefaults.standard.object(forKey: "addToCart") as? Data {
            let decoder = JSONDecoder()
            if var decodedData = try? decoder.decode([[OrderDetailData]].self, from: arrViewCartData) {
                print("RETRIEVED CART ARR ------- ",decodedData)
                if(decodedData.count == 0){
                    arrAddToCartMain.removeAll()
                    arrAddToCartMain = Array(repeating:[OrderDetailData](), count:self.arrDivTabsId.count)
                    arrAddToCartMain.append(contentsOf: decodedData)
                }
                
                if(indexOfDiv! < self.arrDivTabsId.count){
                    
                    // - - - - - - check to determine if item is already present inside the cart or not - - - - - -
                    if (decodedData[indexOfDiv!].count>0 && decodedData[indexOfDiv!].contains(where: {$0.itemid == selectedCategory?.itemid})) {
                        let alert = UIAlertView(title: "Already Present", message: "Item Already Present inside the cart", delegate: nil, cancelButtonTitle: "OK")
                        alert.show()
                        
                        return
                    } else {
                        decodedData[indexOfDiv!].append(selectedCategory!)
                    }
                    
                }
                arrAddToCartMain = decodedData
            }
            
            let joined = Array(arrAddToCartMain.joined())
            totalItemsInCart = joined.count
         
            btnViewCart.setTitle(String(totalItemsInCart), for: .normal)
         
            UserDefaults.standard.set(strCin, forKey: "CartCount")
            
            var lastCin = UserDefaults.standard.value(forKey: "CartCount") as! String
            print("LAST CIN - - ",lastCin)
            
            searchBar.text = ""
            self.OrderFilteredDetailArray.removeAll()
            totalQty = "1"
            edtQuantity.text = totalQty
            tableView.reloadData()
            hideAmount()
        }
        
        let defaults = UserDefaults.standard
        let encoder = JSONEncoder()
        if let encodedData = try? encoder.encode(arrAddToCartMain)
        {
            defaults.set(encodedData, forKey: "addToCart")
            print("SAVED CART ARR ------- ",encodedData)
        }
        
        OrderFilteredDetailArray.removeAll()
        tableView.reloadData()
        hideAmount()
        
        let alert = UIAlertView(title: "Item Added", message: "Item Added to Cart successfully", delegate: nil, cancelButtonTitle: "OK")
        alert.show()
    }
    
    //- - - - - - - - - - - - - - - - - - --  -- - -- - - - - - - - - ADD TO CART  - - - - - - - - - - -- - - - - - - - - - - -
    @IBAction func clicked_addToCart(_ sender: UIButton) {
        if(!(selectedCategory?.itemcode?.isEmpty)! && Int(selectedCategory?.mrp ?? "0")! > 0)
        {
            if(Double(totalQty)! >= highestPromoDiscountQty)
            {
                addToCart()
            }else{
                // - - - - - - Show pop up for promotional rates  - - - - - - - - -
                let sb = UIStoryboard(name: "PromotionalRatePopup", bundle: nil)
                let popup = sb.instantiateInitialViewController() as? PromotionalRateController
                popup?.promoDiscountArray = promoDiscountArray
                popup?.promoQtyArray = promoQtyArray
                popup?.delegate = self
                self.present(popup!, animated: true)

            }
        }else{
            let alert = UIAlertView(title: "Invalid Item", message: "Item is not valid", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
        }
            
    }
    
    // - - - -  - - Delegate to confirm item added to cart - - - - - - - -
    func UpdateCartPopup() {
        addToCart()
    }

    // - -  - -- - - - - -  - - - - - - - - - - - - -  AMOUNT CALCULATION  - - - - - - - - - - --  - - - - - - - - - - -
    func calculateAmount(){
        if(Int(totalQty)! > 0){
        mrpRate = Double(selectedCategory?.mrp ?? "0")!
        dlpRate = Double(selectedCategory?.dlp ?? "0")!
        GSTRate = Double(selectedCategory?.taxpercent ?? "0")!
        discountRate = Double(selectedCategory?.discount ?? "0")!
        
        lblMrpRate.text = Utility.formatRupeeWithDecimal(amount: mrpRate)
        mrpAmount = mrpRate * Double(totalQty)!
        lblMrpAmount.text = Utility.formatRupeeWithDecimal(amount: mrpAmount)
        
        lblDlpRate.text = Utility.formatRupeeWithDecimal(amount: dlpRate)
        dlpAmount = dlpRate * Double(totalQty)!
        lblDlpAmount.text = Utility.formatRupeeWithDecimal(amount: dlpAmount)
        
        lblDiscountRate.text = String(discountRate)+"%"
        if(discountRate>0){
            discountAmount = dlpAmount * (discountRate/100)
        }else{
            discountAmount = 0
        }
        lblDiscountAmount.text = Utility.formatRupeeWithDecimal(amount: discountAmount)
            
        //- - - -  - -  - - Logic for calculating promotional amnt and rate - - -  - - - - - - -
            promoString = selectedCategory?.pramotionaldiscount ?? "0-0"
          
            if (promoString.range(of:",") != nil) {
                promoArrayMain = promoString.components(separatedBy: ",")
            }else{
                promoArrayMain = [promoString]
            }
            
             print("PROMO STRING - - - ",promoString)
       
          
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
            
            print("PROMO - - - ",promoQtyArray," - - - - - ",promoDiscountArray," - - - - -  ",promotionalRate,"-----",highestPromoDiscountQty)
      
        lblPromotionalRate.text = String(promotionalRate)+"%"
            
        if(promotionalRate>0){
            promotionalAmount = (dlpAmount - discountAmount) * (promotionalRate/100)
        }else{
            promotionalAmount = 0
        }
         lblPromotionalAmount.text = Utility.formatRupeeWithDecimal(amount: promotionalAmount)
        
        lblWithoutTaxRate.text =  "-"
        withOutTaxAmount = dlpAmount - discountAmount - promotionalAmount
        lblWithoutTaxAmount.text = Utility.formatRupeeWithDecimal(amount:withOutTaxAmount)
        
        lblGSTRate.text = String(GSTRate)+"%"
        if(GSTRate > 0){
            GSTAmount = withOutTaxAmount * (GSTRate/100)
        }else{
            GSTAmount = 0
        }
        lblGSTAmount.text = Utility.formatRupeeWithDecimal(amount:GSTAmount)
        
            lblWithTaxRate.text = "-"
            withTaxAmount = GSTAmount + withOutTaxAmount
            lblWithTaxAmount.text = Utility.formatRupeeWithDecimal(amount:withTaxAmount)
            
            lblBoxQty.text = selectedCategory?.boxQty ?? "-"
            lblCartonQty.text = selectedCategory?.cartoonQty ?? "-"
            lblItemQtyUnit.text = selectedCategory?.unitnm ?? ""
            lblApprovedOrder.text = selectedCategory?.approveQty ?? "-"
            lblUnapprovedOrder.text = selectedCategory?.unapproveQty ?? "-"
            
            cartonQty = Double(selectedCategory?.cartoonQty ?? "0")!
            
            showCartonQtyAlert()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

