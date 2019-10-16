//
//  DistWiseCompare.swift
//  ManagementApp
//
//  Created by Goldmedal on 29/07/19.
//  Copyright © 2019 Goldmedal. All rights reserved.
//

import Foundation
struct DistWiseCompare: Codable {
    let result: Bool?
    let message, servertime: String?
    let data: [DistWiseCompareObj]
}

struct DistWiseCompareObj: Codable {
    let distnm, distid, currentyearsale, previousyearsale: String?
    let previoutwoyearsale: String?
}
