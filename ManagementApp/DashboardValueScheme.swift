//
//  DashboardValueScheme.swift
//  DealorsApp
//
//  Created by Goldmedal on 8/30/18.
//  Copyright © 2018 Goldmedal. All rights reserved.
//

import Foundation

struct ValueSchemeElement: Codable {
    let result: Bool?
    let message, servertime: String?
    let data: [ValueSchemeData]
}

struct ValueSchemeData: Codable {
    let schemename, netsale, curslab, nextslab: String?
}
