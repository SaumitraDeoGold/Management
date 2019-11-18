//
//  DivBreakdownTotal.swift
//  ManagementApp
//
//  Created by Goldmedal on 11/11/19.
//  Copyright © 2019 Goldmedal. All rights reserved.
//

import Foundation
struct DivBreakdownTotal: Codable {
    let result: Bool
    let message, servertime: String
    let data: [DivBreakdownTotalObj]
}

// MARK: - Datum
struct DivBreakdownTotalObj: Codable {
    let date, amount: String?
}
