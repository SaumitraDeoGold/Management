//
//  DashboardCatSalesView.swift
//  DealorsApp
//
//  Created by Goldmedal on 8/30/18.
//  Copyright © 2018 Goldmedal. All rights reserved.
//

struct SalesCategoryElement: Codable {
    let result: Bool?
    let message, servertime: String?
    let data: [SalesCategoryData]
}

struct SalesCategoryData: Codable {
    let divisionWiseSale: [DivisionWiseSaleData]
    let divisionWiseSaleTotal: [DivisionWiseSaleTotal]
}

struct DivisionWiseSaleData: Codable {
    let categorynm, sale: String?
}

struct DivisionWiseSaleTotal: Codable {
    let totalSale: String?
}
