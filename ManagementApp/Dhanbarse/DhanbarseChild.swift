//
//  DhanbarseChild.swift
//  ManagementApp
//
//  Created by Goldmedal on 03/04/20.
//  Copyright © 2020 Goldmedal. All rights reserved.
//

import Foundation
struct DhanbarseChild: Codable {
    let result: Bool?
    let message, servertime: String?
    let data: [DhanbarseChildObj]
}

// MARK: - Datum
struct DhanbarseChildObj: Codable {
    let stateName: String?
    let aprRetailer, aprElectrician, aprCounterBoy, penRetailer: Int?
    let penElectrician, penCounterBoy, rejRetailer, rejElectrician: Int?
    let rejCounterBoy: Int?
}
