//
//  EmpJoinLeave.swift
//  ManagementApp
//
//  Created by Goldmedal on 18/02/20.
//  Copyright © 2020 Goldmedal. All rights reserved.
//

import Foundation
struct EmpJoinLeave: Codable {
    let result: Bool?
    let message, servertime: String?
    let data: [EmpJoinLeaveObj]
}

// MARK: - Datum
struct EmpJoinLeaveObj: Codable {
    let employeeName, employeeCode, mobileNumber, departmentName: String?
    let designationName, branchname, joinDate, workYear: String?
    let slno: Int?
}
