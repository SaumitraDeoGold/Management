//
//  NDADetail.swift
//  ManagementApp
//
//  Created by Goldmedal on 30/03/19.
//  Copyright © 2019 Goldmedal. All rights reserved.
//

import Foundation
struct NDADetail: Codable {
    let result: Bool?
    let message, servertime: String?
    let data: [NDADetailObj]
}

struct NDADetailObj: Codable {
    let name, cin, salesExecutive, amount, joinDate: String?
}
