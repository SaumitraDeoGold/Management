//
//  Division.swift
//  DealorsApp
//
//  Created by Goldmedal on 8/30/18.
//  Copyright © 2018 Goldmedal. All rights reserved.
//

import Foundation
struct DivisionElement: Codable {
    let result: Bool?
    let message, servertime: String?
    let data: [DivisionData]
}

struct DivisionData: Codable {
    let slno: Int?
    let divisionnm: String?
}
