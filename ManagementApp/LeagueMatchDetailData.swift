//
//  LeagueMatchDetailData.swift
//  DealorsApp
//
//  Created by Goldmedal on 4/12/19.
//  Copyright © 2019 Goldmedal. All rights reserved.
//

import Foundation

struct LeagueMatchDetailElement: Codable {
    let result: Bool?
    let message, servertime: String?
    let data: [LeagueMatchDetailObj]
}

struct LeagueMatchDetailObj: Codable {
    let matchsummaryid: Int?
    let event: String?
    let team1id, team2id: Int?
    let team1, team2, matchDate, matchTime: String?
    let team1point, team2point: Double?
    let winnerlock: Bool?
    let winnerteam: String?
    var othetplay,team1selected,team2selected,prediction: Bool?
    let othetplayteam: String?
    let team1per, team2per: Int?
    let venue,result: String?
    let othetplayteamid, winnerlockteamid, selectedteam : Int?
   
}
