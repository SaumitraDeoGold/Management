//
//  Categorywise.swift
//  ManagementApp
//
//  Created by Goldmedal on 26/11/19.
//  Copyright © 2019 Goldmedal. All rights reserved.
//

import Foundation
struct Categorywise: Codable {
    let result: Bool?
    let message, servertime: String?
    let data: [CategorywiseObj]
}

// MARK: - Datum
struct CategorywiseObj: Codable {
    let slno: Int?
    let categorynm, currentyearsaleamt, lastyearssaleamt: String?
}
