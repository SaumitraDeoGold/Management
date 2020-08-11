//
//  TodSalesData.swift
//  GStar
//
//  Created by Goldmedal on 18/04/20.
//  Copyright © 2020 Goldmedal. All rights reserved.
//

import Foundation

struct TodSalesElement : Codable {
    let result : Bool?
    let message : String?
    let servertime : String?
    let data : [TodSalesData]?

    enum CodingKeys: String, CodingKey {

        case result = "result"
        case message = "message"
        case servertime = "servertime"
        case data = "data"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        result = try values.decodeIfPresent(Bool.self, forKey: .result)
        message = try values.decodeIfPresent(String.self, forKey: .message)
        servertime = try values.decodeIfPresent(String.self, forKey: .servertime)
        data = try values.decodeIfPresent([TodSalesData].self, forKey: .data)
    }

}


struct TodSalesData : Codable {
    let dealernm : String?
    let cin : String?
    let qtytarget : String?
    let qtysale : String?
    let qtyshortamt : String?
    let curmnthtarget : String?
    let curmnthsale : String?
    let curmnthshortamt : String?
    let isaccepted : Int?

    enum CodingKeys: String, CodingKey {

        case dealernm = "dealernm"
        case cin = "cin"
        case qtytarget = "qtytarget"
        case qtysale = "qtysale"
        case qtyshortamt = "qtyshortamt"
        case curmnthtarget = "curmnthtarget"
        case curmnthsale = "curmnthsale"
        case curmnthshortamt = "curmnthshortamt"
        case isaccepted = "isaccepted"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        dealernm = try values.decodeIfPresent(String.self, forKey: .dealernm)
        cin = try values.decodeIfPresent(String.self, forKey: .cin)
        qtytarget = try values.decodeIfPresent(String.self, forKey: .qtytarget)
        qtysale = try values.decodeIfPresent(String.self, forKey: .qtysale)
        qtyshortamt = try values.decodeIfPresent(String.self, forKey: .qtyshortamt)
        curmnthtarget = try values.decodeIfPresent(String.self, forKey: .curmnthtarget)
        curmnthsale = try values.decodeIfPresent(String.self, forKey: .curmnthsale)
        curmnthshortamt = try values.decodeIfPresent(String.self, forKey: .curmnthshortamt)
        isaccepted = try values.decodeIfPresent(Int.self, forKey: .isaccepted)
    }

}
