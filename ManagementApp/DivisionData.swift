//
//  DivisionData.swift
//  DealorsApp
//
//  Created by Goldmedal on 4/21/18.
//  Copyright © 2018 Goldmedal. All rights reserved.
//

import Foundation

struct DivisionElement: Codable {
    let result: Bool
    let message, servertime: String
    let data: [DivisionArray]
}

struct DivisionArray: Codable {
    let division, amount: String
}

class DivisionData {
    
    
    
}
