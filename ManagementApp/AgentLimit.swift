//
//  AgentLimit.swift
//  ManagementApp
//
//  Created by Goldmedal on 20/04/20.
//  Copyright © 2020 Goldmedal. All rights reserved.
//

import Foundation
struct AgentLimit: Codable {
    let result: Bool
    let message, servertime: String
    let data: [AgentLimitObj]
}

// MARK: - Datum
struct AgentLimitObj: Codable {
    let agent, agentId: String
    let outstanding, secured, unSecured: Double
    let securedper, unSecuredper, agentLimit: Int 
}
