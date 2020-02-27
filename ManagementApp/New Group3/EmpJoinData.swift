//
//  EmpJoinData.swift
//  ManagementApp
//
//  Created by Goldmedal on 17/02/20.
//  Copyright © 2020 Goldmedal. All rights reserved.
//

import Foundation
struct EmpJoinData: Codable {
    let result: Bool?
    let message, servertime: String?
    let data: [EmpJoinDataObj]
}

// MARK: - Datum
struct EmpJoinDataObj: Codable {
    let monthCount, yearCount, monthCountLeaving, yearCountLeaving: Int?
}
