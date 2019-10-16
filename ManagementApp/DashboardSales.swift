//
//  DashboardSales.swift
//  DealorsApp
//
//  Created by Goldmedal on 8/30/18.
//  Copyright © 2018 Goldmedal. All rights reserved.
//

import Foundation
struct SaleElement: Codable {
    let result: Bool?
    let message, servertime: String?
    let data: [sales]
}

struct sales: Codable {
    let lstyearsale, curyearsale: String?
}
