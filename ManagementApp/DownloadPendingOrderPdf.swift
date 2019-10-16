//
//  DownloadPendingOrderPdf.swift
//  DealorsApp
//
//  Created by Goldmedal on 8/31/18.
//  Copyright © 2018 Goldmedal. All rights reserved.
//

import Foundation
struct PendingOrderPDFElement: Codable {
    let result: Bool?
    let message, servertime: String?
    let data: [PendingOrderPdfObj]
}

struct PendingOrderPdfObj: Codable {
    let url: String?
}
