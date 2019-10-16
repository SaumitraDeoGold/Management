//
//  AddCatalogueController.swift
//  DealorsApp
//
//  Created by Goldmedal on 12/10/18.
//  Copyright © 2018 Goldmedal. All rights reserved.
//

import UIKit

class AddCatalogueController: UIViewController, UITableViewDelegate , UITableViewDataSource , CatalogueQtyDelegate ,UITextFieldDelegate{
   
    @IBOutlet weak var viewHeight: NSLayoutConstraint!
    
    var AddCatalogueListElementMain = [OrderDetailElement]()
    var AddCatalogueArray = [OrderDetailData]()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var imvClose: UIImageView!
    @IBOutlet weak var vwClose: UIView!
    @IBOutlet weak var lblItemName: UILabel!
    @IBOutlet weak var lblItemCode: UILabel!
    @IBOutlet weak var lblItemQty: UILabel!
    @IBOutlet weak var lblItemRate: UILabel!
    
    var delegate: PopupDateDelegate?
    
    var strCin = ""
    var strItemCode = String()
    var strItemName = String()
    
    var arrDivTabsId = [String]()
    
     var arrAddToCartMain = [[OrderDetailData]]()
    
    var edtTotalQty = "0"
    var totalQty = "0"
   
    var addCatalogueListApi=""
    
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
    
    var totalItemsInCart = 0
    
    var totalQtyArr = [Double]()
    var totalAmntArr = [Double]()
    
    let MAX_LENGTH_QTY = 5
    let ACCEPTABLE_NUMBERS = "0123456789"
   
    var repeateditems = [String]()
    
    var promoDiscToShow = [String]()
    var attributedString: NSMutableAttributedString? = nil
    var matchedPromoIndex = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let initialData =  UserDefaults.standard.value(forKey: "initialData") as? Dictionary ?? [:]

        arrDivTabsId = ["1","2","4","6","7"]
        
     //   addCatalogueListApi = (initialData["baseApi"] as? String ?? "")+""+(initialData["creditNoteDetails"] as? String ?? "")
        addCatalogueListApi = "https://api.goldmedalindia.in//api/getOrderItemCatPriceDetails"
        
        
        lblItemName.text = strItemName
        lblItemCode.text = strItemCode
        
