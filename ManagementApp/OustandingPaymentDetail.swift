//
//  OustandingPaymentDetail.swift
//  DealorsApp
//
//  Created by Goldmedal on 2/23/19.
//  Copyright © 2019 Goldmedal. All rights reserved.
//

import Foundation


struct OutstandingPaymentDetailReportElement: Codable {
    let result: Bool?
    let message, servertime: String?
    let data: [OutstandingPaymentDetailObj]
}

struct OutstandingPaymentDetailObj: Codable {
    let transno, receipt, grandtotal, savedamounttotal: String?
    let withdiscountamounttotal: String?
    let invoices: [OutsInvoiceObj]
}

struct OutsInvoiceObj: Codable {
    let invoiceId, discountedAmount, enteredAmount, savedAmount,invoiceAmount,catId: String?
    let outstandingAmount, per: String?
  
}

//struct RetryTransactionElement: Codable {
//    let result: Bool?
//    let message, servertime: String?
//    let data: [Datum]?
//}
//
//struct Datum: Codable {
//    let transno, receipt, grandtotal, savedamounttotal: String?
//    let withdiscountamounttotal: String?
//    let invoices: [Invoice]?
//}
//
//struct Invoice: Codable {
//    let invoiceId, invoiceAmount, catId, discountedAmount: String?
//    let enteredAmount, savedAmount, outstandingAmount, per: String?
//
//}
