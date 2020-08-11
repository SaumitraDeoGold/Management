//
//  DhanCityProfile.swift
//  ManagementApp
//
//  Created by Goldmedal on 20/06/20.
//  Copyright © 2020 Goldmedal. All rights reserved.
//

import Foundation
struct DhanCityProfile: Codable {
    let result: Bool?
    let message, servertime: String?
    let data: [DhanCityProfileObj]
}

// MARK: - Datum
struct DhanCityProfileObj: Codable {
    let slNo, name, email, mobileNo, category: String?
    let address, city, state, district: String?
    let shopName, joinDate: String?
}
