//
//  OutsPaymentSummaryList.swift
//  DealorsApp
//
//  Created by Goldmedal on 3/11/19.
//  Copyright © 2019 Goldmedal. All rights reserved.
//

import Foundation
struct OutsPaymentSummaryListElement: Codable {
    let result: Bool?
    let message, servertime: String?
    let data: [OutsPaymentSummaryListObj]
}

struct OutsPaymentSummaryListObj: Codable {
    let receipt: String?
    let retry: Bool?
    let voucherdt: String?
    let discoumtamt: Int?
    let status, transactionid, freepaytransactionid: String?
    let totalamt, savedamt, slno, statusflag: Int?
}
