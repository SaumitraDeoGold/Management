//
//  SearchVendor.swift
//  ManagementApp
//
//  Created by Goldmedal on 25/01/20.
//  Copyright © 2020 Goldmedal. All rights reserved.
//

import Foundation

struct SearchVendor: Codable {
    let result: Bool?
    let message, servertime: String?
    let data: [SearchVendorObj]?
}


struct SearchVendorObj: Codable {
    let slno, vendornm, code: String?
}
