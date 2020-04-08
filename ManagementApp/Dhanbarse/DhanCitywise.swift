//
//  DhanCitywise.swift
//  ManagementApp
//
//  Created by Goldmedal on 05/04/20.
//  Copyright © 2020 Goldmedal. All rights reserved.
//

import Foundation
struct DhanCitywise: Codable {
    let result: Bool?
    let message, servertime: String?
    let data: [DhanCitywiseObj]
}

// MARK: - Datum
struct DhanCitywiseObj: Codable {
    let city: String?
    let retailer, electrician, counterBoy: Int?
}
