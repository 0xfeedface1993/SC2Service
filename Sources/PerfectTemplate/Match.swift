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
import StORM

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
    
    func convertToStorm() -> Match? {
        guard let a = find(team: self.teama.name, lpname: String(self.teama.page.split(separator: "/").last ?? "").replacingOccurrences(of: "_", with: " ")),
            let b = find(team: self.teamb.name, lpname: String(self.teamb.page.split(separator: "/").last ?? "").replacingOccurrences(of: "_", with: " ")) else {
                log(error: "Not found team: \(self.teama.name), \(self.teamb.name)")
                return nil
        }
        
        let match = Match()
        
        do {
            try match.find([("playera", "\(a.id)"), ("playerb", "\(b.id)"), ("utcTime", "\(utcTime)"), ("type", "\(0)")])
            if match.id != 0 {
                log(message: "Found team match: \(match.id)")
                return nil
            }
            match.playera = a.id
            match.playerb = b.id
            match.event = self.event
            match.page = self.page
            match.utcTime = self.utcTime
            match.type = 0
            return match
        } catch {
            match.playera = a.id
            match.playerb = b.id
            match.event = self.event
            match.page = self.page
            match.utcTime = self.utcTime
            match.type = 0
            return match
        }
    }
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
    
    func convertToStorm() -> Match? {
        guard let a = find(player: self.playera.name, race: self.playera.race, nation: self.playera.nation),
            let b = find(player: self.playerb.name, race: self.playerb.race, nation: self.playerb.nation), a.id != 0, b.id != 0 else {
                log(error: "Not found player: \(self.playera.name), \(self.playerb.name)")
                return nil
        }
        
        let match = Match()
        
        do {
            try match.find([("playera", "\(a.id)"), ("playerb", "\(b.id)"), ("utcTime", "\(utcTime)"), ("type", "\(1)")])
            if match.id != 0 {
                log(message: "Found player match: \(match.id)")
                return nil
            }
            
            match.playera = a.id
            match.playerb = b.id
            match.racea = self.playera.race
            match.raceb = self.playerb.race
            match.event = self.event
            match.page = self.page
            match.utcTime = self.utcTime
            match.type = 1
            return match
        } catch {
            match.playera = a.id
            match.playerb = b.id
            match.racea = self.playera.race
            match.raceb = self.playerb.race
            match.event = self.event
            match.page = self.page
            match.utcTime = self.utcTime
            match.type = 1
            return match
        }
    }
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
//    for i in json.teams {
//        let pagea = i.teama.page.split(separator: "/").last ?? ""
//        let pageb = i.teamb.page.split(separator: "/").last ?? ""
//        let suffixa = String(pagea).replacingOccurrences(of: "_", with: " ")
//        let suffixb = String(pageb).replacingOccurrences(of: "_", with: " ")
//
//        guard let at = find(team: i.teama.name, lpname: suffixa), let bt = find(team: i.teamb.name, lpname: suffixb) else {
//            continue
//        }
//
//        print(at)
//        print(bt)
//    }
//
    
    let players = json.players.map({ $0.convertToStorm() }).filter({ $0 != nil })
    let teams = json.teams.map({ $0.convertToStorm() }).filter({ $0 != nil })
    
    for i in players {
        do {
            try i?.save(set: { (id) in
                i?.id = id as! Int
            })
        }   catch   {
            log(error: "Save \(i?.page ?? "") failed!")
        }
    }
    
    for j in teams {
        do {
            try j?.save(set: { (id) in
                j?.id = id as! Int
            })
        }   catch   {
            log(error: "Save \(j?.page ?? "") failed!")
        }
    }
    
    saveSuccessMaker(response: response)
}

func todayMatchHandler(request: HTTPRequest, response: HTTPResponse) {
    // Respond with a simple message.
    
    let matches = Match()
    do {
        try matches.findAll()
        let rows = matches.rows()
        let teams = rows.filter({ $0.type == 0 }).map({ row -> Match.MatchGroupResult? in
            let x = PGroup()
            let y = PGroup()
            do {
                try x.get(row.playera)
                try y.get(row.playerb)
                let match = Match.MatchGroupResult(a: x.transformResult(), b: y.transformResult(), id: row.id, type: row.type, raceA: row.racea, raceB: row.raceb, page: row.page, event: row.event, utc: row.utcTime)
                return match
            }   catch   {
                log(error: "Read \(row.playera), \(row.playerb) failed: \(error.localizedDescription)")
                return nil
            }
        }).filter({ $0 != nil }).map({ $0! })
        let players = rows.filter({ $0.type == 1 }).map({ row -> Match.MatchPlayerResult? in
            let x = PPlayer()
            let y = PPlayer()
            do {
                try x.get(row.playera)
                try y.get(row.playerb)
                return Match.MatchPlayerResult(a: x.transformResult(), b: y.transformResult(), id: row.id, type: row.type, raceA: row.racea, raceB: row.raceb, page: row.page, event: row.event, utc: row.utcTime)
            }   catch   {
                log(error: "Read \(row.playera), \(row.playerb) failed: \(error.localizedDescription)")
                return nil
            }
        }).filter({ $0 != nil }).map({ $0! })
        
        let res = MatchResponse(code: ResponseErrorCode.ok.rawValue, msg: "", data: MatchBind(teams: teams, players: players))
        response.setHeader(.contentType, value: "application/json")
        try! response.setBody(json: res)
        response.completed()
        //select(whereclause: "utcTime >= $0", params: [""], orderby: ["utcTime"])
    } catch {
        log(error: error.localizedDescription)
    
        let res = EmptyArrayResponse()
        response.setHeader(.contentType, value: "application/json")
        try! response.setBody(json: res)
        response.completed()
    }
}

struct MatchBind: Codable {
    var teams : [Match.MatchGroupResult]
    var players : [Match.MatchPlayerResult]
}

struct MatchResponse: APIResponse {
    var code : Int
    var msg : String
    var data : MatchBind
}
