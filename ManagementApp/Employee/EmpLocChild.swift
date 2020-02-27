//
//  EmpLocChild.swift
//  ManagementApp
//
//  Created by Goldmedal on 25/02/20.
//  Copyright © 2020 Goldmedal. All rights reserved.
//

import Foundation
struct EmpLocChild: Codable {
    let result: Bool?
    let message, servertime: String?
    let data: [EmpLocChildObj]
}

// MARK: - Datum
struct EmpLocChildObj: Codable {
    let employeeName, employeeCode, department, branchName: String?
    let mobileNumber, joinDate, workYear, sublocation: String?
}
