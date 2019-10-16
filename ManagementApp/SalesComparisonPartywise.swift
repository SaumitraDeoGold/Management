//
//  SalesComparisonPartywise.swift
//  ManagementApp
//
//  Created by Goldmedal on 31/05/19.
//  Copyright © 2019 Goldmedal. All rights reserved.
//

import Foundation
struct PartywiseComparison: Codable {
    let result: Bool?
    let message, servertime: String?
    let data: [PartywiseComparisonObj]
}

struct PartywiseComparisonObj: Codable {
    let slno, name, cin, currentyearsale, partystatus: String?
    let previousyearsale, previoustwoyearsale: String?
}
