//
//  DashboardAgingReport.swift
//  DealorsApp
//
//  Created by Goldmedal on 8/30/18.
//  Copyright © 2018 Goldmedal. All rights reserved.
//

import Foundation
struct AgingReportElement: Codable {
    let result: Bool?
    let message, servertime: String?
    let data: [AgingReportObj]
}

struct AgingReportObj: Codable {
    let agingDetails: [AgingDetail]
    let agingurls: [Agingurl]
}

struct AgingDetail: Codable {
    let days, amount: String?
}

struct Agingurl: Codable {
    let url: String?
}
