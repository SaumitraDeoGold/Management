//
//  RaiseDisputeData.swift
//  DealorsApp
//
//  Created by Goldmedal on 5/2/19.
//  Copyright © 2019 Goldmedal. All rights reserved.
//

import Foundation
struct RaiseDisputeElement: Codable {
    let result: Bool?
    let message, servertime: String?
    let data: [RaiseDisputeObj]
}

struct RaiseDisputeObj: Codable {
    let disputeid: Int?
    let reason: String?
}
