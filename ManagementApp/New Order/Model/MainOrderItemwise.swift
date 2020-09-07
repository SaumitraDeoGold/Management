//
//  MainOrderItemwise.swift
//  ManagementApp
//
//  Created by Goldmedal on 22/07/20.
//  Copyright © 2020 Goldmedal. All rights reserved.
//

import Foundation
struct MainOrderItemwise: Codable {
    let result: Bool?
    let message, servertime: String?
    let data: [MainOrderItemwiseObj]
}

// MARK: - Datum
struct MainOrderItemwiseObj: Codable {
    let subCatId: String?
    let subCat, dispatchFrom, color : String?
    let itemId, itemName, qty, amount: String?
    let pendingsince, ponum: String?
}
