//
//  DistWiseChild.swift
//  ManagementApp
//
//  Created by Goldmedal on 30/07/19.
//  Copyright © 2019 Goldmedal. All rights reserved.
//

import Foundation
struct DistWiseChild: Codable {
    let result: Bool?
    let message, servertime: String?
    let data: [DistWiseChildObj]
}

// MARK: - Datum
struct DistWiseChildObj: Codable {
    let slno, name, cin: String?
    let partystatus: String?
    let currentyearsale, previousyearsale, previoustwoyearsale: String?
}
