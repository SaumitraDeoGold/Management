//
//  MatchSummaryDetailData.swift
//  DealorsApp
//
//  Created by Goldmedal on 4/25/19.
//  Copyright © 2019 Goldmedal. All rights reserved.
//

import Foundation
struct MatchDetailSummaryElement: Codable {
    let result: Bool?
    let message, servertime: String?
    let data: [MatchDetailObj]
}

struct MatchDetailObj: Codable {
    let detail: [DetailObj]
    let img: [ImgArr]
}

struct DetailObj: Codable {
    let partyName: String?
    let chancesToWin, sale, chancesToWinper, saleper, amountEarned, amountEarnedPer: String?
    let matchWon, matchLost: String?
    let matchBal: String?
    let pdfurl: String?
    let totalmatch: String?
}

struct Img: Codable {
    let imgurl: String?
}


struct ImgArr: Codable {
    let imgurl: String?
}
