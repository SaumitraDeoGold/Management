//
//  Enquiry.swift
//  DealorsApp
//
//  Created by Goldmedal on 8/30/18.
//  Copyright © 2018 Goldmedal. All rights reserved.
//

import Foundation
struct enquiryElement: Codable {
    let result: Bool?
    let message, servertime: String?
    let data: [EnquiryData]
}

struct EnquiryData: Codable {
    let slno: Int?
    let subjectnm: String?
}
