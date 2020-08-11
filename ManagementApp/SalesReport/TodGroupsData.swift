//
//  TodGroupsData.swift
//  GStar
//
//  Created by Goldmedal on 18/04/20.
//  Copyright © 2020 Goldmedal. All rights reserved.
//

import Foundation

struct TodGroupsElement : Codable {
    let result : Bool?
    let message : String?
    let servertime : String?
    let data : [TodGroupsData]?

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
        data = try values.decodeIfPresent([TodGroupsData].self, forKey: .data)
    }

}

struct TodGroupsData : Codable {
    let groupid : String?
    let groupnm : String?

    enum CodingKeys: String, CodingKey {

        case groupid = "groupid"
        case groupnm = "groupnm"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        groupid = try values.decodeIfPresent(String.self, forKey: .groupid)
        groupnm = try values.decodeIfPresent(String.self, forKey: .groupnm)
    }

}
