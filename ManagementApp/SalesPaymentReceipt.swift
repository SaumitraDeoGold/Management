//
//  SalesPaymentReceipt.swift
//  DealorsApp
//
//  Created by Goldmedal on 8/30/18.
//  Copyright © 2018 Goldmedal. All rights reserved.
//

import Foundation

struct SalesPaymentElement: Decodable {
    let result: Bool?
    let message, servertime: String?
    let data: [SalesPaymentData]
}

struct SalesPaymentData: Decodable {
    let custrecieptdata: [SalesPaymentObject]
    let ismore: Bool?
}

struct SalesPaymentObject: Decodable {
    let slno: Int?
    let instrumentType: String?
    let reciept, date: String?
    let division: String?
    let status: String?
    let amount: String?
}
