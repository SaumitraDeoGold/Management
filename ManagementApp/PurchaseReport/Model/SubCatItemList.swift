//
//  SubCatItemList.swift
//  ManagementApp
//
//  Created by Goldmedal on 27/05/20.
//  Copyright © 2020 Goldmedal. All rights reserved.
//

import Foundation
struct SubCatItemList: Codable {
    let result: Bool?
    let message, servertime: String?
    let data: [SubCatItemListObj]
}

// MARK: - Datum
struct SubCatItemListObj: Codable {
    let slno: Int?
    let item: String?
}
