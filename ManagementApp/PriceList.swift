//
//  PriceList.swift
//  DealorsApp
//
//  Created by Goldmedal on 8/30/18.
//  Copyright © 2018 Goldmedal. All rights reserved.
//

import Foundation

struct PriceListElement: Decodable {
    let result: Bool?
    let message, servertime: String?
    let data: [PriceListData]
}

struct PriceListData: Decodable {
    let pricelistdata: [PricelistObject]
    let ismore: Bool?
}

struct PricelistObject: Decodable {
    let brandName, rangeName, fromDate, toDate, imgurl: String?
    let fileURL: String?
}
