//
//  PurSalesLedger.swift
//  ManagementApp
//
//  Created by Goldmedal on 19/05/20.
//  Copyright © 2020 Goldmedal. All rights reserved.
//

import Foundation
struct PurSalesLedger: Codable {
    let result: Bool?
    let message, servertime: String?
    let data: [PurSalesLedgerObj]
}

// MARK: - Datum
struct PurSalesLedgerObj: Codable {
    let purchasePartyName, purchasePartyId, purchasePartyTypeCat, purchaseLedgerAmt: String?
    let saleLedgerAmt, diffrence: String?
}
