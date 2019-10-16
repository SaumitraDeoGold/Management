//
//  ComboCompareData.swift
//  DealorsApp
//
//  Created by Goldmedal on 10/26/18.
//  Copyright © 2018 Goldmedal. All rights reserved.
//

import Foundation
struct ComboCompareElement:Codable {
    let result: Bool?
    let message, servertime: String?
    let data: [ComboCompareObj]
}

struct ComboCompareObj:Codable {
    let combocomparedetails: [ComboCompareArr]
    let allcombonm: String?
}

struct ComboCompareArr:Codable {
    let itemid: String?
    let combogrpname: String?
    let comboname, itemnm, qty: String?
}
