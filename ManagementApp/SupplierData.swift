//
//  SupplierData.swift
//  ManagementApp
//
//  Created by Goldmedal on 06/12/19.
//  Copyright © 2019 Goldmedal. All rights reserved.
//

import Foundation
struct SupplierData: Codable {
    let result: Bool?
    let message, servertime: String?
    let data: [SupplierDataObj]
}

// MARK: - Datum
struct SupplierDataObj: Codable {
    let name, amount, link: String?
}
