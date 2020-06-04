//
//  RateComparison.swift
//  ManagementApp
//
//  Created by Goldmedal on 27/05/20.
//  Copyright © 2020 Goldmedal. All rights reserved.
//

import Foundation
struct RateComparison: Codable {
    let result: Bool?
    let message, servertime: String?
    let data: [RateComparisonObj]
}

// MARK: - Datum
struct RateComparisonObj: Codable {
    let itemCode, itemName, party, partyId: String?
    let partyType: String?
    let mrp, comparison: String?
}

 
