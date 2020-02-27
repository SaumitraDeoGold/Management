//
//  SearchSupplier.swift
//  ManagementApp
//
//  Created by Goldmedal on 25/01/20.
//  Copyright © 2020 Goldmedal. All rights reserved.
//

import Foundation
struct SearchSupplier: Codable {
    let result: Bool?
    let message, servertime: String?
    let data: [SearchSupplierObj]?
}

// MARK: - Datum
struct SearchSupplierObj: Codable {
    let slno, suppliernm, code: String?
}
