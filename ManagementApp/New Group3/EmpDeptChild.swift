//
//  EmpDeptChild.swift
//  ManagementApp
//
//  Created by Goldmedal on 17/02/20.
//  Copyright © 2020 Goldmedal. All rights reserved.
//

import Foundation
struct EmpDeptChild: Codable {
    let result: Bool?
    let message, servertime: String?
    let data: [EmpDeptChildObj]
}

// MARK: - Datum
struct EmpDeptChildObj: Codable {
    let employeeName: String?
    let departmentname: String?
    let designationName, employeeCode: String?
    let branchname, joinDate, workYear: String?
    let mobileNumber: String?
    let slno: Int?
}
