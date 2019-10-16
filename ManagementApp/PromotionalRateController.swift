//
//  SpinTotalPopupController.swift
//  DealorsApp
//
//  Created by Goldmedal on 10/17/18.
//  Copyright © 2018 Goldmedal. All rights reserved.
//

import UIKit

protocol UpdateCartDelegate {
    func UpdateCartPopup()
}

class PromotionalRateController: UIViewController, UITableViewDelegate , UITableViewDataSource {
    
    @IBOutlet weak var viewHeight: NSLayoutConstraint!
    @IBOutlet weak var viewBottomHeight: NSLayoutConstraint!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var imvClose: UIImageView!
    @IBOutlet weak var vwClose: UIView!
    @IBOutlet weak var vwBottomMain: UIView!
    var callFrom = String()
    
    var promoDiscountArray = [Double]()
    var promoQtyArray = [Double]()
    
    var delegate: UpdateCartDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        
        if(callFrom.isEqual("cart")){
            vwBottomMain.isHidden = true
            viewBottomHeight.constant = CGFloat(0)
        }else{
            vwBottomMain.isHidden = false
            viewBottomHeight.constant = CGFloat(50)
        }
        
        
        if(self.tableView != nil)
        {
            self.tableView.reloadData()
            self.viewHeight.constant = CGFloat((self.promoQtyArray.count*40)+200)
        }
        
        promoDiscountArray = promoDiscountArray.sorted()
        promoQtyArray = promoQtyArray.sorted()
        
        
        if(self.promoQtyArray.count == 0){
            var alert = UIAlertView(title: "No Data available", message: "No Data available", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
            
            self.dismiss(animated: true)
        }
        
        let tabClose = UITapGestureRecognizer(target: self, action: #selector(self.tapFunction))
        vwClose.addGestureRecognizer(tabClose)
    }
    
    @objc func tapFunction(sender:UITapGestureRecognizer) {
        print("tap working")
        dismiss(animated: true)
    }
    
    @IBAction func clicked_update(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @IBAction func clicked_proceed(_ sender: UIButton) {
        delegate?.UpdateCartPopup()
        dismiss(animated: true)
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PromotionalViewCell", for: indexPath) as! PromotionalViewCell
        
        cell.lblPromoQty.text = String(promoQtyArray[indexPath.row])
        cell.lblPromoDiscount.text = String(promoDiscountArray[indexPath.row])
        
        return cell
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return promoQtyArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
}


