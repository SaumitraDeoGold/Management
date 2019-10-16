//
//  OtpFreepayGetData.swift
//  DealorsApp
//
//  Created by Goldmedal on 4/1/19.
//  Copyright © 2019 Goldmedal. All rights reserved.
//

import Foundation

struct GetOtpFreePayElement: Codable {
    let result: Bool?
    let message, servertime: String?
    let data: [GetOtpFreePayObj]
}

struct GetOtpFreePayObj: Codable {
    let isRegistered: Bool?
    let mobile,email: String?
}
