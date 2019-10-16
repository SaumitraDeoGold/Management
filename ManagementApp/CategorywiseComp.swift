//
//  CategorywiseComp.swift
//  ManagementApp
//
//  Created by Goldmedal on 14/08/19.
//  Copyright © 2019 Goldmedal. All rights reserved.
//

import Foundation
struct CategorywiseComp: Codable {
    let result: Bool?
    let message, servertime: String?
    let data: [CategorywiseCompObj]
}

// MARK: - Datum
struct CategorywiseCompObj: Codable {
    let branchid, branchnm, curwiringdevices, curlights: String?
    let curwireandcable, curpipesandfittings, curmcbanddbs, curtotalsale: String?
    let curbranchcontribution, curbranchcontributionpercentage, lastwiringdevices, lastlights: String?
    let lastwireandcable, lastpipesandfittings, lastmcbanddbs, lasttotalsale: String?
    let lastbranchcontribution, lastbranchcontributionpercentage: String?
}
