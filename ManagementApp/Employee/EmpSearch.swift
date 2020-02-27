//
//  EmpSearch.swift
//  ManagementApp
//
//  Created by Goldmedal on 27/02/20.
//  Copyright © 2020 Goldmedal. All rights reserved.
//

import Foundation
struct EmpSearch: Codable {
    let result: Bool?
    let message, servertime: String?
    let data: [EmpSearchObj]
}

// MARK: - Datum
struct EmpSearchObj: Codable {
    let slno: Int?
    let name: String?
}
