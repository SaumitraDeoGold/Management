//
//  SalexExecutive.swift
//  ManagementApp
//
//  Created by Goldmedal on 24/06/20.
//  Copyright © 2020 Goldmedal. All rights reserved.
//

import Foundation
struct SalexExecutive: Codable {
    let result: Bool?
    let message, servertime: String?
    let data: [SalexExecutiveObj]
}

// MARK: - Datum
struct SalexExecutiveObj: Codable {
    let saleexesaleandtargetDetails: [SalesExData]
    let totalSale, totalTarget, totaldealerTarget: String?
}

// MARK: - SaleexesaleandtargetDetail
struct SalesExData: Codable {
    let division, sales, target, dealertarget: String?
}
