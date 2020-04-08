//
//  GetAllAttendanceData.swift
//  HrApp
//
//  Created by Goldmedal on 2/5/20.
//  Copyright © 2020 Goldmedal. All rights reserved.
//

import Foundation

struct GetAllAttendanceElement : Codable {
    let version : String?
    let statusCode : Int?
    let statusCodeMessage : String?
    let timestamp : String?
    let size : Int?
    let data : [GetAllAttendanceData]?
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
        data = try values.decodeIfPresent([GetAllAttendanceData].self, forKey: .data)
        errors = try values.decodeIfPresent([ErrorsData].self, forKey: .errors)
    }

}

struct GetAllAttendanceData : Codable {
     let date : String?
     let firstIn : String?
     let lastOut : String?
     let totalHours : String?
     let punchInPunchOut : String?
     let statusPunch : String?
     let type : String?

    enum CodingKeys: String, CodingKey {
        
        case date = "Date"
        case firstIn = "FirstIn"
        case lastOut = "LastOut"
        case totalHours = "TotalHours"
        case punchInPunchOut = "PunchIn_PunchOut"
        case statusPunch = "status"
        case type = "Type"
     
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        date = try values.decodeIfPresent(String.self, forKey: .date)
        firstIn = try values.decodeIfPresent(String.self, forKey: .firstIn)
        lastOut = try values.decodeIfPresent(String.self, forKey: .lastOut)
        totalHours = try values.decodeIfPresent(String.self, forKey: .totalHours)
        punchInPunchOut = try values.decodeIfPresent(String.self, forKey: .punchInPunchOut)
        statusPunch = try values.decodeIfPresent(String.self, forKey: .statusPunch)
        type = try values.decodeIfPresent(String.self, forKey: .type)
    }
    
    init(date: String, firstIn: String, lastOut: String, totalHours: String, punchInPunchOut: String,statusPunch: String, type: String) {
           self.date = date
           self.firstIn = firstIn
           self.lastOut = lastOut
           self.totalHours = totalHours
           self.punchInPunchOut = punchInPunchOut
           self.statusPunch = statusPunch
           self.type = type
       }

}
