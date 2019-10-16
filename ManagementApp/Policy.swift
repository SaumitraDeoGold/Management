//
//  Policy.swift
//  DealorsApp
//
//  Created by Goldmedal on 8/30/18.
//  Copyright © 2018 Goldmedal. All rights reserved.
//

import Foundation

struct PolicyElement : Decodable {
    let result: Bool?
    let message, servertime: String?
    let data: [PolicyData]
}

struct PolicyData : Decodable {
    let policyName, fromDate, todate,imgurl, pdf: String?
}
