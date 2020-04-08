//
//  LocAttendanceChild.swift
//  ManagementApp
//
//  Created by Goldmedal on 26/03/20.
//  Copyright © 2020 Goldmedal. All rights reserved.
//

import Foundation
struct LocAttendanceChild: Codable {
    let result: Bool?
    let message, servertime: String?
    let data: [LocAttendanceChildObj]
}

// MARK: - Datum
struct LocAttendanceChildObj: Codable {
    let employeeslno, employeeCode, employeeName, departmentname, designationName: String?
    let location, subLocation, branchname, dob: String?
    let address, datumIn, intime, out, dueration: String?
    let mobileNumber, joinDate, workYear, fatehr: String?
    let mother, email: String?
}
