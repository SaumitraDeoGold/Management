//
//  OutstandingReport.swift
//  DealorsApp
//
//  Created by Goldmedal on 8/30/18.
//  Copyright © 2018 Goldmedal. All rights reserved.
//

import Foundation

struct OutstandingReportElement: Decodable {
    let result: Bool?
    let message, servertime: String?
    let data: [OutstandingReportData]
}

struct OutstandingReportData: Decodable {
    let outstandingdata: [OutstandingReportObject]
    let totaloutstanding: [Totaloutstanding]
    let totaldueoverdue: [Totaldueoverdue]
    let ismore: Bool?
}

struct OutstandingReportObject: Decodable {
    let invoiceNo, invoiceDate, invoiceAmt, ouststandingAmt, divisionName, dueDays: String?
}

struct Totaldueoverdue: Decodable {
    let due, overDue: String?
}

struct Totaloutstanding: Decodable {
    let invoiceAmt, ouststandingAmt: String?
}

