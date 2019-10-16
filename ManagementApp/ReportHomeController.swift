//
//  ReportHomeController.swift
//  DealorsApp
//
//  Created by Goldmedal on 3/29/18.
//  Copyright © 2018 Goldmedal. All rights reserved.
//

import UIKit

class ReportHomeController: UIViewController , UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var collection: UICollectionView!
    @IBOutlet weak var imvBack: UIImageView!
    
    var reportItem:Array = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

         reportItem = ["DIVISION WISE SALES","DISPATCHED MATERIAL","PENDING ORDERS","OUTSTANDING","CREDIT LIMIT","ACTIVE SCHEME","SALES PAYMENT REPORT"]
        
                // Do any additional setup after loading the view.
        let tabBack = UITapGestureRecognizer(target: self, action: #selector(ReportHomeController.tapFunction))
        imvBack.addGestureRecognizer(tabBack)
    }
    
    @objc func tapFunction(sender:UITapGestureRecognizer) {
        print("back")
        self.dismiss(animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
     func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       
        return reportItem.count
    }
    
     func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "report", for: indexPath) as! ReportRowCell
        
        cell.lblReport.text = reportItem[indexPath.row]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
      
        return UIEdgeInsetsMake(40, 0, 0, 0)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let picWidth = self.view.frame.size.width * 0.4
        let picHeight = self.view.frame.size.width * 0.25
        
        
        return CGSize(width: picWidth, height: picHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if(indexPath.row == 0){
            let vcDivisionWiseSale = self.storyboard?.instantiateViewController(withIdentifier: "DivisionWiseSale") as! DivisionWiseSale
            self.present(vcDivisionWiseSale, animated: true, completion: nil)
            
        }
        if(indexPath.row == 1){
            //let vcDispatchedMaterial = self.storyboard?.instantiateViewController(withIdentifier: "DispatchedMaterial") as! DispatchedMaterialController
            //self.present(vcDispatchedMaterial, animated: true, completion: nil)
            
        }
        if(indexPath.row == 2){
            //let vcPendingOrder = self.storyboard?.instantiateViewController(withIdentifier: "PendingOrder") as! PendingOrderController
            //self.present(vcPendingOrder, animated: true, completion: nil)
            
        }
        else if(indexPath.row == 3)
        {
        let vcOutStanding = self.storyboard?.instantiateViewController(withIdentifier: "OutStanding") as! OutStandingController
        self.present(vcOutStanding, animated: true, completion: nil)
        }
        
            
        else if(indexPath.row == 5)
        {
            let vcActiveScheme = self.storyboard?.instantiateViewController(withIdentifier: "ActiveScheme") as! ActiveSchemeController
            self.present(vcActiveScheme, animated: true, completion: nil)
        }
            
        else if(indexPath.row == 6)
        {
            //let vcSalesPayment = self.storyboard?.instantiateViewController(withIdentifier: "SalesPayment") as! SalesPaymentController
            //self.present(vcSalesPayment, animated: true, completion: nil)
        }
       
        
    }
    
}
