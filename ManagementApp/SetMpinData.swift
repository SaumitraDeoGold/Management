//
//  SetMpinData.swift
//  DealorsApp
//
//  Created by Goldmedal on 1/16/19.
//  Copyright © 2019 Goldmedal. All rights reserved.
//

import Foundation
struct SetMpinElement: Codable {
    let result: Bool?
    let message, servertime: String?
    let data: [SetMpinData]
}

struct SetMpinData: Codable {
    let output: String?
}
