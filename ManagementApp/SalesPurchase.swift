//
//  SalesPurchase.swift
//  ManagementApp
//
//  Created by Goldmedal on 26/04/19.
//  Copyright © 2019 Goldmedal. All rights reserved.
//

import Foundation
struct SalesPurchase: Codable {
    let result: Bool?
    let message, servertime: String?
    let data: [SalesPurchaseObj]
}

struct SalesPurchaseObj: Codable {
    let branchid, branchnm, salewithtaxamt, salewithouttaxamt: String?
    let payment, creditnote, debitnote, outstandingamt: String?
    let stockamt, purchaseamt: String?
}
