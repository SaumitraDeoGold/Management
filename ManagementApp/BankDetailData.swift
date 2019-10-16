//
//  BankDetaildata.swift
//  DealorsApp
//
//  Created by Goldmedal on 2/26/19.
//  Copyright © 2019 Goldmedal. All rights reserved.
//

import Foundation
struct BankNameDetailElement: Codable {
    let result: Bool?
    let message, servertime: String?
    let data: [BankNameDetailArray]
}

struct BankNameDetailArray: Codable {
    let bankname, utrn, amount: String?
}
