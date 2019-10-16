//
//  Category.swift
//  ManagementApp
//
//  Created by Goldmedal on 03/10/19.
//  Copyright © 2019 Goldmedal. All rights reserved.
//

import Foundation
struct Category: Codable {
    let result: Bool?
    let message, servertime: String?
    let data: [CategoryObj]
}

// MARK: - Datum
struct CategoryObj: Codable {
    let name, userid, usertype: String
}
