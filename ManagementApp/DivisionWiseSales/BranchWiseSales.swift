//
//  BranchWiseSales.swift
//  G-Management
//
//  Created by Goldmedal on 22/02/19.
//  Copyright © 2019 Goldmedal. All rights reserved.
//

import Foundation
struct BranchWiseSales: Codable {
    let result: Bool?
    let message, servertime: String?
    let data: [BranchSale]?
}

struct BranchSale: Codable {
    let branchid, branchnm, wiringdevices, lights: String?
    let wireandcable, pipesandfittings, mcbanddbs, totalsale: String?
    let branchcontribution, branchcontributionpercentage: String?
}
