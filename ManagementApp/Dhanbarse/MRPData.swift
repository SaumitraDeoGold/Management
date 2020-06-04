//
//  MRPData.swift
//  ManagementApp
//
//  Created by Goldmedal on 23/04/20.
//  Copyright © 2020 Goldmedal. All rights reserved.
//

import Foundation
struct MRPData: Codable {
    let result: Bool?
    let message, servertime: String?
    let data: [MRPDataObj]
}

// MARK: - Datum
struct MRPDataObj: Codable {
    let mpRid: Int?
    let mprRequestNO, requestedby, requestedDesignation, requestedDate: String?
    let requiredDate: JSONNull?
    let positionTitle, noPosition, budget, employeeType: String?
    let location, description, natureOfRequest, ageRange: String?
    let status, gender, previousEmployeeName, previousEmployeeDesignation: String?
    let educationRequirement, preferedQualificationExprienece, replacementReason, department: String?
    let subDaeprtment: String? 
}

class JSONNull: Codable, Hashable {

    public static func == (lhs: JSONNull, rhs: JSONNull) -> Bool {
        return true
    }

    public var hashValue: Int {
        return 0
    }

    public init() {}

    public required init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if !container.decodeNil() {
            throw DecodingError.typeMismatch(JSONNull.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for JSONNull"))
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encodeNil()
    }
}
