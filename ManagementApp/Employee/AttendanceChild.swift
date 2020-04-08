//
//  AttendanceChild.swift
//  ManagementApp
//
//  Created by Goldmedal on 25/03/20.
//  Copyright © 2020 Goldmedal. All rights reserved.
//

import Foundation
struct AttendanceChild: Codable {
    let result: Bool?
    let message, servertime: String?
    let data: [AttendanceChildObj]
}

// MARK: - Datum
struct AttendanceChildObj: Codable {
    let employeeCode, employeeslno, employeeName, departmentname, designationName: String?
    let location, subLocation, branchname, dob: String?
    let address, datumIn, inTime, out, dueration: String?
    let mobileNumber, joinDate, workYear, fatehr: String?
    let mother, email: String? 
}
