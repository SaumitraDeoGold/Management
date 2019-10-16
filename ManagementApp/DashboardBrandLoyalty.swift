//
//  DashboardBrandLoyalty.swift
//  DealorsApp
//
//  Created by Goldmedal on 8/30/18.
//  Copyright © 2018 Goldmedal. All rights reserved.
//

import Foundation
struct BrandLoyaltyElement: Codable {
    let result: Bool?
    let message, servertime: String?
    let data: [BrandLoyaltyObj]
}

struct BrandLoyaltyObj: Codable {
    let url: String?
}
