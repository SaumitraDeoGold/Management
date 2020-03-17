//
//  SupplierLedger.swift
//  ManagementApp
//
//  Created by Goldmedal on 16/03/20.
//  Copyright © 2020 Goldmedal. All rights reserved.
//

import Foundation
struct SupplierLedger: Codable {
    let result: Bool?
    let message, servertime: String?
    let data: [SupplierLedgerObj]
}

// MARK: - Datum
struct SupplierLedgerObj: Codable {
    let ledger: [Ledger]
    let supplier:[Supplier]
}

// MARK: - Ledger
struct Ledger: Codable {
    let name: String?
}

struct Supplier: Codable {
    let name: String?
}
