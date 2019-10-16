//
//  OutstandingAbove.swift
//  ManagementApp
//
//  Created by Goldmedal on 28/03/19.
//  Copyright © 2019 Goldmedal. All rights reserved.
//

import Foundation
struct OutstandingAbove: Decodable {
    let result: Bool?
    let message, servertime: String?
    let data: [OutstandingAboveObj]
}

struct OutstandingAboveObj: Decodable {
    let slno: String?
    let category: String?
    let partynm: String?
    let locnm: String?
    let city: String?
    let statenm: String?
    let commercial: String?
    let cin, totaloutstanding, countinvoice, historydays, partystatus: String?
    let totalbalance, lastinvoicedate, lastpaymentdate, lastpaymentamt: String?
}
