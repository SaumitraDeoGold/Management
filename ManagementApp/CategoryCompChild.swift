//
//  CategoryCompChild.swift
//  ManagementApp
//
//  Created by Goldmedal on 28/11/19.
//  Copyright © 2019 Goldmedal. All rights reserved.
//

import Foundation
struct CategoryCompChild: Codable {
    let result: Bool?
    let message, servertime: String?
    let data: [CategoryCompChildObj]
}

// MARK: - Datum
struct CategoryCompChildObj: Codable {
    let slno: Int?
    let branchnm, currentyearsaleamt, lastyearssaleamt: String?
}
