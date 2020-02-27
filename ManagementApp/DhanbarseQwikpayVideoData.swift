
//
//  QwikpayVideoData.swift
//  DealorsApp
//
//  Created by Goldmedal on 8/19/19.
//  Copyright © 2019 Goldmedal. All rights reserved.
//

import Foundation
struct DhanbarseQwikPayVideoElement: Codable {
    let result: Bool?
    let message, servertime: String?
    let data: [DhanbarseQwikPayObj]
}

// MARK: - Datum
struct DhanbarseQwikPayObj: Codable {
    let videolink: String?
    let images: String?
    let subject, details, hour, minute: String?
    let second: String?
}
