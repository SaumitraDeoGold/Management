//
//  Statewise.swift
//  ManagementApp
//
//  Created by Goldmedal on 08/07/19.
//  Copyright © 2019 Goldmedal. All rights reserved.
//

import Foundation
  struct Statewise: Codable {
    let result: Bool?
    let message, servertime: String?
    let data: [StatewiseObj]
}
 
struct StatewiseObj: Codable {
    let statenm, stateid, currentyearsale, previousyearsale: String
    let previoutwoyearsale: String
}
