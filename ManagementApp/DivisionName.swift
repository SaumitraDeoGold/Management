//
//  DivisionName.swift
//  ManagementApp
//
//  Created by Goldmedal on 12/11/19.
//  Copyright © 2019 Goldmedal. All rights reserved.
//

import Foundation
struct DivisionName: Codable {
    let result: Bool?
    let message, servertime: String?
    let data: [DivisionNameObj]
}

// MARK: - Datum
struct DivisionNameObj: Codable {
    let slno: Int?
    let divisioncode, divisionnm: String?
}
