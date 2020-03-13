//
//  EmployeeChild.swift
//  ManagementApp
//
//  Created by Goldmedal on 11/02/20.
//  Copyright © 2020 Goldmedal. All rights reserved.
//

import Foundation
struct EmployeeChild: Codable {
    let result: Bool?
    let message, servertime: String?
    let data: [EmployeeChildObj]
}

// MARK: - Datum
struct EmployeeChildObj: Codable {
    let employeeName, employeeCode, department: String?
    let branchName, joinDate, workYear: String?
    let mobileNumber: String?
    let slno : Int?
}
