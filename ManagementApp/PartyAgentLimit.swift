//
//  PartyAgentLimit.swift
//  ManagementApp
//
//  Created by Goldmedal on 20/04/20.
//  Copyright © 2020 Goldmedal. All rights reserved.
//

import Foundation
struct PartyAgentLimit: Codable {
    let result: Bool
    let message, servertime: String
    let data: [PartyAgentLimitObj]
}

// MARK: - Datum
struct PartyAgentLimitObj: Codable {
    let party: String
    let outstanding, secured, unSecured, securedper: Int
    let unSecuredper, insurance: Int
}
