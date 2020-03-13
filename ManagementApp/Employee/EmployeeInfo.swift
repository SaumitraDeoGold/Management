//
//  EmployeeInfo.swift
//  ManagementApp
//
//  Created by Goldmedal on 27/02/20.
//  Copyright © 2020 Goldmedal. All rights reserved.
//

import Foundation
struct EmployeeInfo: Codable {
    let result: Bool?
    let message, servertime: String?
    let data: [EmployeeInfoObj]
}

// MARK: - Datum
struct EmployeeInfoObj: Codable {
    let name, joinDate, dob, department, email, address, empcode: String?
    let designation, location, sublocation, father: String?
    let mother, contactNo, workExp, img: String?
    let ctc, branch: String?
}
