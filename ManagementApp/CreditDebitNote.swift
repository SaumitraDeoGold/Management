//
//  CreditDebitNote.swift
//  DealorsApp
//
//  Created by Goldmedal on 9/5/18.
//  Copyright © 2018 Goldmedal. All rights reserved.
//

import Foundation
struct CreditDebitNoteElement: Codable {
    let result: Bool?
    let message, servertime: String?
    let data: [CreditDebitObj]
}

struct CreditDebitObj: Codable {
    let slno: Int?
    let referenceno, date, amount, ledgerdec, type, url, download: String?
}


