//
//  StarRewards.swift
//  DealorsApp
//
//  Created by Goldmedal on 8/30/18.
//  Copyright © 2018 Goldmedal. All rights reserved.
//

import Foundation

struct StarRewardElement: Codable {
    let result: Bool?
    let message, servertime: String?
    let data: [StarRewardObj]
}

struct StarRewardObj: Codable {
    let summaryDetails: [SummaryDetail]
    let starRewardurl: [StarRewardurl]
}

struct StarRewardurl: Codable {
    let url: String?
}

struct SummaryDetail: Codable {
    let division, lstyrsales, curryrsales: String?
}
