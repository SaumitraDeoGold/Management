//
//  DashboardLastPaymentView.swift
//  DealorsApp
//
//  Created by Goldmedal on 8/30/18.
//  Copyright © 2018 Goldmedal. All rights reserved.
//

import Foundation
struct LastPaymentElement: Codable {
    let result: Bool?
    let message, servertime: String?
    let data: [LastPaymentObj]
}

struct LastPaymentObj: Codable {
    let custrecieptdata: [Custrecieptdatum]
    let ismore: Bool?
}

struct Custrecieptdatum: Codable {
    let slno: Int?
    let instrumentType, reciept, date, division: String?
    let status, amount: String?
}
