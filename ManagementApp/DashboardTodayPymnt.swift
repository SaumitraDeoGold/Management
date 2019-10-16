//
//  DashboardTodayPymnt.swift
//  ManagementApp
//
//  Created by Goldmedal on 20/03/19.
//  Copyright © 2019 Goldmedal. All rights reserved.
//

import Foundation
struct TodayPayment: Codable {
    let result: Bool?
    let message, servertime: String?
    let data: [TodayPaymentObj]
}

struct TodayPaymentObj: Codable {
    let today, monthly, quarterly, yearly: String
}
