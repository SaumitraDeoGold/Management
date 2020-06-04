//
//  DRPData.swift
//  ManagementApp
//
//  Created by Goldmedal on 21/04/20.
//  Copyright © 2020 Goldmedal. All rights reserved.
//

import Foundation
struct DRPData: Codable {
    let result: Bool
    let message, servertime: String
    let data: [DRPDataObj]
}

// MARK: - Datum
struct DRPDataObj: Codable {
    let stateid: Int
    let statenm, drp, rrp, crp: String
}
