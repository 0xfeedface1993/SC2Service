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

class MTeam: APIRequest {
    override func registerName() -> String { return "request-match-team" }
    var name: String = ""
    var page: String = ""
    var image: String = ""
    
    override func setJSONValues(_ values: [String : Any]) {
        self.name = getJSONValue(named: "name", from: values, defaultValue: "")
        self.page = getJSONValue(named: "page", from: values, defaultValue: "")
        self.image = getJSONValue(named: "image", from: values, defaultValue: "")
    }
    
    override func getJSONValues() -> [String : Any] {
        return [
            JSONDecoding.objectIdentifierKey:registerName(),
            "image":image,
            "page":page,
            "name":name
        ]
    }
}

class TeamMatch: APIRequest {
    override func registerName() -> String { return "request-match-teammatch" }
    var teama: MTeam = MTeam()
    var teamb: MTeam = MTeam()
    var page: String = ""
    var event: String = ""
    var utcTime: UInt32 = 0
    
    override func setJSONValues(_ values: [String : Any]) {
        self.teama = getJSONValue(named: "teama", from: values, defaultValue: MTeam())
        self.teamb = getJSONValue(named: "teamb", from: values, defaultValue: MTeam())
        self.page = getJSONValue(named: "page", from: values, defaultValue: "")
        self.event = getJSONValue(named: "event", from: values, defaultValue: "")
        self.utcTime = getJSONValue(named: "utcTime", from: values, defaultValue: 0)
    }
    
    override func getJSONValues() -> [String : Any] {
        return [
            JSONDecoding.objectIdentifierKey:registerName(),
            "teama":teama.getJSONValues(),
            "teamb":teamb.getJSONValues(),
            "page":page,
            "event":event,
            "utcTime":utcTime,
        ]
    }
}

class Player: APIRequest {
    override func registerName() -> String { return "request-match-player" }
    var name: String = ""
    var page: String = ""
    var race: String = ""
    var nation: String = ""
    
    override func setJSONValues(_ values: [String : Any]) {
        self.name = getJSONValue(named: "name", from: values, defaultValue: "")
        self.page = getJSONValue(named: "page", from: values, defaultValue: "")
        self.race = getJSONValue(named: "race", from: values, defaultValue: "")
        self.nation = getJSONValue(named: "nation", from: values, defaultValue: "")
    }
    
    override func getJSONValues() -> [String : Any] {
        return [
            JSONDecoding.objectIdentifierKey:registerName(),
            "race":race,
            "page":page,
            "name":name,
            "nation":nation
        ]
    }
}

class PlayerMatch: APIRequest {
    override func registerName() -> String { return "request-match-playermatch" }
    var playera: Player = Player()
    var playerb: Player = Player()
    var page: String = ""
    var event: String = ""
    var utcTime: UInt32 = 0
    
    override func setJSONValues(_ values: [String : Any]) {
        self.playera = getJSONValue(named: "playera", from: values, defaultValue: Player())
        self.playerb = getJSONValue(named: "playerb", from: values, defaultValue: Player())
        self.page = getJSONValue(named: "page", from: values, defaultValue: "")
        self.event = getJSONValue(named: "event", from: values, defaultValue: "")
        self.utcTime = getJSONValue(named: "utcTime", from: values, defaultValue: 0)
    }
    
    override func getJSONValues() -> [String : Any] {
        return [
            JSONDecoding.objectIdentifierKey:registerName(),
            "playera":playera.getJSONValues(),
            "playerb":playerb.getJSONValues(),
            "page":page,
            "event":event,
            "utcTime":utcTime,
        ]
    }
}

class MatchBatchAddRequest: APIRequest {
    override func registerName() -> String { return "request-match-b-add" }
    var teams : [TeamMatch] = [TeamMatch]()
    var players : [PlayerMatch] = [PlayerMatch]()
    
    override func setJSONValues(_ values: [String : Any]) {
        self.teams = getJSONValue(named: "teams", from: values, defaultValue: [TeamMatch]())
        self.players = getJSONValue(named: "players", from: values, defaultValue: [PlayerMatch]())
    }
    
    override func getJSONValues() -> [String : Any] {
        return [
            JSONDecoding.objectIdentifierKey:registerName(),
            "teams":teams.map({ $0.getJSONValues() }),
            "players":players.map({ $0.getJSONValues() })
        ]
    }
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
    
    guard let json = parser(request: request, type: MatchBatchAddRequest.self) else {
        jsonErrorMaker(response: response)
        return
    }
    
//    for i in json.players {
//        print("a: \(find(player: i.playera.name, race: i.playera.race, nation: i.playera.nation))")
//        print("b: \(find(player: i.playerb.name, race: i.playerb.race, nation: i.playerb.nation))")
//    }
    
//    for i in json.teams {
//        let suffix = String(i.teama.page.split(separator: "/").last!).replacingOccurrences(of: "_", with: " ")
//        print("\(find(team: i.teama.name, lpname: suffix))")
//    }
    
    
    saveSuccessMaker(response: response)
}
