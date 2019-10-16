//
//  TODData.swift
//  DealorsApp
//
//  Created by Goldmedal on 6/1/19.
//  Copyright © 2019 Goldmedal. All rights reserved.
//

import Foundation
struct TODElement: Codable {
    let result: Bool?
    let message, servertime: String?
    let data: [TODObj]
}

// MARK: - Datum
struct TODObj: Codable {
    let groupName, groupId, yearlyTargetAmt, yearlySalesAmt: String?
    let q1amt, q2amt, q3amt, q4amt: String?
    let apramt, mayamt, junamt, julamt: String?
    let augamt, sepamt, octamt, novamt: String?
    let decamt, janamt, febamt, maramt: String?
    let q1amts, q2amts, q3amts, q4amts: String?
    let apramts, mayamts, junamts, julamts: String?
    let augamts, sepamts, octamts, novamts: String?
    let decamts, janamts, febamts, maramts: String?
    let yearlytradeSale, q1tradesale, q2tradesale, q3tradesale: String?
    let q4tradesale, aprtradesale, maytradesale, juntradesale: String?
    let jultradesale, augtradesale, septradesale, octtradesale: String?
    let novtradesale, dectradesale, jantradesale, febtradesale: String?
    let martradesale, yearlyprojectSale, q1projectsale, q2projectsale: String?
    let q3projectsale, q4projectsale, aprprojectsale, mayprojectsale: String?
    let junprojectsale, julprojectsale, augprojectsale, sepprojectsale: String?
    let octprojectsale, novprojectsale, decprojectsale, janprojectsale: String?
    let febprojectsale, marprojectsale, yearlyearnedAmt, q1earnedamt: String?
    let q2earnedamt, q3earnedamt, q4earnedamt, aprearnedamt: String?
    let mayearnedamt, junearnedamt, julearnedamt, augearnedamt: String?
    let sepearnedamt, octearnedamt, novearnedamt, decearnedamt: String?
    let janearnedamt, febearnedamt, marearnedamt: String?
    let isAccept: Bool?
    var groupImage: String?
}

