//
//  StockDetails.swift
//  ManagementApp
//
//  Created by Goldmedal on 25/04/19.
//  Copyright © 2019 Goldmedal. All rights reserved.
//

import Foundation

struct StockDetails: Codable {
    let result: Bool?
    let message, servertime: String?
    let data: [StockDetailsObj]
}

struct StockDetailsObj: Codable {
    let itmecode, itemnm, colornm, rangenm: String?
    let categorynm: String?
    let productcode: String?
    let divisionnm: String?
    let stockamt, stockqty, date: String?
}
