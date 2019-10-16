//
//  SearchDealers.swift
//  ManagementApp
//
//  Created by Goldmedal on 07/06/19.
//  Copyright © 2019 Goldmedal. All rights reserved.
//

import Foundation

struct SearchDealers: Codable {
    let result: Bool?
    let message, servertime: String?
    let data: [SearchDealersObj]?
}

struct SearchDealersObj: Codable {
    let slno, dealernm, cin: String?
}
