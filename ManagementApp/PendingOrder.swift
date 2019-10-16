//
//  PendingOrder.swift
//  DealorsApp
//
//  Created by Goldmedal on 8/30/18.
//  Copyright © 2018 Goldmedal. All rights reserved.
//

import Foundation
struct PendingOrderElement: Decodable {
    let result: Bool?
    let message, servertime: String?
    let data: [PendingOrderData]
}

struct PendingOrderData: Decodable {
    let pendingdata: [PendingOrderObject]
    let ismore: Bool?
}

struct PendingOrderObject: Decodable {
    let itemName, itemCode, colornm, poNum: String?
    let poDt, pendingQty, amount: String?
}
