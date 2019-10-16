//
//  BranchWisePayment.swift
//  G-Management
//
//  Created by Goldmedal on 22/02/19.
//  Copyright © 2019 Goldmedal. All rights reserved.
//

import Foundation
struct BranchWisePayment: Codable {
    let result: Bool?
    let message, servertime: String?
    let data: [BranchPay]?
}

struct BranchPay: Codable {
    let branchid, branchnm, payment, totalpayment, contribution: String?
}
