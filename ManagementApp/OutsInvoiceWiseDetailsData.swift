//
//  OutsInvoiceWiseDetailsData.swift
//  DealorsApp
//
//  Created by Goldmedal on 3/18/19.
//  Copyright © 2019 Goldmedal. All rights reserved.
//

import Foundation

struct OutsInvoiceWiseCdElement: Codable {
    let result: Bool?
    let message, servertime: String?
    let data: [OutsInvoiceWiseCdObj]
}

struct OutsInvoiceWiseCdObj: Codable {
    let duedays, percentage: String?
    let duedate: String?
}
