//
//  TotalSaleDivisionWise.swift
//  G-Management
//
//  Created by Goldmedal on 08/03/19.
//  Copyright © 2019 Goldmedal. All rights reserved.
//

import Foundation
struct TotalSale: Codable {
    let result: Bool?
    let message, servertime: String?
    let data: [TotalSaleobj]
}

struct TotalSaleobj: Codable {
    let saledetails: [Saledetail]
    let saledetailsTotal: SaledetailsTotal
    let ismore: Bool?
}

struct Saledetail: Codable { 
    let partynm, cin, exnm, wiringdevices, lights, partystatus: String?
    let wireandcable, pipesandfittings, mcbanddbs: String?
}

struct SaledetailsTotal: Codable {
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
