//
//  DistrictwiseDhan.swift
//  ManagementApp
//
//  Created by Goldmedal on 03/04/20.
//  Copyright © 2020 Goldmedal. All rights reserved.
//

import Foundation
struct DistrictwiseDhan: Codable {
    let result: Bool?
    let message, servertime: String?
    let data: [DistrictwiseDhanObj]
}

// MARK: - Datum
struct DistrictwiseDhanObj: Codable {
    let district: String?
    let districtId, retailer, electrician, counterBoy: Int?
}
