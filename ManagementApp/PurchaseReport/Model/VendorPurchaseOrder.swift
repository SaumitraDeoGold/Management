//
//  VendorPurchaseOrder.swift
//  ManagementApp
//
//  Created by Goldmedal on 19/05/20.
//  Copyright © 2020 Goldmedal. All rights reserved.
//

import Foundation
struct VendorPurchaseOrder: Codable {
    let result: Bool?
    let message, servertime: String?
    let data: [VendorPurchaseOrderObj]
}

// MARK: - Datum
struct VendorPurchaseOrderObj: Codable {
    let partyId, typeOfParty: String?
    let party: String?
    let branch: String?
    let branchId, total, invoiceNo, invoiceDate: String?
    let division: String?
    let receivedDate: String?
    let fileurl: String?
}

 
