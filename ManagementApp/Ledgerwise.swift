//
//  Ledgerwise.swift
//  ManagementApp
//
//  Created by Goldmedal on 04/12/19.
//  Copyright © 2019 Goldmedal. All rights reserved.
//

import Foundation
struct Ledgerwise: Codable {
    let result: Bool?
    let message, servertime: String?
    let data: [LedgerwiseObj]
}

// MARK: - Datum
struct LedgerwiseObj: Codable {
    let ledgerid, headnm, amount, sale: String?
}
