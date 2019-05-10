//
//  TeamZone.swift
//  PerfectTemplate
//
//  Created by virus1994 on 2019/4/17.
//

import PerfectLib
import PerfectHTTP
import PerfectHTTPServer
import StarCraftMatchCore

struct ZoneTeamDelRequest: Codable {
    var teamid : Int
    var zoneid : Int
}

struct TeamDelRequest: Codable {
    var teamid : [Int]
}

struct TeamAddRequest: Codable {
    var name: String
    var manager: String
    var teamid : Int
    var zone : Int
}

struct ZoneAddRequest: Codable {
    var name : String
    var zone : String
}

struct TeamItem: Codable {
    var name : String
    var uid : Int
    var manager : String
    
    static func convert(team: Team) -> TeamItem {
        let z = TeamItem(name: team.name, uid: team.id, manager: team.mananger)
        return z
    }
}

struct TeamList: Codable {
    var list : [TeamItem]
    
    static func convert(teams: [Team]) -> TeamList {
        let z = TeamList(list: teams.map({
            let i = TeamItem.convert(team: $0)
            return i
        }))
        return z
    }
}

struct ZoneItem: Codable {
    var name : String
    var uid : Int
    var team : [TeamItem]
    
    static func convert(zone: Zone) -> ZoneItem {
        let z = ZoneItem(name: zone.name, uid: zone.id, team: [])
        return z
    }
}

struct ZoneList: Codable {
    var list : [ZoneItem]
   
    static func convert(zone: [Zone]) -> ZoneList {
        let z = zone.map({ x -> ZoneItem in
            var zitem = ZoneItem.convert(zone: x)
            let tz = TeamInZone()
            let pack = tz.request(teamInZone: x.id)
            zitem.team = pack?.values.map({ y in
                TeamItem.convert(team: y.team)
            }) ?? []
            return zitem
        })
        return ZoneList(list: z)
    }
}

struct ZoneResponse: APIResponse {
    var code: Int
    var msg: String
    var data: ZoneList
}

struct TeamResponse: APIResponse {
    var code: Int
    var msg: String
    var data: TeamList
}
/// 添加战队，当teamid不为0时，为添加已有战队，否则需要指定赛区、管理员创建后添加
///
/// - Parameters:
///   - request: http请求
///   - response: http响应
func teamAddHandler(request: HTTPRequest, response: HTTPResponse) {
    // Respond with a simple message.
    response.setHeader(.contentType, value: "application/json")
    // Ensure that response.completed() is called when your processing is done.
    
    guard let contentType = request.header(HTTPRequestHeader.Name.contentType), contentType == "application/json" else {
       jsonErrorMaker(response: response)
        return
    }
    
    guard let json: TeamAddRequest = parser(request: request) else {
        jsonErrorMaker(response: response)
        return
    }
    
    if json.teamid != 0 {
        save(zoneTeamPack: (json.zone, [json.teamid]), completion: { (ok) in
            if ok {
                saveSuccessMaker(response: response)
            }   else    {
                saveErrorMaker(response: response)
            }
        })
        return
    }
    
    save(team: json.name, manager: json.manager) { (isSuccess) in
        if isSuccess {
            do {
                let team = Team()
                try team.find([("name", json.name)])
                save(zoneTeamPack: (json.zone, [team.id]), completion: { (ok) in
                    if ok {
                        saveSuccessMaker(response: response)
                    }   else    {
                        saveErrorMaker(response: response)
                    }
                })
                
            }   catch   {
                log(error: error.localizedDescription)
                saveErrorMaker(response: response)
            }
        }   else    {
            saveErrorMaker(response: response)
        }
    }
}

/// 添加赛区，目前赛区只有名字，后续可能有其他数据
///
/// - Parameters:
///   - request: http请求
///   - response: http响应
func zoneAddHandler(request: HTTPRequest, response: HTTPResponse) {
    // Respond with a simple message.
    response.setHeader(.contentType, value: "application/json")
    // Ensure that response.completed() is called when your processing is done.
    
    guard let contentType = request.header(HTTPRequestHeader.Name.contentType), contentType == "application/json" else {
        jsonErrorMaker(response: response)
        return
    }
    
    guard let json: ZoneAddRequest = parser(request: request) else {
        jsonErrorMaker(response: response)
        return
    }
    
    save(zone: json.name) { (isSuccess) in
        if isSuccess {
            saveSuccessMaker(response: response)
        }   else    {
            saveErrorMaker(response: response)
        }
    }
}

