//
//  Insurance.swift
//  ManagementApp
//
//  Created by Goldmedal on 28/01/20.
//  Copyright © 2020 Goldmedal. All rights reserved.
//

import Foundation
struct Insurance: Codable {
    let result: Bool?
    let message, servertime: String?
    let data: [InsuranceObj]
}

// MARK: - Datum
struct InsuranceObj: Codable {
    let branch, branchid: String?
    let outstanding, secured, unSecured, securedper: Int?
    let unSecuredper, insurance: Int?
}
