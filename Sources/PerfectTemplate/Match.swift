//
//  Match.swift
//  PerfectTemplate
//
//  Created by virus1994 on 2019/4/26.
//

import PerfectLib
import PerfectHTTP
import PerfectHTTPServer
import StarCraftMatchCore

struct MTeam: Codable {
    var name: String
    var page: String
    var image: String
}

struct TeamMatch: Codable {
    var teama: MTeam
    var teamb: MTeam
    var page: String
    var event: String
    var utcTime: UInt32
}

struct Player: Codable {
    var name: String
    var page: String
    var race: String
    var nation: String
}

struct PlayerMatch: Codable {
    var playera: Player
    var playerb: Player
    var page: String
    var event: String
    var utcTime: UInt32
}

struct MatchBatchAddRequest: Codable {
    var teams : [TeamMatch]
    var players : [PlayerMatch]
}

/// 添加最近比赛，含战队赛和个人赛
///
/// - Parameters:
///   - request: http请求
///   - response: http响应
func matchBatchHandler(request: HTTPRequest, response: HTTPResponse) {
    // Respond with a simple message.
    response.setHeader(.contentType, value: "application/json")
    // Ensure that response.completed() is called when your processing is done.
    
    guard let contentType = request.header(HTTPRequestHeader.Name.contentType), contentType == "application/json" else {
        jsonErrorMaker(response: response)
        return
    }
    
    guard let json: MatchBatchAddRequest = parser(request: request) else {
        jsonErrorMaker(response: response)
        return
    }
    
    
//    for i in json.players {
//        print("a: \(find(player: i.playera.name, race: i.playera.race, nation: i.playera.nation))")
//        print("b: \(find(player: i.playerb.name, race: i.playerb.race, nation: i.playerb.nation))")
//    }
    
    for i in json.teams {
        let pagea = i.teama.page.split(separator: "/").last ?? ""
        let pageb = i.teamb.page.split(separator: "/").last ?? ""
        let suffixa = String(pagea).replacingOccurrences(of: "_", with: " ")
        let suffixb = String(pageb).replacingOccurrences(of: "_", with: " ")
        
        guard let at = find(team: i.teama.name, lpname: suffixa), let bt = find(team: i.teamb.name, lpname: suffixb) else {
            continue
        }
        
        print(at)
        print(bt)
    }
    
    
    saveSuccessMaker(response: response)
}
