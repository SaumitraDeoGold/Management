//
//  AddMatchesData.swift
//  DealorsApp
//
//  Created by Goldmedal on 4/13/19.
//  Copyright © 2019 Goldmedal. All rights reserved.
//

import Foundation
struct AddLeagueMatchDetailElement: Codable {
    let result: Bool?
    let message, servertime: String?
    let data: [AddLeagueMatchDetailObj]
}

struct AddLeagueMatchDetailObj: Codable {
    let output: String?
}
