//
//  DhanDisChild.swift
//  ManagementApp
//
//  Created by Goldmedal on 05/04/20.
//  Copyright © 2020 Goldmedal. All rights reserved.
//

import Foundation
struct DhanDisChild: Codable {
    let result: Bool?
    let message, servertime: String?
    let data: [DhanDisChildObj]
}

// MARK: - Datum
struct DhanDisChildObj: Codable {
    let districtName: String?
    let aprRetailer, aprElectrician, aprCounterBoy, penRetailer: Int?
    let penElectrician, penCounterBoy, rejRetailer, rejElectrician: Int?
    let rejCounterBoy: Int?
}
