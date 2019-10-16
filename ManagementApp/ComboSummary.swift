//
//  ComboSummary.swift
//  DealorsApp
//
//  Created by Goldmedal on 9/25/18.
//  Copyright © 2018 Goldmedal. All rights reserved.
//

import Foundation

struct ComboSummaryElement:Codable {
    let result: Bool?
    let message, servertime: String?
    let data: [ComboSummaryObj]
}

struct ComboSummaryObj : Codable {
    let itemnm, finalqty, totalsale, difference: String?
}
