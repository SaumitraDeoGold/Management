//
//  EmployeeData.swift
//  ManagementApp
//
//  Created by Goldmedal on 11/02/20.
//  Copyright © 2020 Goldmedal. All rights reserved.
//

import Foundation
struct EmployeeData: Codable {
    let result: Bool?
    let message, servertime: String?
    let data: [EmployeeDataObj]
}

// MARK: - Datum
struct EmployeeDataObj: Codable {
    let employeeCount, branchId, internalEmpCount, execCount: Int?
    let branchName: String?
}
 
