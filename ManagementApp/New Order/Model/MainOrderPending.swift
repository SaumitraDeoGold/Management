//
//  MainOrderPending.swift
//  ManagementApp
//
//  Created by Goldmedal on 21/07/20.
//  Copyright © 2020 Goldmedal. All rights reserved.
//

import Foundation
import Foundation
struct MainOrderPending: Codable {
    let result: Bool?
    let message, servertime: String?
    let data: [MainOrderPendingObj]
}

// MARK: - Datum
struct MainOrderPendingObj: Codable {
    let partyId, name, lights, mcbAndDBS: String?
    let pipesAndFITTINGS, wireAndCABLE, wiringdevices: String?

}
