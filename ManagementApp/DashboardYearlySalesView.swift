//
//  DashboardYearlySalesView.swift
//  DealorsApp
//
//  Created by Goldmedal on 8/30/18.
//  Copyright © 2018 Goldmedal. All rights reserved.
//

import Foundation
struct YearlySalesAgreementElement: Codable {
    let result: Bool?
    let message, servertime: String?
    let data: [YearlySalesData]
}

struct YearlySalesData: Codable {
    let ysadetails: [Ysadetail]
    let ysatotal: [Ysatotal]
}

struct Ysadetail: Codable {
    let groupnm, ysa, sale: String?
}

struct Ysatotal: Codable {
    let totalsale: String
}
