//
//  ComboSchemeData.swift
//  DealorsApp
//
//  Created by Goldmedal on 10/18/18.
//  Copyright © 2018 Goldmedal. All rights reserved.
//

import Foundation
struct ComboSchemeElement:Codable {
    let result: Bool?
    let message, servertime: String?
    let data: [ComboSchemeObj]
}

struct ComboSchemeObj:Codable {
    let comboSchemeDetails: [ComboSchemeDetail]
    let comboSchemeURL: String?
    let comboSchemeBooking: Bool?
}

struct ComboSchemeDetail:Codable {
    let slno: Int?
    var combogrpname: String?
    var comboname, qty, initQty, amount: String?
    var isAdded: Bool?
}


