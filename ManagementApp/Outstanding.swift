//
//  Outstanding.swift
//  DealorsApp
//
//  Created by Goldmedal on 8/30/18.
//  Copyright © 2018 Goldmedal. All rights reserved.
//

import Foundation
struct OutstandingElement: Decodable {
    let result: Bool?
    let message: String?
    let data: [Outstanding]
}

struct Outstanding: Decodable {
    let due, overDue, outstandings : String?
}
