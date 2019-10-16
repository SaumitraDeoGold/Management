//
//  OrderViewCell.swift
//  DealorsApp
//
//  Created by Goldmedal on 11/15/18.
//  Copyright © 2018 Goldmedal. All rights reserved.
//

import UIKit

class OrderViewCell: UITableViewCell {
    
    @IBOutlet weak var collectionView: UICollectionView!
    var arrCatItemsMain = [OrderData]()
    var orderBy:Int = 0
    
    func updateCellWith(category:[OrderData],orderBy:Int) {
        self.arrCatItemsMain = category
        self.orderBy = orderBy
        self.collectionView.reloadData()
    }
    
}


extension OrderViewCell : UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       
        if arrCatItemsMain.count > 0{
            return arrCatItemsMain.count
        }else{
            return 0
        }
     
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OrderCollectionViewCell", for: indexPath) as! OrderCollectionViewCell
        
        cell.lblCategory.text = arrCatItemsMain[indexPath.item].catnm ?? "-"
        if arrCatItemsMain[indexPath.item].catimage != ""
        {
            cell.imvCategory.sd_setImage(with: URL(string: arrCatItemsMain[indexPath.item].catimage ?? ""), placeholderImage: UIImage(named: "no_image_icon.png"))
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
      
        if(orderBy == 0){
            let   vcOrderDetails = parentViewController?.storyboard?.instantiateViewController(withIdentifier: "OrderDetails") as! OrderDetailsViewController
            
            vcOrderDetails.catId = arrCatItemsMain[indexPath.item].catid ?? 0
            vcOrderDetails.divId = arrCatItemsMain[indexPath.item].divisionid ?? 0
            
            parentViewController?.present(vcOrderDetails, animated: true, completion: nil)
        }else{
            let   vcOrderDetails = parentViewController?.storyboard?.instantiateViewController(withIdentifier: "OrderCatalogueController") as! OrderCatalogueController
            
            vcOrderDetails.catId = arrCatItemsMain[indexPath.item].catid ?? 0
            vcOrderDetails.divId = arrCatItemsMain[indexPath.item].divisionid ?? 0
            
            parentViewController?.present(vcOrderDetails, animated: true, completion: nil)
        }
        
    }
    
}

extension OrderViewCell : UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        let itemsPerRow:CGFloat = 4
//        let hardCodedPadding:CGFloat = 5
//        let itemWidth = (collectionView.bounds.width / itemsPerRow) - hardCodedPadding
//        let itemHeight = collectionView.bounds.height - (2 * hardCodedPadding)
        return CGSize(width: 150, height: 150)
    }
    
}
