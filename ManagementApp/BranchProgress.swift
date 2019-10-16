
//
//  BranchProgress.swift
//  ManagementApp
//
//  Created by Goldmedal on 17/04/19.
//  Copyright © 2019 Goldmedal. All rights reserved.
//

import Foundation
struct BranchProgress: Codable {
    let result: Bool?
    let message, servertime: String?
    let data: [BranchProgressObj]
}

struct BranchProgressObj: Codable {
    let branchid, branchnm, currentyearsale, previousyearsale: String
    let previoustwoyearsale: String
}
