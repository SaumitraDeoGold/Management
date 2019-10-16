//
//  ActiveScheme.swift
//  DealorsApp
//
//  Created by Goldmedal on 8/30/18.
//  Copyright © 2018 Goldmedal. All rights reserved.
//

import Foundation
struct ActiveSchemeElement: Decodable {
    let result: Bool?
    let message, servertime: String?
    let data: [ActiveSchemeData]
}

struct ActiveSchemeData: Decodable {
    let activeschemedata: [ActiveSchemeObject]
    let ismore: Bool?
}

struct ActiveSchemeObject: Decodable {
    let schemeType, schemeName, fromDate, toDate, imgurl: String?
    let link: String?
}
