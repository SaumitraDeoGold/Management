//
//  SupplierObject.swift
//  ManagementApp
//
//  Created by Goldmedal on 28/01/20.
//  Copyright © 2020 Goldmedal. All rights reserved.
//

import Foundation
struct SupplierObject: Codable {
    let result: Bool?
    let message, servertime: String?
    let data: [SupplierObj]
}

// MARK: - Datum
struct SupplierObj: Codable {
    let purchaseamt, ledgerbalanceamt: String?
}
