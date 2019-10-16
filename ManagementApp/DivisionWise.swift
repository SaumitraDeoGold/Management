//
//  DivisionWise.swift
//  DealorsApp
//
//  Created by Goldmedal on 8/30/18.
//  Copyright © 2018 Goldmedal. All rights reserved.
//

import Foundation
struct DivisionWiseSaleElement: Decodable {
    let result: Bool?
    let message, servertime: String?
    let data: [DivisionWiseData]
}

struct DivisionWiseData: Decodable {
    let divisionSalesReport: [DivisionSalesReport]
    let totalAmt: String?
}

struct DivisionSalesReport: Decodable {
    let division, amount: String?
}
