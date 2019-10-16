//
//  GetAllTeamsData.swift
//  DealorsApp
//
//  Created by Goldmedal on 4/15/19.
//  Copyright © 2019 Goldmedal. All rights reserved.
//

import Foundation
struct GetAllTeam: Codable {
    let result: Bool?
    let message, servertime: String?
    let data: [GetAllTeamObj]
}

struct GetAllTeamObj: Codable {
    let eventName, teamName: String?
    let eventId, teamId, issemifinal, isfinal, iswinner : Int?
    let point: Double?
}

