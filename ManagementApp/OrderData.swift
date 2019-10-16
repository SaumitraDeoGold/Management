//
//  OrderData.swift
//  DealorsApp
//
//  Created by Goldmedal on 11/15/18.
//  Copyright © 2018 Goldmedal. All rights reserved.
//

import Foundation
struct OrderElement: Codable {
    let result: Bool?
    let message, servertime: String?
    let data: [OrderData]
}

struct OrderData: Codable {
    let divisionid: Int?
    let catid: Int?
    let catnm, catimage,divisionnm: String?
}

