//
//  getSpinData.swift
//  DealorsApp
//
//  Created by Goldmedal on 10/17/18.
//  Copyright © 2018 Goldmedal. All rights reserved.
//

import Foundation

struct SpinElement: Codable{
    let result: Bool?
    let message, servertime: String?
    let data: [SpinObj]
}

struct SpinObj: Codable {
    let noOfSpin, remSpin, winAmt: String?
    let slNo, nxtDrwAmt: Int?
    let active, applyCN:Bool
}
