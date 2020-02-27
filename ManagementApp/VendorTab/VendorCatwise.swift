//
//  VendorCatwise.swift
//  ManagementApp
//
//  Created by Goldmedal on 15/02/20.
//  Copyright © 2020 Goldmedal. All rights reserved.
//

import Foundation
struct VendorCatwise: Codable {
    let result: Bool?
    let message, servertime: String?
    let data: [VendorCatwiseObj]
}

// MARK: - Datum
struct VendorCatwiseObj: Codable {
    let categoryId: Int?
    let categoryName: String?
    let amount: Double?
    
}