/// 获取所有有效赛区
///
/// - Parameters:
///   - request: http请求
///   - response: http响应
func zoneAllHandler(request: HTTPRequest, response: HTTPResponse) {
    // Respond with a simple message.
    response.setHeader(.contentType, value: "application/json")
    // Ensure that response.completed() is called when your processing is done.
    
    guard let contentType = request.header(HTTPRequestHeader.Name.contentType), contentType == "application/json" else {
        jsonErrorMaker(response: response)
        return
    }
    
    let zones = read(zoneState: 1)
    let res = ZoneResponse(code: ResponseErrorCode.ok.rawValue, msg: "", data: ZoneList.convert(zone: zones))
    do {
        try response.setBody(json: res)
    }   catch   {
        log(error: error.localizedDescription)
        try! response.setBody(json: EmptyResponse())
    }
    response.completed()
}

/// 获取所有有效战队
///
/// - Parameters:
///   - request: http请求
///   - response: http响应
func teamAllHandler(request: HTTPRequest, response: HTTPResponse) {
    // Respond with a simple message.
    response.setHeader(.contentType, value: "application/json")
    // Ensure that response.completed() is called when your processing is done.
    
    guard let contentType = request.header(HTTPRequestHeader.Name.contentType), contentType == "application/json" else {
        jsonErrorMaker(response: response)
        return
    }
    
    let teams = read(teamState: 1)
    let res = TeamResponse(code: ResponseErrorCode.ok.rawValue, msg: "", data: TeamList.convert(teams: teams))
    do {
        try response.setBody(json: res)
    }   catch   {
        log(error: error.localizedDescription)
         try! response.setBody(json: EmptyResponse())
    }
    response.completed()
}

/// 删除一个或多个战队，使用战队id
///
/// - Parameters:
///   - request: http请求
///   - response: http响应
func teamDeleteHandler(request: HTTPRequest, response: HTTPResponse) {
    // Respond with a simple message.
    response.setHeader(.contentType, value: "application/json")
    // Ensure that response.completed() is called when your processing is done.
    
    guard let contentType = request.header(HTTPRequestHeader.Name.contentType), contentType == "application/json" else {
        jsonErrorMaker(response: response)
        return
    }
    
    guard let json: TeamDelRequest = parser(request: request) else {
        jsonErrorMaker(response: response)
        return
    }
    
    remove(teamsID: json.teamid) { (isSuccess) in
        if isSuccess {
            saveSuccessMaker(response: response)
        }   else    {
            saveErrorMaker(response: response)
        }
    }
}

/// 删除一个或多个赛区，使用赛区id
///
/// - Parameters:
///   - request: http请求
///   - response: http响应
func zoneDeleteHandler(request: HTTPRequest, response: HTTPResponse) {
    // Respond with a simple message.
    response.setHeader(.contentType, value: "application/json")
    // Ensure that response.completed() is called when your processing is done.
    
    guard let contentType = request.header(HTTPRequestHeader.Name.contentType), contentType == "application/json" else {
        jsonErrorMaker(response: response)
        return
    }
    
    guard let json: TeamDelRequest = parser(request: request) else {
        jsonErrorMaker(response: response)
        return
    }
    
    remove(zonesID: json.teamid) { (isSuccess) in
        if isSuccess {
            saveSuccessMaker(response: response)
        }   else    {
            saveErrorMaker(response: response)
        }
    }
}

func zonevTeamDeleteHandler(request: HTTPRequest, response: HTTPResponse) {
    // Respond with a simple message.
    response.setHeader(.contentType, value: "application/json")
    // Ensure that response.completed() is called when your processing is done.
    
    guard let contentType = request.header(HTTPRequestHeader.Name.contentType), contentType == "application/json" else {
        jsonErrorMaker(response: response)
        return
    }
    
    guard let json: ZoneTeamDelRequest = parser(request: request) else {
        jsonErrorMaker(response: response)
        return
    }
    
    remove(teamID: json.teamid, zoneID: json.zoneid) { (isSuccess) in
        if isSuccess {
            saveSuccessMaker(response: response)
        }   else    {
            saveErrorMaker(response: response)
        }
    }
}
