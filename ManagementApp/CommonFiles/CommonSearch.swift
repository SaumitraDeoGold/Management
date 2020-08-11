//
//  CommonSearch.swift
//  ManagementApp
//
//  Created by Goldmedal on 26/06/20.
//  Copyright © 2020 Goldmedal. All rights reserved.
//

import Foundation
struct CommonSearch: Codable {
    let result: Bool?
    let message, servertime: String?
    let data: [CommonSearchObj]
}

// MARK: - Datum
struct CommonSearchObj : Codable {
    let name: String?
    let slno: String?
    let id: String?
    
}
