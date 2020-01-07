//
//  DhanbarseDocsData.swift
//  DealorsApp
//
//  Created by Goldmedal on 8/19/19.
//  Copyright © 2019 Goldmedal. All rights reserved.
//

import Foundation
struct DhanbarseQwikPayDocsElement: Codable {
    let result: Bool?
    let message, servertime: String?
    let data: [DhanbarseQwikPayDocsObj]
}

// MARK: - Datum
struct DhanbarseQwikPayDocsObj: Codable {
    let pricelistdata: [DhanbarseQwikPayDocsArr]
    let ismore: Bool?
}

// MARK: - Pricelistdatum
struct DhanbarseQwikPayDocsArr: Codable {
    let policyType, policyName, fromDate, toDate: String?
    let fileURL: String?
    let imgurl: String?
}
