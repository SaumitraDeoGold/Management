//
//  PurchasePartyLedgerLayout.swift
//  ManagementApp
//
//  Created by Goldmedal on 17/06/20.
//  Copyright © 2020 Goldmedal. All rights reserved.
//

import Foundation
import UIKit

class PurchasePartyLedgerLayout: UICollectionViewLayout {
    
    var numberOfColumns = 4
    var shouldPinFirstColumn = true
    var shouldPinFirstRow = true
    fileprivate var cache = [UICollectionViewLayoutAttributes]()
    var itemAttributes = [[UICollectionViewLayoutAttributes]]()
    var itemsSize = [CGSize]()
    var contentSize: CGSize = .zero
    
    
    
    override func prepare() {
        
        guard cache.isEmpty == true, let collectionView = collectionView else {
            return
        }
        
        if collectionView.numberOfSections == 0 {
            return
        }
        numberOfColumns = collectionView.numberOfItems(inSection: 1)
        itemAttributes = []
        if itemAttributes.count != collectionView.numberOfSections {
            generateItemAttributes(collectionView: collectionView)
            return
        }
        
        for section in 0..<collectionView.numberOfSections {
            for item in 0..<collectionView.numberOfItems(inSection: section) {
                if section != 0 && item != 0 {
                    continue
                }
                
                let attributes = layoutAttributesForItem(at: IndexPath(item: item, section: section))!
                if section == 0 {
                    var frame = attributes.frame
                    frame.origin.y = collectionView.contentOffset.y
                    attributes.frame = frame
                }
                
                if item == 0 {
                    var frame = attributes.frame
                    frame.origin.x = collectionView.contentOffset.x
                    attributes.frame = frame
                }
            }
        }
        
    }
    
    
    
    override var collectionViewContentSize: CGSize {
        return contentSize
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return itemAttributes[indexPath.section][indexPath.row]
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var attributes = [UICollectionViewLayoutAttributes]()
        for section in itemAttributes {
            let filteredArray = section.filter { obj -> Bool in
                return rect.intersects(obj.frame)
            }
            
            attributes.append(contentsOf: filteredArray)
        }
        
        return attributes
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
}



// MARK: - Helpers
extension PurchasePartyLedgerLayout {
    
    func generateItemAttributes(collectionView: UICollectionView) {
        if itemsSize.count != numberOfColumns {
            calculateItemSizes()
        }
        
        var column = 0
        var xOffset: CGFloat = 0
        var yOffset: CGFloat = 0
        var contentWidth: CGFloat = 0
        
        itemAttributes = []
        
        for section in 0..<collectionView.numberOfSections {
            var sectionAttributes: [UICollectionViewLayoutAttributes] = []
            
            for index in 0..<numberOfColumns {
                let itemSize = itemsSize[index]
                let indexPath = IndexPath(item: index, section: section)
                let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                attributes.frame = CGRect(x: xOffset, y: yOffset, width: itemSize.width, height: itemSize.height).integral
                
                if section == 0 && index == 0 {
                    // First cell should be on top
                    attributes.zIndex = 1024
                } else if section == 0 || index == 0 {
                    // First row/column should be above other cells
                    attributes.zIndex = 1023
                }
                
                if section == 0 {
                    var frame = attributes.frame
                    frame.origin.y = collectionView.contentOffset.y
                    attributes.frame = frame
                }
                if index == 0 {
                    var frame = attributes.frame
                    frame.origin.x = collectionView.contentOffset.x
                    attributes.frame = frame
                }
                
                sectionAttributes.append(attributes)
                
                xOffset += itemSize.width
                column += 1
                
                if column == numberOfColumns {
                    if xOffset > contentWidth {
                        contentWidth = xOffset
                    }
                    
                    column = 0
                    xOffset = 0
                    yOffset += itemSize.height
                }
            }
            
            itemAttributes.append(sectionAttributes)
        }
        
        if let attributes = itemAttributes.last?.last {
            contentSize = CGSize(width: contentWidth, height: attributes.frame.maxY)
        }
    }
    
    func calculateItemSizes() {
        itemsSize = []
        
        for index in 0..<numberOfColumns {
            itemsSize.append(sizeForItemWithColumnIndex(index))
        }
    }
    
    func sizeForItemWithColumnIndex(_ columnIndex: Int) -> CGSize {
        let screenWidth = UIScreen.main.bounds.width
        var width = 0
        if numberOfColumns == 4{
            switch columnIndex {
            case 0:
                width = 130
            case 1:
                width = 90
            case 2:
                width = 90
            case 3:
                width = 90
                
            default:
                width = Int((screenWidth/3)-1)
            }
        }else if numberOfColumns == 2{
            switch columnIndex {
            case 0:
                width = Int((screenWidth/2)-1)
            case 1:
                width = Int((screenWidth/2)-1)
                
            default:
                width = Int((screenWidth/3)-1)
            }
        }else if numberOfColumns == 7{
            switch columnIndex {
            case 0:
                width = Int((screenWidth/3)-1)
            case 1:
                width = Int((screenWidth/2)-1)
            case 2:
                width = Int((screenWidth/2)-1)
            case 3:
                width = Int((screenWidth/3)-1)
                
            default:
                width = Int((screenWidth/3)-1)
            }
        }else if numberOfColumns == 6{
            switch columnIndex {
            case 0:
                width = 130
            case 1:
                width = Int((screenWidth/2)-1)
            default:
                width = 100
            }
        }else{
            switch columnIndex {
            case 0:
                width = 130
            case 1:
                width = Int((screenWidth/2)-1)
            case 2:
                width = Int((screenWidth/2)-1)
                
            default:
                width = Int((screenWidth/2)-1)
            }
        }
        
        //let size: CGSize = text.size(withAttributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14.0)])
        //let width: CGFloat = 130
        return CGSize(width: width, height: 45)
    }
    
}
