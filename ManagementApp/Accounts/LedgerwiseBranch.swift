//
//  LedgerwiseBranch.swift
//  ManagementApp
//
//  Created by Goldmedal on 07/12/19.
//  Copyright © 2019 Goldmedal. All rights reserved.
//

import Foundation
struct LedgerwiseBranch: Codable {
    let result: Bool?
    let message, servertime: String?
    let data: [LedgerwiseBranchObj]
}

// MARK: - Datum
struct LedgerwiseBranchObj: Codable {
    let branchid, branchnm, amount: String?
}
