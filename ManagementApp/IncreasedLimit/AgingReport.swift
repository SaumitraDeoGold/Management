//
//  AgingReport.swift
//  ManagementApp
//
//  Created by Goldmedal on 19/10/19.
//  Copyright © 2019 Goldmedal. All rights reserved.
//

import Foundation
struct AgingReport: Decodable {
    let result: Bool?
    let message, servertime: String?
    let data: [AgingData]
}

// MARK: - Datum
struct AgingData: Decodable {
    let agingDetails: [AgingDetails]
    let agingurls: [Agingurls]
}

// MARK: - AgingDetail
struct AgingDetails: Decodable {
    let days, amount: String?
}

// MARK: - Agingurl
struct Agingurls: Decodable {
    let url: String?
}

