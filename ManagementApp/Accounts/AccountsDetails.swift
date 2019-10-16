//
//  AccountsDetails.swift
//  ManagementApp
//
//  Created by Goldmedal on 21/05/19.
//  Copyright © 2019 Goldmedal. All rights reserved.
//

import Foundation
struct AccountDetails: Codable {
    let result: Bool?
    let message, servertime: String?
    let data: [AccountDetailsObj]
}

struct AccountDetailsObj: Codable {
    let partynm, cin, city, outstandingamt, partystatus, lstinvoicedt, lstpaymentdt, lstpaymentamt: String?
}
