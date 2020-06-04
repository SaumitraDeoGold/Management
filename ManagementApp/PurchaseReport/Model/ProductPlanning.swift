//
//  ProductPlanning.swift
//  ManagementApp
//
//  Created by Goldmedal on 20/05/20.
//  Copyright © 2020 Goldmedal. All rights reserved.
//

import Foundation
struct ProductPlanning: Codable {
    let result: Bool?
    let message, servertime: String?
    let data: [ProductPlanningObj]
}

// MARK: - Datum
struct ProductPlanningObj: Codable {
    let itemCode, itemName, vasaiStock, branchStock: String?
    let purchasePending, averageSale: String?
}
