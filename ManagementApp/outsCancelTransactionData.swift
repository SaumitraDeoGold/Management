//
//  outsCancelTransactionData.swift
//  DealorsApp
//
//  Created by Goldmedal on 4/9/19.
//  Copyright © 2019 Goldmedal. All rights reserved.
//

import Foundation
//  -- -  - - - - - local unblocking outstanding object - -  - - - - - - - -
struct UnblockOutstandingElement: Codable {
    let result: Bool?
    let message, servertime: String?
    let data: UnblockOutstandingObj?
}

struct UnblockOutstandingObj: Codable {
}
