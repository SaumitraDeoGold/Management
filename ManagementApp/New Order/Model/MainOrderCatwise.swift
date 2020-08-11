//
//  MainOrderCatwise.swift
//  ManagementApp
//
//  Created by Goldmedal on 22/07/20.
//  Copyright © 2020 Goldmedal. All rights reserved.
//

import Foundation
struct MainOrderCatwise: Codable {
    let result: Bool?
    let message, servertime: String?
    let data: [MainOrderCatwiseObj]
}

// MARK: - Datum
struct MainOrderCatwiseObj: Codable {
    let divisionId, division, categoryId, category: String?
    let amount: String? 
}
