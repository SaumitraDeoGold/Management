//
//  DashboardTodaySale.swift
//  ManagementApp
//
//  Created by Goldmedal on 20/03/19.
//  Copyright © 2019 Goldmedal. All rights reserved.
//

import Foundation
//typealias Welcome = [WelcomeElement]

struct TodaySales: Codable {
    let result: Bool?
    let message, servertime: String?
    let data: [TodaySaleObj]
}

struct TodaySaleObj: Codable {
    let today, monthly, quarterly, yearly: String
}
