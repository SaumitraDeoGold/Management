//
//  PartywiseComp.swift
//  ManagementApp
//
//  Created by Goldmedal on 03/07/19.
//  Copyright © 2019 Goldmedal. All rights reserved.
//

import Foundation
struct PartwiseComp: Codable {
    let result: Bool?
    let message, servertime: String?
    let data: [PartwiseCompObj]
}

// MARK: - Datum
struct PartwiseCompObj: Codable {
    let branchid, headnm, amount: String?
}
//struct PartwiseComp: Codable {
//    let result: Bool?
//    let message, servertime: String?
//    let data: [PartwiseCompObj]
//}
//
//struct PartwiseCompObj: Codable {
//    let name, amount: String?
//}
