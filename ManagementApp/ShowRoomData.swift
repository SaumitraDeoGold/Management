//
//  ShowRoomData.swift
//  DealorsApp
//
//  Created by Goldmedal on 15/11/18.
//  Copyright © 2018 Goldmedal. All rights reserved.
//


import Foundation



struct ShowRoomElement: Codable {
    let result: Bool?
    let message, servertime: String?
    let data: [ShowRoomData]
}

struct ShowRoomData: Codable {
    let name, address, area, city: String?
    let state, country: String?
    let image: String?
}

