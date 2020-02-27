//
//  EmpLocation.swift
//  ManagementApp
//
//  Created by Goldmedal on 25/02/20.
//  Copyright © 2020 Goldmedal. All rights reserved.
//

import Foundation
struct EmpLocation: Codable {
    let result: Bool?
    let message, servertime: String?
    let data: [EmpLocationObj]
}

// MARK: - Datum
struct EmpLocationObj: Codable {
    let employeeCount, internalEmpCount, execCount, locationId: Int?
    let locationName: String? 
}
