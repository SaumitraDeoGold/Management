//
//  VendorInvoiceStruct.swift
//  ManagementApp
//
//  Created by Goldmedal on 06/02/20.
//  Copyright © 2020 Goldmedal. All rights reserved.
//

import Foundation
struct VendorInvoiceStruct: Codable {
    let result: Bool?
    let message, servertime: String?
    let data: [VendorInvoiceStructObj]
}

// MARK: - Datum
struct VendorInvoiceStructObj: Codable {
    let purchaseAndLedgerBalanceInvoiceNoVendordata: [VendorListData]
    let ismore: Bool?
}

// MARK: - PurchaseAndLedgerBalanceInvoiceNoVendordatum
struct VendorListData: Codable {
    let slno: Int?
    let uniqueKey, invoiceNo, date, fileurl: String?
    let amount: Int?
}
