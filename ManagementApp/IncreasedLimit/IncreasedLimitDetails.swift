//
//  IncreasedLimitDetails.swift
//  ManagementApp
//
//  Created by Goldmedal on 19/10/19.
//  Copyright © 2019 Goldmedal. All rights reserved.
//

import Foundation
struct IncreasedLimitDetails: Codable {
    let result, message, servertime: String?
    let data: [IncreasedLimitDetailsObj]
}

// MARK: - Datum
struct IncreasedLimitDetailsObj: Codable {
    let slno: Int?
    let partytype: String?
    let displaynm: String?
    let homebranch: String?
    let city, increaselimit: String?
    let creatdt: String?
    let status: String?
    let uselimit: String?
    let usernm: String?
}
