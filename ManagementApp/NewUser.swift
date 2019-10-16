//
//  NewUser.swift
//  DealorsApp
//
//  Created by Goldmedal on 8/24/18.
//  Copyright © 2018 Goldmedal. All rights reserved.
//

import Foundation
struct ValidateCINElement: Decodable {
    let result: Bool?
    let message, servertime: String?
    let data: [ValidateCinData]
}

struct ValidateCinData: Decodable {
    let email, mobile: String?
}
