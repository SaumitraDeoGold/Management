//
//  ThirdPartyAging.swift
//  ManagementApp
//
//  Created by Goldmedal on 26/05/20.
//  Copyright © 2020 Goldmedal. All rights reserved.
//

import Foundation
struct ThirdPartyAging: Codable {
    let result: Bool?
    let message, servertime: String?
    let data: [ThirdPartyAgingObj]
}

// MARK: - Datum
struct ThirdPartyAgingObj: Codable {
    let partyId, party, to30Days, to60Days, to90Days: String?
    let to120Days, to150Days, ab150Days: String?
}
