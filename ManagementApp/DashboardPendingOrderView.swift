//
//  DashboardPendingOrderView.swift
//  DealorsApp
//
//  Created by Goldmedal on 8/30/18.
//  Copyright © 2018 Goldmedal. All rights reserved.
//

import Foundation
struct PendingOrderDivisionElement: Codable {
    let result: Bool?
    let message, servertime: String?
    let data: [PendingOrderDivisionObj]
}

struct PendingOrderDivisionObj: Codable {
    let pendingdetails: [Pendingdetail]
    let pendingtotal: [Pendingtotal]
}

struct Pendingdetail: Codable {
    let divisionnm, pending: String?
}

struct Pendingtotal: Codable {
    let pendingtotal: String?
}
