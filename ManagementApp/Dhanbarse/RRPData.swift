//
//  RRPData.swift
//  ManagementApp
//
//  Created by Goldmedal on 21/04/20.
//  Copyright © 2020 Goldmedal. All rights reserved.
//

import Foundation
struct RRPData: Codable {
    let result: Bool
    let message, servertime: String
    let data: [RRPDataObj]
}

// MARK: - Datum
struct RRPDataObj: Codable {
    let profileid, fullName: String
    let categorynm: String
    let pointType: String
    let mobileNo, email, balancePoints, shopName: String
}

 
