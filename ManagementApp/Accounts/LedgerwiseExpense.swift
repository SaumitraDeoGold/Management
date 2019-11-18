//
//  LedgerwiseExpense.swift
//  ManagementApp
//
//  Created by Goldmedal on 11/11/19.
//  Copyright © 2019 Goldmedal. All rights reserved.
//

import Foundation
struct LedgerwiseExpense: Codable {
    let result: Bool
    let message, servertime: String
    let data: [LedgerwiseExpenseObj]
}

// MARK: - Datum
struct LedgerwiseExpenseObj: Codable {
    let name, amount: String?
}
