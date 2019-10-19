//
//  DashboardGroupScheme.swift
//  DealorsApp
//
//  Created by Goldmedal on 8/30/18.
//  Copyright © 2018 Goldmedal. All rights reserved.
//

import Foundation

struct GroupSchemeElement: Codable {
    let result: Bool?
    let message, servertime: String?
    let data: [GroupSchemeData]
}

struct GroupSchemeData: Codable {
    let schemename, netsale, curslab, nextslab: String?
}