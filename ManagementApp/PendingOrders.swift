//
//  PendingOrders.swift
//  ManagementApp
//
//  Created by Goldmedal on 25/04/19.
//  Copyright © 2019 Goldmedal. All rights reserved.
//

import Foundation
struct PendingOrder: Codable {
    let result: Bool?
    let message, servertime: String?
    let data: [PendingOrderObj]
}

struct PendingOrderObj: Codable {
    let branchid, branchnm, salependingqty, salependingamt: String?
    let transferpendingqty, transferpendingamt: String?
}
