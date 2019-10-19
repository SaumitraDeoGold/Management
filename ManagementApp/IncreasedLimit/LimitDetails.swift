//
//  LimitDetails.swift
//  ManagementApp
//
//  Created by Goldmedal on 18/10/19.
//  Copyright © 2019 Goldmedal. All rights reserved.
//

import Foundation
struct LimitDetails: Codable {
    let result: Bool?
    let message, servertime: String?
    let data: [LimitDetailsObj]
}

// MARK: - Datum
struct LimitDetailsObj: Codable {
    let partyid, cin, displaynm: String?
}
