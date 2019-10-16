//
//  OrderSummary.swift
//  DealorsApp
//
//  Created by Goldmedal on 12/1/18.
//  Copyright © 2018 Goldmedal. All rights reserved.
//

import Foundation
struct OrderSummaryElement: Codable {
    let result: Bool?
    let message, servertime: String?
    let data: [OrderSummaryObj]
}

struct OrderSummaryObj: Codable {
    let ponum, podt, potime, amount: String?
    let logstatus: String?
    let orderurl,byWeb: String?
}


