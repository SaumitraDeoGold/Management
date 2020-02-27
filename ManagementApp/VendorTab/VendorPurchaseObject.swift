//
//  VendorPurchaseObject.swift
//  ManagementApp
//
//  Created by Goldmedal on 28/01/20.
//  Copyright © 2020 Goldmedal. All rights reserved.
//

import Foundation
struct VendorPurchaseObject: Codable {
    let result: Bool?
    let message, servertime: String?
    let data: [VendorPurchaseObj]
}

// MARK: - Datum
struct VendorPurchaseObj: Codable {
    let purchaseamt, ledgerbalanceamt: String?
}
