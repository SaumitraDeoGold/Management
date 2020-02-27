//
//  InsureParty.swift
//  ManagementApp
//
//  Created by Goldmedal on 28/01/20.
//  Copyright © 2020 Goldmedal. All rights reserved.
//

import Foundation
struct InsureParty: Codable {
    let result: Bool?
    let message, servertime: String?
    let data: [InsurePartyObj]
}

// MARK: - Datum
struct InsurePartyObj: Codable {
    let name: String?
    let outstanding, secured, unSecured, securedper: Int?
    let unSecuredper, insurance: Int?
}
