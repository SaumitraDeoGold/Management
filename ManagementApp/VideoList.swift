//
//  VideoList.swift
//  DealorsApp
//
//  Created by Goldmedal on 10/8/18.
//  Copyright © 2018 Goldmedal. All rights reserved.
//

import Foundation
struct VideoDetailElement:Decodable {
    let result: Bool?
    let message, servertime: String?
    let data: [VideoObj]
}

struct VideoObj:Decodable {
    let events, advertisement, product: [Advertisement]
}

struct Advertisement:Decodable {
    let videolink: String?
    let images: String?
    let subject, details, hour, minute: String?
    let second: String?
}
