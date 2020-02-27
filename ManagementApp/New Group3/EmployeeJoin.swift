//
//  EmployeeJoin.swift
//  ManagementApp
//
//  Created by Goldmedal on 17/02/20.
//  Copyright © 2020 Goldmedal. All rights reserved.
//

import Foundation 
struct EmployeeJoins: Codable {
    let result: Bool?
    let message, servertime: String?
    let data: [EmployeeJoinObj]
}

// MARK: - Datum
struct EmployeeJoinObj: Codable {
    let monthCount, yearCount: Int?
}
