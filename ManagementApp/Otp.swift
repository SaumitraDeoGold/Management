//
//  Otp.swift
//  DealorsApp
//
//  Created by Goldmedal on 8/24/18.
//  Copyright © 2018 Goldmedal. All rights reserved.
//

import Foundation
struct VerifyOTPElement: Decodable {
    let result: Bool?
    let message, servertime: String?
}
