//
//  MpinData.swift
//  DealorsApp
//
//  Created by Goldmedal on 1/2/19.
//  Copyright © 2019 Goldmedal. All rights reserved.
//

import Foundation
struct CheckMpinElement: Codable {
    let result: Bool?
    let message, servertime: String?
    let data: [CheckMpinData]?
}

struct CheckMpinData: Codable {
    let isBlock: Bool?
    let isForcedLogout: Bool?
}
