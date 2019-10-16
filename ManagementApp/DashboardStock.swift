//
//  DashboardStock.swift
//  ManagementApp
//
//  Created by Goldmedal on 16/04/19.
//  Copyright © 2019 Goldmedal. All rights reserved.
//

import Foundation
struct Stock: Codable {
    let result: Bool?
    let message, servertime: String?
    let data: [StockObj]
}

struct StockObj: Codable {
    let branchid, branchnm, stockamt: String?
    let asondt: String?
    let slab30, slab60, slab90, slab120: String?
    let slab150, slab180, slab200: String?
}
