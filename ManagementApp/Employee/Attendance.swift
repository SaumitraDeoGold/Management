//
//  Attendance.swift
//  ManagementApp
//
//  Created by Goldmedal on 23/03/20.
//  Copyright © 2020 Goldmedal. All rights reserved.
//

import Foundation
struct Attendance: Codable {
    let result: Bool?
    let message, servertime: String?
    let data: [AttendanceObj]
}

// MARK: - Datum
struct AttendanceObj: Codable {
    let branchName: String?
    let branchId: Int?
    let salesexecPresent, salesexecAbsent, employeePresent, employeeAbsent: String?
     
}
