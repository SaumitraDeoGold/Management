//
//  ProductSellingView.swift
//  DealorsApp
//
//  Created by Goldmedal on 5/25/18.
//  Copyright © 2018 Goldmedal. All rights reserved.
//

import UIKit

class ProductSellingView: UICollectionView , UICollectionViewDelegate  {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
}
