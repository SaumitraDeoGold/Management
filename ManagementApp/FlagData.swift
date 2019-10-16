//
//  FlagData.swift
//  DealorsApp
//
//  Created by Goldmedal on 4/19/19.
//  Copyright © 2019 Goldmedal. All rights reserved.
//

import Foundation
class FlagData: Codable {
    var flag,teamName: String?
    var teamId: Int?
    var points: Double?
    
    init(flag: String?, teamName: String?,teamId: Int?,points: Double?) {
        self.flag = flag
        self.teamName = teamName
        self.teamId = teamId
        self.points = points
    }
}
