//
//  TotalPayDivisionWise.swift
//  ManagementApp
//
//  Created by Goldmedal on 09/12/19.
//  Copyright © 2019 Goldmedal. All rights reserved.
//

import Foundation
struct TotalPay: Codable {
    let result: Bool?
    let message, servertime: String?
    let data: [TotalPayObj]
}

// MARK: - Datum
struct TotalPayObj: Codable {
    let paymentdetails: [Paymentdetail]
    let paymentdetailsTotal: PaymentdetailsTotal
    let ismore: Bool?
}

// MARK: - Paymentdetail
struct Paymentdetail: Codable {
    let partynm, cin: String?
    let partystatus: String?
    let exnm, wiringdevices, lights, wireandcable: String?
    let pipesandfittings, mcbanddbs: String?
}

// MARK: - PaymentdetailsTotal
struct PaymentdetailsTotal: Codable {
    let wiringdevicetotal, lightetotal, wireandcabletotal, pipesandfittingtotal: String?
    let mcbanddbtotal: String?
    init(wiringdevicetotal: String, lightetotal: String, wireandcabletotal: String, pipesandfittingtotal: String, mcbanddbtotal: String) {
        self.wiringdevicetotal = wiringdevicetotal
        self.lightetotal = lightetotal
        self.wireandcabletotal = wireandcabletotal
        self.pipesandfittingtotal = pipesandfittingtotal
        self.mcbanddbtotal = mcbanddbtotal
    }
}
