//
//  DhanMonthwise.swift
//  ManagementApp
//
//  Created by Goldmedal on 05/04/20.
//  Copyright © 2020 Goldmedal. All rights reserved.
//

import Foundation
struct DhanMonthwise: Codable {
    let result: Bool?
    let message, servertime: String?
    let data: [DhanMonthwiseObj]
}

// MARK: - Datum
struct DhanMonthwiseObj: Codable {
    let month: String?
    let retailer, electrician, counterBoy: Int?
}
