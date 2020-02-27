//
//  EmpDeptwise.swift
//  ManagementApp
//
//  Created by Goldmedal on 17/02/20.
//  Copyright © 2020 Goldmedal. All rights reserved.
//

import Foundation
struct EmpDeptwise: Codable {
    let result: Bool?
    let message, servertime: String?
    let data: [EmpDeptwiseObj]
}

// MARK: - Datum
struct EmpDeptwiseObj: Codable {
    let departmentId, empCount: Int?
    let departmentName: String?
}
