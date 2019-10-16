//
//  SpinTotalData.swift
//  DealorsApp
//
//  Created by Goldmedal on 10/17/18.
//  Copyright © 2018 Goldmedal. All rights reserved.
//

import Foundation
struct SpinTotalElement:Codable {
    let result: Bool?
    let message, servertime: String?
    let data: [SpinTotalObj]
}

struct SpinTotalObj:Codable  {
    let date: String?
    let amount: Int?
}
