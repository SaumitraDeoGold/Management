//
//  InvoiceData.swift
//  ManagementApp
//
//  Created by Goldmedal on 14/12/19.
//  Copyright © 2019 Goldmedal. All rights reserved.
//

import Foundation
struct InvoiceData: Codable {
    let result: Bool?
    let message, servertime: String?
    let data: [InvoiceDataObj]
}

// MARK: - Datum
struct InvoiceDataObj: Codable {
    let vocherno, date, amount, narration: String?
    let paymentmode: String?
    let type: String?
    let link: String?
}
