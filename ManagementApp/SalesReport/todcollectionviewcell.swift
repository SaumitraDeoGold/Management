//
//  todcollectionviewcell.swift
//  ManagementApp
//
//  Created by Goldmedal on 29/06/20.
//  Copyright © 2020 Goldmedal. All rights reserved.
//

import Foundation

class DefaultCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var infoLabel: UILabel!
}

class SpreadsheetCollectionReusableView: UICollectionReusableView {
    @IBOutlet weak var infoLabel: UILabel!
    
    @IBOutlet weak var btnPartyText: UIButton!
    
    
    @IBOutlet weak var adjustmentButton: UIButton!
    
    @IBOutlet weak var pdfButton: UIButton!
    
    
    weak var headerDelegate: YourHeaderViewDelegate?
    
    @IBAction func partyTapped(sender: UIButton) {
        
        headerDelegate?.showPartyDetail!(index : sender.tag)
        
    }
    
    @IBAction func pdfTapped(sender: UIButton) {
        
        headerDelegate?.showPdfWithCIN!(index : sender.tag)
        
    }
    
    
    @IBAction func adjustmentTapped(sender: UIButton) {
        
        headerDelegate?.showPdfWithCIN!(index : sender.tag)
        
    }
    
    
    
    
    
}
