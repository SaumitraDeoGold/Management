//
//  LocationAttendance.swift
//  ManagementApp
//
//  Created by Goldmedal on 24/03/20.
//  Copyright © 2020 Goldmedal. All rights reserved.
//

import Foundation
struct LocationAttendance: Codable {
    let result: Bool?
    let message, servertime: String?
    let data: [LocationAttendanceObj]
}

// MARK: - Datum
struct LocationAttendanceObj: Codable {
    let locationName: String?
    let locationId: Int?
    let salesexecPresent, salesexecAbsent, employeePresent, employeeAbsent: String? 
}
