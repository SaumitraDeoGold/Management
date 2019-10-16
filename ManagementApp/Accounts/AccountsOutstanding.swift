//
//  AccountsOutstanding.swift
//  ManagementApp
//
//  Created by Goldmedal on 14/05/19.
//  Copyright © 2019 Goldmedal. All rights reserved.
//

import Foundation
struct AccountsOutstanding: Codable {
    let result: Bool?
    let message, servertime: String?
    let data: [AccountsOutstandingObj]
}

struct AccountsOutstandingObj: Codable {
    let branchid, branchnm, outstandingamt: String?
}
