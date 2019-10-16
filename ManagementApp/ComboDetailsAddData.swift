//
//  ComboDetailsAddData.swift
//  DealorsApp
//
//  Created by Goldmedal on 10/30/18.
//  Copyright © 2018 Goldmedal. All rights reserved.
//

import Foundation
struct ComboDetailsAddElement:Codable {
    let result: Bool?
    let message, servertime: String?
    let data: [ComboDetailArr]
}

struct ComboDetailArr:Codable {
    let itemname, qty, dlp, amount: String?
    let remarks: String?
}
