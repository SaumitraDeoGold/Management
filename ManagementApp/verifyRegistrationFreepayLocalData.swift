//
//  verifyRegistrationFreepayLocalData.swift
//  DealorsApp
//
//  Created by Goldmedal on 3/18/19.
//  Copyright © 2019 Goldmedal. All rights reserved.
//

import Foundation
// - - - -  for local verification api  for freepay otp -- - - -  - - -
struct VerifyRegistrationOtpLocal: Codable {
    let result: Bool?
    let message, servertime: String?
    let data: VerifyRegistrationOtpLocalObj?
}

struct VerifyRegistrationOtpLocalObj: Codable {
  
}
