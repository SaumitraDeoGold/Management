//
//  StatewiseCompareChild.swift
//  ManagementApp
//
//  Created by Goldmedal on 17/07/19.
//  Copyright © 2019 Goldmedal. All rights reserved.
//

import Foundation
struct StatewiseChild: Codable {
    let result: Bool?
    let message, servertime: String?
    let data: [StatewiseChildObj]
}

// MARK: - Datum
struct StatewiseChildObj: Codable {
    let slno, name, cin: String?
    let partystatus: String?
    let currentyearsale, previousyearsale, previoustwoyearsale: String?
}
