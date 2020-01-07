//
//  TechSpecsRowCell.swift
//  DealorsApp
//
//  Created by Goldmedal on 5/5/18.
//  Copyright © 2018 Goldmedal. All rights reserved.
//

import UIKit

class TechSpecsRowCell: UITableViewCell {
    
    @IBOutlet weak var collectionView: UICollectionView!
    var arrCatItemsMain = [TechSpecsData]()
    
    func updateCellWith(category:[TechSpecsData]) {
        self.arrCatItemsMain = category
        self.collectionView.reloadData()
    }
    
}


extension TechSpecsRowCell : UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if arrCatItemsMain.count > 0{
            return arrCatItemsMain.count
        }else{
            return 0
        }
        
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OrderCollectionViewCell", for: indexPath) as! OrderCollectionViewCell
        
        if arrCatItemsMain[indexPath.item].urlimg != ""
        {
            cell.imvCategory.sd_setImage(with: URL(string: arrCatItemsMain[indexPath.item].urlimg ?? ""), placeholderImage: UIImage(named: "no_image_icon.png"))
        }else{
            cell.imvCategory.image = UIImage(named: "no_image_icon.png")
        }
        
        cell.lblCategory.text = arrCatItemsMain[indexPath.item].subCat
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let url = URL(string: arrCatItemsMain[indexPath.item].urlpdf ?? "") else {
            
            var alert = UIAlertView(title: "Error", message: "Invalid Pdf", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
            
            return
        }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
        
        //        if(orderBy == 1){
        //            let   vcOrderDetails = parentViewController?.storyboard?.instantiateViewController(withIdentifier: "OrderDetails") as! OrderDetailsViewController
        //
        //            vcOrderDetails.catId = arrCatItemsMain[indexPath.item].catid ?? 0
        //            vcOrderDetails.divId = arrCatItemsMain[indexPath.item].divisionid ?? 0
        //            vcOrderDetails.catName = arrCatItemsMain[indexPath.item].catnm ?? "Order By Code"
        //
        //            parentViewController?.present(vcOrderDetails, animated: true, completion: nil)
        //        }else{
        //            let vcOrderDetails = parentViewController?.storyboard?.instantiateViewController(withIdentifier: "OrderCatalogueController") as! OrderCatalogueController
        //
        //            vcOrderDetails.catId = arrCatItemsMain[indexPath.item].catid ?? 0
        //            vcOrderDetails.divId = arrCatItemsMain[indexPath.item].divisionid ?? 0
        //            vcOrderDetails.catName = arrCatItemsMain[indexPath.item].catnm ?? "Order By Catalogue"
        //
        //            parentViewController?.present(vcOrderDetails, animated: true, completion: nil)
        //        }
        
    }
    
}

extension TechSpecsRowCell : UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 150, height: 175)
    }
    
}


//class TechSpecsRowCell: UITableViewCell {
//
//
//    @IBOutlet weak var imvTechSpecs: UIImageView!
//    @IBOutlet weak var lblCode: UILabel!
//    @IBOutlet weak var lblName: UILabel!
//
//
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        // Initialization code
//    }
//
//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//
//        // Configure the view for the selected state
//    }
//
//}
