//
//  BranchwiseOrders.swift
//  ManagementApp
//
//  Created by Goldmedal on 26/04/19.
//  Copyright © 2019 Goldmedal. All rights reserved.
//

import Foundation
struct BranchwiseOrders: Codable {
    let result: Bool?
    let message, servertime: String?
    let data: [BranchwiseOrdersObj]
}

struct BranchwiseOrdersObj: Codable {
    let itemnm, qty, amount: String?
}
