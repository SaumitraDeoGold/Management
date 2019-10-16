//
//  SpinConfirmData.swift
//  DealorsApp
//
//  Created by Goldmedal on 10/31/18.
//  Copyright © 2018 Goldmedal. All rights reserved.
//

import Foundation
struct SpinConfirmElement:Codable {
    let result: Bool?
    let message, servertime: String?
    let data: [SpinConfirmObj]
}

struct SpinConfirmObj:Codable {
    let slNo, amount: Int?
}
