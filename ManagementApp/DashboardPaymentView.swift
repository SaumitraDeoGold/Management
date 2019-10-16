//
//  DashboardPaymentView.swift
//  DealorsApp
//
//  Created by Goldmedal on 8/30/18.
//  Copyright © 2018 Goldmedal. All rights reserved.
//

import Foundation
struct OutstandingPaymentElement: Codable {
    let result: Bool?
    let message, servertime: String?
    let data: [OutstandingPaymentObj]
}

struct OutstandingPaymentObj: Codable {
    let outstandingdetails: [Outstandingdetail]
    let outstandingtotal: [Outstandingtotal]
}

struct Outstandingdetail: Codable {
    let divisionnm, due, overdue, outstanding: String?
}

struct Outstandingtotal: Codable {
    let duetotal, overduetotal, outstandingtotal: String?
}
