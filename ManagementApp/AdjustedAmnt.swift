//
//  AdjustedAmnt.swift
//  DealorsApp
//
//  Created by Goldmedal on 8/30/18.
//  Copyright © 2018 Goldmedal. All rights reserved.
//

import Foundation

struct AdjustedAmntElement: Codable {
    let result: Bool?
    let message, servertime: String?
    let data: [AdjustedAmntArray]
}

struct AdjustedAmntArray: Codable {
    let invoice, invoiceDate, type, amount, adjustedAmount: String?
}
