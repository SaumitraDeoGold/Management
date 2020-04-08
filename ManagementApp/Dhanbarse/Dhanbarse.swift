//
//  Dhanbarse.swift
//  ManagementApp
//
//  Created by Goldmedal on 02/04/20.
//  Copyright © 2020 Goldmedal. All rights reserved.
//

import Foundation
struct Dhanbarse: Codable {
    let result: Bool?
    let message, servertime: String?
    let data: [DhanbarseObj]
}

// MARK: - Datum
struct DhanbarseObj : Codable {
    let stateName: String?
    let stateId, retailer, electrician, counterBoy: Int?
}
