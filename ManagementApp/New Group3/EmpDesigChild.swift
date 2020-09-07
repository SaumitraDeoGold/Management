
//
//  EmpDesigChild.swift
//  ManagementApp
//
//  Created by Goldmedal on 17/02/20.
//  Copyright © 2020 Goldmedal. All rights reserved.
//

import Foundation
struct EmpDesigChild: Codable {
    let result: Bool?
    let message, servertime: String?
    let data: [EmpDesigChildObj]
}

// MARK: - Datum
struct EmpDesigChildObj: Codable {
    let employeeName, departmentname, designationName, employeeCode, location: String?
    let branchname, mobileNumber, joinDate, workYear: String?
    let slno: Int?
}
