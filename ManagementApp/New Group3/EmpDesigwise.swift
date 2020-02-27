//
//  EmpDesigwise.swift
//  ManagementApp
//
//  Created by Goldmedal on 17/02/20.
//  Copyright © 2020 Goldmedal. All rights reserved.
//

import Foundation
struct EmpDesigwise: Codable {
    let result: Bool?
    let message, servertime: String?
    let data: [EmpDesigwiseObj]
}

// MARK: - Datum
struct EmpDesigwiseObj: Codable {
    let designationId, empCount: Int?
    let designationName: String?
}
