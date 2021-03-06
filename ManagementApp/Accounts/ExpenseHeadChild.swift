//
//  ExpenseHeadChild.swift
//  ManagementApp
//
//  Created by Goldmedal on 31/08/19.
//  Copyright © 2019 Goldmedal. All rights reserved.
//

import Foundation
struct ExpenseHead: Codable {
    let result: Bool?
    let message, servertime: String?
    let data: [ExpenseHeadObj]
}

// MARK: - Datum
struct ExpenseHeadObj: Codable {
    let name, amount, link: String?
    
}
