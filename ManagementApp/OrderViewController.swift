//
//  OrderViewController.swift
//  DealorsApp
//
//  Created by Goldmedal on 5/12/18.
//  Copyright © 2018 Goldmedal. All rights reserved.
//

import UIKit
import FirebaseAnalytics
import DropDown

class OrderViewController: BaseViewController{
    
    @IBOutlet weak var noDataView: NoDataView!
    @IBOutlet weak var vwDropDown: RoundView!
    @IBOutlet weak var lblDropdownText: UILabel!
    
    var OrderElementMain = [OrderElement]()
    var OrderArray = [OrderData]()
    var OrderCategoryItems = [[OrderData]]()
    var OrderDivisionSection = [String]()
    
    var strCin = ""
    var OrderApi=""
    
     let dropDown = DropDown()
    var totalItemsInCart = 0
    
    var orderBy = 0
    
    @IBOutlet weak var tableView: UITableView!
     @IBOutlet weak var btnViewCart: UIButton!
  
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        addSlideMenuButton()
        
        self.noDataView.hideView(view: self.noDataView)
        
        dropDown.dataSource = ["By Code", "By Catalogue"]
        
         let gesture = UITapGestureRecognizer(target: self, action: "clickDropdown:")
         vwDropDown.addGestureRecognizer(gesture)
        
        lblDropdownText.text = dropDown.dataSource[0]
        
        dropDown.dismissMode = .onTap
        
        let loginData =  UserDefaults.standard.value(forKey: "loginData") as? Dictionary ?? [:]
        strCin = loginData["userlogid"] as? String ?? ""
        
        //        let initialData =  UserDefaults.standard.value(forKey: "initialData") as? Dictionary ?? [:]
        //        OrderApi = (initialData["baseApi"] as? String ?? "")+""+(initialData["comboSchemes"] as? String ?? "")
        OrderApi = "https://api.goldmedalindia.in//api/getOrderDivisionAndCat"
        
        // Do any additional setup after loading the view.
        if (Utility.isConnectedToNetwork()) {
            print("Internet connection available")
            self.apiOrderList()
            self.noDataView.hideView(view: self.noDataView)
        }
        else{
            print("No internet connection available")
            
            var alert = UIAlertView(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
            self.noDataView.showView(view: self.noDataView, from: "NET")
        }
        
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        
        btnViewCart.setTitle(String(totalItemsInCart), for: .normal)
        
        Analytics.setScreenName("MY ORDER SCREEN", screenClass: "OrderViewController")
    }
    
    @objc func clickDropdown(_ sender:UITapGestureRecognizer){
       
        dropDown.show()
        
        // The view to which the drop down will appear on
        dropDown.anchorView = vwDropDown // UIView or UIBarButtonItem
      
        
        // Action triggered on selection
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            print("Selected item: \(item) at index: \(index)")
            self.lblDropdownText.text = item
            self.orderBy = index
            
             print("ORDER BY - - -",self.orderBy)
            self.dropDown.hide()
            self.tableView.reloadData()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
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
    }
    
    func apiOrderList(){
        ViewControllerUtils.sharedInstance.showLoader()
        
        let json: [String: Any] = ["CIN":strCin,"ClientSecret":"ClientSecret"]
        
        DataManager.shared.makeAPICall(url: OrderApi, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            
            DispatchQueue.main.async {
                do {
                    self.OrderElementMain = try JSONDecoder().decode([OrderElement].self, from: data!)
                    self.OrderArray = self.OrderElementMain[0].data
                   
                 
                    let groupedDictionary = Dictionary(grouping: self.OrderArray, by: { (order) -> String in
                        return order.divisionnm!
                    })
                    
                    let keys = groupedDictionary.keys.sorted()
                    
                    self.OrderDivisionSection.append(contentsOf: keys)
                    
                    keys.forEach({ (key) in
                        self.OrderCategoryItems.append(groupedDictionary[key]!)
                    })
                  
                } catch let errorData {
                    print(errorData.localizedDescription)
                }
                
                if(self.OrderArray.count>0){
                    if(self.tableView != nil)
                    {
                        self.tableView.reloadData()
                    }
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
    
    @IBAction func clicked_viewCart(_ sender: UIButton) {
        let vcViewCart = self.storyboard?.instantiateViewController(withIdentifier: "OrderViewCart") as! OrderViewCartController
        ViewControllerUtils.sharedInstance.removeLoader()
        self.present(vcViewCart, animated: true, completion: nil)
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   
}

extension OrderViewController : UITableViewDelegate { }

extension OrderViewController : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 40))
        headerView.backgroundColor = UIColor.darkGray
        let label = UILabel()
        label.frame = CGRect.init(x: 20, y: 5, width: headerView.frame.width-10, height: headerView.frame.height-10)
        label.text = OrderDivisionSection[section]
        label.textColor = UIColor.white
        
        headerView.addSubview(label)
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 170
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return OrderDivisionSection.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OrderViewCell") as! OrderViewCell
        let itemCategory = self.OrderCategoryItems[indexPath.section]
        print("CELL ORDER TYPE - - -",self.orderBy)
        cell.updateCellWith(category:itemCategory, orderBy: self.orderBy)
        return cell
    }
}
