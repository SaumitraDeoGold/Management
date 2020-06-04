//
//  ThirdPartyStatus.swift
//  ManagementApp
//
//  Created by Goldmedal on 20/05/20.
//  Copyright © 2020 Goldmedal. All rights reserved.
//

import Foundation
struct ThirdPartyStatus: Codable {
    let result: Bool?
    let message, servertime: String?
    let data: [ThirdPartyStatusObj]
}

// MARK: - Datum
struct ThirdPartyStatusObj: Codable {
    let branch: String?
    let pono, poDate, party, partyId: String?
    let orderStatus: String?
    let status: String?
    let total: String?
    let url: String?
}
