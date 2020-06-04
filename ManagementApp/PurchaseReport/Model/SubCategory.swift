//
//  SubCategory.swift
//  ManagementApp
//
//  Created by Goldmedal on 24/05/20.
//  Copyright © 2020 Goldmedal. All rights reserved.
//

import Foundation
struct SubCategory: Codable {
    let result: Bool?
    let message, servertime: String?
    let data: [SubCategoryObj]
}

// MARK: - Datum
struct SubCategoryObj: Codable {
    let subcatid: Int?
    let subcatnm: String?
}
