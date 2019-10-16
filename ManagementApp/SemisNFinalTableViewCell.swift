//
//  SemisNFinalTableViewCell.swift
//  DealorsApp
//
//  Created by Goldmedal on 4/15/19.
//  Copyright © 2019 Goldmedal. All rights reserved.
//

import UIKit

class SemisNFinalTableViewCell: UITableViewCell {

    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var arrTeamDataMain = [GetAllTeamObj]()
    var arrFlag = [FlagData]()
    var selectedRowIndex = -1
   
    func updateCellWith(teamData:[GetAllTeamObj],arrFlag:[FlagData]) {
        self.arrTeamDataMain = teamData
        self.arrFlag = arrFlag
        self.collectionView.allowsMultipleSelection = false
        self.collectionView.reloadData()
    }
    
    
}


extension SemisNFinalTableViewCell : UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if arrTeamDataMain.count > 0{
            return arrTeamDataMain.count
        }else{
            return 0
        }
        
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SemisNFinalCell", for: indexPath) as! SemisNFinalCell
     
        if cell.isSelected{
            cell.layer.borderWidth = 5.0
            cell.layer.borderColor = UIColor.green.cgColor
        }else{
            cell.layer.borderWidth = 0
            cell.layer.borderColor = UIColor.white.cgColor
            
        }
        
        cell.imvTeamFlag.image = UIImage(named:arrFlag[indexPath.item].flag ?? "")
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
       
        cell?.layer.borderWidth = 5.0
        cell?.layer.borderColor = UIColor.green.cgColor
        
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
   
        cell?.layer.borderWidth = 0
        cell?.layer.borderColor = UIColor.white.cgColor
        
    }
  
    
}

extension SemisNFinalTableViewCell : UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
     
        return CGSize(width: 120, height: 120)
    }
    
}
