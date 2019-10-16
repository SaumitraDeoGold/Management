//
//  Document.swift
//  DealorsApp
//
//  Created by Goldmedal on 8/30/18.
//  Copyright © 2018 Goldmedal. All rights reserved.
//

import Foundation

struct DocumentElement: Codable {
    let result: Bool?
    let message, servertime: String?
    let data: [DocumentObj]
}

struct DocumentObj: Codable {
    let schemename, fromdt, todate, url: String?
    let appurl: String?
}
