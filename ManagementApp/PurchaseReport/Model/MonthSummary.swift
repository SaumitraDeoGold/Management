//
//  MonthSummary.swift
//  ManagementApp
//
//  Created by Goldmedal on 26/05/20.
//  Copyright © 2020 Goldmedal. All rights reserved.
//

import Foundation
struct MonthSummary: Codable {
    let result: Bool?
    let message, servertime: String?
    let data: [MonthSummaryObj]
}

// MARK: - Datum
struct MonthSummaryObj: Codable {
    let itemCode, itemName: String?
    let unit: String?
    let openingBal, totalOrder, totalReceived, bal: String?
 
}
 
