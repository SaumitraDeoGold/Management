//
//  ExpenseComparison.swift
//  ManagementApp
//
//  Created by Goldmedal on 03/07/19.
//  Copyright © 2019 Goldmedal. All rights reserved.
//

import Foundation
struct ExpenseComparison: Codable {
    let result: Bool?
    let message, servertime: String?
    let data: [ExpenseComparisonObj]
}
 
struct ExpenseComparisonObj: Codable {
    let branchid, branchnm, salary, otherespenses, sale: String?
}