        // Do any additional setup after loading the view.
        if (Utility.isConnectedToNetwork()) {
            print("Internet connection available")
            OperationQueue.main.addOperation {
                self.apiAddCatalogueList()
            }
        }
        else{
            print("No internet connection available")
            
            var alert = UIAlertView(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
        }
        
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        
        totalAmnt()
        
        let tabClose = UITapGestureRecognizer(target: self, action: #selector(self.tapFunction))
        vwClose.addGestureRecognizer(tabClose)
    }
    
    @objc func tapFunction(sender:UITapGestureRecognizer) {
        print("tap working")
        dismiss(animated: true)
    }
    
    
    func apiAddCatalogueList(){
        ViewControllerUtils.sharedInstance.showLoader()
   
        var  json = ["CIN":strCin,"ClientSecret":"ClientSecret","ItemCode":strItemCode,"ItemName":strItemName]
       
        print(json)
        
        DataManager.shared.makeAPICall(url: addCatalogueListApi, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            DispatchQueue.main.async {
                do {
                    self.AddCatalogueListElementMain = try JSONDecoder().decode([OrderDetailElement].self, from: data!)
                    self.AddCatalogueArray = self.AddCatalogueListElementMain[0].data
                    
                    for i in 0...(self.AddCatalogueArray.count-1){
                        self.AddCatalogueArray[i].itemQty = 0
                        self.AddCatalogueArray[i].totalAmount = "0"
                        self.AddCatalogueArray[i].taxAmount = "0"
                        self.AddCatalogueArray[i].mrpAmnt = "0"
                        self.AddCatalogueArray[i].dlpAmnt = "0"
                        self.AddCatalogueArray[i].promoAmnt = "0"
                        self.AddCatalogueArray[i].withTaxAmnt = "0"
                        self.AddCatalogueArray[i].actualPromoDiscount = "0"
                        self.AddCatalogueArray[i].highestPromoAmnt = "0"
                    }
                    
                } catch let errorData {
                    print(errorData.localizedDescription)
                }
                
                if(self.AddCatalogueArray.count == 0){
                    var alert = UIAlertView(title: "No Data Available", message: "No Data Available", delegate: nil, cancelButtonTitle: "OK")
                    alert.show()
                    
                    self.dismiss(animated: true)
                }
                
                
                if(self.tableView != nil)
                {
                    self.tableView.reloadData()
                    self.viewHeight.constant = CGFloat((self.AddCatalogueArray.count*130)+100)
                }
                
            }
            ViewControllerUtils.sharedInstance.removeLoader()
        }) { (Error) in
            ViewControllerUtils.sharedInstance.removeLoader()
            print(Error?.localizedDescription)
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CatalogueAddViewCell", for: indexPath) as! CatalogueAddViewCell
      
        cell.lblItemName.text = AddCatalogueArray[indexPath.row].colornm
        cell.lblMrp.text = Utility.formatRupeeWithDecimal(amount:Double(AddCatalogueArray[indexPath.row].mrp ?? "0")!)
        cell.lblDlp.text = Utility.formatRupeeWithDecimal(amount:Double(AddCatalogueArray[indexPath.row].dlp ?? "0")!)
        cell.lblDiscount.text = String((AddCatalogueArray[indexPath.row].discount ?? "0")!)+"%"
        
        promoDiscount(orderQty: String(describing: AddCatalogueArray[indexPath.row].itemQty ?? 0), index: indexPath.row)
        
       // cell.lblPromoDiscount.text = (promoDiscToShow.map{String($0)}).joined(separator: " ,")
        cell.lblPromoDiscount.attributedText = attributedString
        
        cell.lblCartonQty.text = (String(describing:Int(AddCatalogueArray[indexPath.row].cartoonQty ?? "0")!)) + " " + (AddCatalogueArray[indexPath.row].unitnm ?? "-")!
        cell.lblOuterQty.text = (String(describing:Int(AddCatalogueArray[indexPath.row].boxQty ?? "0")!)) + " " + (AddCatalogueArray[indexPath.row].unitnm ?? "-")!
        
        cell.lblApprovedPendingOrder.text = "Approved Qty\n \((AddCatalogueArray[indexPath.row].approveQty ?? "0")!)  \((AddCatalogueArray[indexPath.row].unitnm ?? "-")!)"
        
        cell.lblUnApprovedPendingOrder.text = "Unapproved Qty\n \((AddCatalogueArray[indexPath.row].unapproveQty ?? "0")!)  \((AddCatalogueArray[indexPath.row].unitnm ?? "-")!)"
        
        cell.btnQty.setTitle(String(describing: AddCatalogueArray[indexPath.row].itemQty ?? 0), for: .normal)
        
        cell.delegate = self
        
        return cell
    }
    
    
    func CatalogueTotalQty(cell: CatalogueAddViewCell) {
        var indexPath = self.tableView.indexPath(for: cell)
        
        let alertController = UIAlertController(title: "ENTER QUANTITY", message: "", preferredStyle: .alert)
        
        //the confirm action taking the inputs
        let confirmAction = UIAlertAction(title: "Enter", style: .default) { (_) in
            
            //getting the input values from user
            self.edtTotalQty = (alertController.textFields?[0].text)!
            
            if(self.edtTotalQty.count == 0){
                self.edtTotalQty = "0"
            }
            
            self.ShowTotalQty(orderQty: self.edtTotalQty, cell: cell)
            
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
    
    
    
    //  --  - - - - - - - - - called when edit text for qty changes - - -  - - - - - - - - - - --
    func ShowTotalQty(orderQty: String, cell: CatalogueAddViewCell) {
        let indexPath = self.tableView.indexPath(for: cell)
        
         totalQty = orderQty
        
        if(totalQty.isEmpty){
          totalQty = "0"
        }
        
         cell.btnQty.setTitle(orderQty, for: .normal)
        
        AddCatalogueArray[(indexPath?.row)!].itemQty = Int(totalQty)
       
        calculateAmount(orderQty: totalQty,index: (indexPath?.row)!)
        cell.lblPromoDiscount.attributedText = attributedString
        totalAmnt()
    }
    
    
    func calculateAmount(orderQty: String,index:Int){
   //     if(Int(orderQty)! > 0){
            mrpRate = Double(AddCatalogueArray[index].mrp ?? "0")!
            dlpRate = Double(AddCatalogueArray[index].dlp ?? "0")!
            GSTRate = Double(AddCatalogueArray[index].taxpercent ?? "0")!
            discountRate = Double(AddCatalogueArray[index].discount ?? "0")!
            mrpAmount = mrpRate * Double(totalQty)!
            dlpAmount = dlpRate * Double(totalQty)!
          
            if(discountRate>0){
                discountAmount = dlpAmount * (discountRate/100)
            }else{
                discountAmount = 0
            }
          
            promoDiscount(orderQty: orderQty, index: index)
           
            withOutTaxAmount = dlpAmount - discountAmount - promotionalAmount
           
            if(GSTRate > 0){
                GSTAmount = withOutTaxAmount * (GSTRate/100)
            }else{
                GSTAmount = 0
            }
           
            withTaxAmount = GSTAmount + withOutTaxAmount
            cartonQty = Double(AddCatalogueArray[index].cartoonQty ?? "0")!
            
            
            AddCatalogueArray[index].totalAmount = String(withOutTaxAmount)
            AddCatalogueArray[index].taxAmount = String(GSTAmount)
            AddCatalogueArray[index].mrpAmnt = String(mrpAmount)
            AddCatalogueArray[index].dlpAmnt = String(dlpAmount)
            AddCatalogueArray[index].promoAmnt = String(promotionalAmount)
            AddCatalogueArray[index].withTaxAmnt = String(withTaxAmount)
            AddCatalogueArray[index].discountAmnt = String(discountAmount)
            AddCatalogueArray[index].actualPromoDiscount = String(promotionalRate)
            AddCatalogueArray[index].highestPromoAmnt = String(highestPromoDiscountQty)

   //     }
    }
    
    func totalAmnt(){

        let totalEdtQty = AddCatalogueArray.reduce(0, { $0 + $1.itemQty! })
        let totalAmntWithoutTax = AddCatalogueArray.reduce(0, { $0 + Double($1.totalAmount!)! })
        
        lblItemQty.text = String(totalEdtQty)+" Item"
        lblItemRate.text = Utility.formatRupeeWithDecimal(amount:totalAmntWithoutTax)
    }
    
      //- - - -  - -  - - Logic for calculating promotional amnt and rate - - -  - - - - - - -
    func promoDiscount(orderQty: String,index:Int){
        promoDiscToShow.removeAll()
        matchedPromoIndex = -1
        
        promoString = AddCatalogueArray[index].pramotionaldiscount ?? "0-0"
        
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
                if(promoQtyArray[i]>0){
                    promotionalRate = promoDiscountArray[i]
                    matchedPromoIndex = (promoArrayMain.count - 1) - i
                }
                break
            }else{
                promotionalRate = 0
                matchedPromoIndex = -1
            }
        }
       
        
         for i in (0...(promoQtyArray.count - 1)).reversed(){
            promoDiscToShow.append(String(describing: Int(promoDiscountArray[i])) + "%" + " ("+String(describing: Int(promoQtyArray[i])) + (AddCatalogueArray[index].unitnm ?? "-")! + ")")
        }
        
        attributedString = NSMutableAttributedString(string: (promoDiscToShow.map{String($0)}).joined(separator: " ,"))
            if(matchedPromoIndex != -1){
                attributedString?.setColorForText(textForAttribute: promoDiscToShow[matchedPromoIndex], withColor: UIColor.init(named: "ColorGreen")!)
            }
        
        if(promotionalRate>0){
            promotionalAmount = (dlpAmount - discountAmount) * (promotionalRate/100)
        }else{
            promotionalAmount = 0
        }
      
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        print("TEXT RANGE")
        
        let newLength: Int = textField.text!.characters.count + string.characters.count - range.length
        let numberOnly = NSCharacterSet.init(charactersIn: ACCEPTABLE_NUMBERS).inverted
        let strValid = string.rangeOfCharacter(from: numberOnly) == nil
        
        return (strValid && (newLength <= MAX_LENGTH_QTY))
        
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AddCatalogueArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    
    // - -  - - - - - - - - - - -  - -  Calculate amount of catalogue item  - - - - - - - - - - - - -
    func calculateCart(){
        repeateditems.removeAll()
      
        arrAddToCartMain.removeAll()
        arrAddToCartMain = Array(repeating:[OrderDetailData](), count:arrDivTabsId.count)

        let indexOfDiv = arrDivTabsId.index{$0 == (AddCatalogueArray[0].divisionId)!}
        print("Index of - - - - ",indexOfDiv!)

        if(indexOfDiv! < arrDivTabsId.count){
             for i in 0...(self.AddCatalogueArray.count-1){
                arrAddToCartMain[indexOfDiv!].append(AddCatalogueArray[i])
            }
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
                    for i in (0...(self.AddCatalogueArray.count-1)).reversed(){
                    if (decodedData[indexOfDiv!].count>0 && decodedData[indexOfDiv!].contains(where: {$0.itemid == AddCatalogueArray[i].itemid}) && (AddCatalogueArray[i].itemQty ?? 0) > 0) {

                         repeateditems.append(AddCatalogueArray[i].colornm!)
                         AddCatalogueArray.remove(at: i)
                    } else {
                        if((AddCatalogueArray[i].itemQty ?? 0)! > 0){
                             decodedData[indexOfDiv!].append(AddCatalogueArray[i])
                        }else{
                            AddCatalogueArray.remove(at: i)
                        }
                    }
                }
             }
                arrAddToCartMain = decodedData
            }

            UserDefaults.standard.set(strCin, forKey: "CartCount")

            var lastCin = UserDefaults.standard.value(forKey: "CartCount") as! String
            print("LAST CIN - - ",lastCin)
        }

        let defaults = UserDefaults.standard
        let encoder = JSONEncoder()
        if let encodedData = try? encoder.encode(arrAddToCartMain)
        {
            defaults.set(encodedData, forKey: "addToCart")
            print("SAVED CART ARR ------- ",encodedData)
        }

        if(AddCatalogueArray.count > 0){
            let alert = UIAlertView(title: "Item Added", message: "Item Added to Cart successfully", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
        }else{
            if(repeateditems.count > 0){
                let alert = UIAlertView(title: "Failed!!!", message: "Items \(repeateditems.joined(separator: ",")) already present inside the cart)", delegate: nil, cancelButtonTitle: "OK")
                alert.show()
            }else{
                let alert = UIAlertView(title: "Failed!!!", message: "No Items added as no quantity was provided", delegate: nil, cancelButtonTitle: "OK")
                alert.show()
            }
        }
        
        
        if let arrViewCartData = UserDefaults.standard.object(forKey: "addToCart") as? Data {
            let decoder = JSONDecoder()
            if var decodedData = try? decoder.decode([[OrderDetailData]].self, from: arrViewCartData) {
                print("RETRIEVED CART ARR ------- ",decodedData)
                if(decodedData.count > 0){
                    let joined = Array(decodedData.joined())
                    totalItemsInCart = joined.count
                    
                    delegate?.showCartValue!(value: String(totalItemsInCart))
                }
            }
        }
        

        // close popup here
        dismiss(animated: true, completion: nil)
    }
    
    //- - - - - - - - - - - - - - - - - - --  -- - -- - - - - - - - - ADD TO CART  - - - - - - - - - - -- - - - - - - - - -
    @IBAction func clicked_addToCart(_ sender: UIButton) {
        if(AddCatalogueArray.count>0){
            calculateCart()
        }
    }
  
}


extension NSMutableAttributedString {
    
    func setColorForText(textForAttribute: String, withColor color: UIColor) {
        let range: NSRange = self.mutableString.range(of: textForAttribute, options: .caseInsensitive)
      
        // Swift 4.1 and below
        self.addAttribute(NSAttributedStringKey.foregroundColor, value: color, range: range)
    }
    
}
