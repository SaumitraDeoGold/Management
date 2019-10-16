//
//  DashDivSale.swift
//  ManagementApp
//
//  Created by Goldmedal on 14/06/19.
//  Copyright © 2019 Goldmedal. All rights reserved.
//

import Foundation
// MARK: - WelcomeElement
struct DashDivSale: Codable {
    let result: Bool?
    let message, servertime: String?
    let data: [DivSaleObj]
}

// MARK: - Datum
struct DivSaleObj: Codable {
    let divisionnm, amount: String?
}
