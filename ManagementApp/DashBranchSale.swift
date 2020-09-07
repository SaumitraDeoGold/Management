//
//  DashBranchSale.swift
//  ManagementApp
//
//  Created by Goldmedal on 14/06/19.
//  Copyright © 2019 Goldmedal. All rights reserved.
//

import Foundation
struct DashBranch: Codable {
    let result: Bool?
    let message, servertime: String?
    let data: [DashBranchObj]
}

// MARK: - Datum
struct DashBranchObj: Codable {
    let branchnm, amount, payment: String?
}
