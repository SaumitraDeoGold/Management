//
//  Catalogue.swift
//  DealorsApp
//
//  Created by Goldmedal on 8/30/18.
//  Copyright © 2018 Goldmedal. All rights reserved.
//

import Foundation
struct CatalogueElement: Decodable {
    let result: Bool?
    let message, servertime: String?
    let data: [CatalogueData]
}

struct CatalogueData: Decodable {
    let pricelistdata: [CatalogueObject]
    let ismore: Bool?
}

struct CatalogueObject: Decodable {
    let brandName, rangeName, fromDate, toDate, imgurl: String?
    let fileURL: String?
}
