//
//  ComboReview.swift
//  DealorsApp
//
//  Created by Goldmedal on 11/5/18.
//  Copyright © 2018 Goldmedal. All rights reserved.
//

import Foundation
struct ComboReviewElement:Codable {
    let result: Bool?
    let message, servertime: String?
    let data: [ComboReviewObj]
}

struct ComboReviewObj:Codable {
    let comboTotalQtyDetails: [ComboTotalQtyDetail]
    let totalqty: String?
}

struct ComboTotalQtyDetail:Codable {
    let itemname, range, qty: String?
}
