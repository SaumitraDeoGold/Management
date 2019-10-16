//
//  DashboardRegularScheme.swift
//  DealorsApp
//
//  Created by Goldmedal on 8/30/18.
//  Copyright © 2018 Goldmedal. All rights reserved.
//

import Foundation
struct RegularSchemeElement: Codable {
    let result: Bool?
    let message, servertime: String?
    let data: [RegularSchemeData]
}

struct RegularSchemeData: Codable {
    let schemename, netsale, curslab, nextslab: String?
}
