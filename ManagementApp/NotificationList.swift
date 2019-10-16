//
//  NotificationList.swift
//  DealorsApp
//
//  Created by Goldmedal on 15/11/18.
//  Copyright © 2018 Goldmedal. All rights reserved.
//

import Foundation



struct NotiTotalElement: Codable {
    let result: Bool
    let message, servertime: String
    let data: [NotificationObject]
}

struct NotificationObject: Codable {
    let title, body, date, time: String?
}

