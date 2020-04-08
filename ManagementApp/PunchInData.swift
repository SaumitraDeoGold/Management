//
//  PunchInData.swift
//  HrApp
//
//  Created by Goldmedal on 1/31/20.
//  Copyright © 2020 Goldmedal. All rights reserved.
//

import Foundation
struct PunchInDataElement : Codable {
    let version : String?
    let statusCode : Int?
    let statusCodeMessage : String?
    let timestamp : String?
    let size : Int?
    let data : [PunchInData]?
    let errors : [ErrorsData]?

    enum CodingKeys: String, CodingKey {
        case version = "Version"
        case statusCode = "StatusCode"
        case statusCodeMessage = "StatusCodeMessage"
        case timestamp = "Timestamp"
        case size = "Size"
        case data = "Data"
        case errors = "Errors"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        version = try values.decodeIfPresent(String.self, forKey: .version)
        statusCode = try values.decodeIfPresent(Int.self, forKey: .statusCode)
        statusCodeMessage = try values.decodeIfPresent(String.self, forKey: .statusCodeMessage)
        timestamp = try values.decodeIfPresent(String.self, forKey: .timestamp)
        size = try values.decodeIfPresent(Int.self, forKey: .size)
        data = try values.decodeIfPresent([PunchInData].self, forKey: .data)
        errors = try values.decodeIfPresent([ErrorsData].self, forKey: .errors)
    }

}

struct PunchInData : Codable {
    let punchInTime : String?
    let punchOutTime : String?
    let totalWorkingHours : String?
    let punchInLocation : String?
    let punchOutLocation : String?

    enum CodingKeys: String, CodingKey {
        case punchInTime = "PunchInTime"
        case punchOutTime = "PunchOutTime"
        case totalWorkingHours = "TotalWorkingHours"
        case punchInLocation = "PunchInLocation"
        case punchOutLocation = "PunchOutLocation"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        punchInTime = try values.decodeIfPresent(String.self, forKey: .punchInTime)
        punchOutTime = try values.decodeIfPresent(String.self, forKey: .punchOutTime)
        totalWorkingHours = try values.decodeIfPresent(String.self, forKey: .totalWorkingHours)
        punchInLocation = try values.decodeIfPresent(String.self, forKey: .punchInLocation)
        punchOutLocation = try values.decodeIfPresent(String.self, forKey: .punchOutLocation)
    }

}
