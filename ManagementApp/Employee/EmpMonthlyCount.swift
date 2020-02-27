//
//  EmpMonthlyCount.swift
//  ManagementApp
//
//  Created by Goldmedal on 26/02/20.
//  Copyright © 2020 Goldmedal. All rights reserved.
//

import Foundation
struct EmpMonthlyCount: Codable {
    let result: Bool?
    let message, servertime: String?
    let data: [EmpMonthlyCountObj]
}

// MARK: - Datum
struct EmpMonthlyCountObj: Codable {
    let empCount, leave: Int?
    let month: String?
}
