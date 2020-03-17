//
//  ExpenseBill.swift
//  ManagementApp
//
//  Created by Goldmedal on 14/03/20.
//  Copyright © 2020 Goldmedal. All rights reserved.
//

import Foundation

struct ExpenseBill: Codable {
    let result: Bool?
    let message, servertime: String?
    let data: [ExpenseBillData]
}

// MARK: - Datum
struct ExpenseBillData: Codable {
    let expenseChilddata: [ExpenseBillObj]
    let ismore: Bool?
}

// MARK: - ExpenseChilddatum
struct ExpenseBillObj: Codable {
    let branch: String?
    let supplierName, ledgerName, voucherNo, date: String?
    let amount, narration: String?
    let paymentmode: String?
    let type: String?
    let link: String?
    let slno: Int?
}
