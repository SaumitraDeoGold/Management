//
//  Dispatch.swift
//  DealorsApp
//
//  Created by Rahul Bangde on 19/08/18.
//  Copyright © 2018 Goldmedal. All rights reserved.
//

struct DispatchedMaterialElement: Decodable {
    let result: Bool?
    let message, servertime: String?
    let data: [DispatchedMaterialData]
}

struct DispatchedMaterialData: Decodable {
    let dispatchdata: [DispatchedMaterialObject]
    let ismore: Bool?
}

struct DispatchedMaterialObject: Decodable {
    let invoiceNo, invoiceDate: String?
    let division: String?
    let amount, lrNo: String?
    let transporterName: String?
    let url: String?
}
