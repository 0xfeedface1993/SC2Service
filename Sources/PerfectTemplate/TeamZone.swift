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

class ZoneTeamDelRequest: APIRequest {
    override func registerName() -> String { return "request-zt-del" }
    var teamid : Int = 0
    var zoneid : Int = 0
    
    override func setJSONValues(_ values: [String : Any]) {
        self.teamid = getJSONValue(named: "teamid", from: values, defaultValue: 0)
        self.zoneid = getJSONValue(named: "zoneid", from: values, defaultValue: 0)
    }
    
    override func getJSONValues() -> [String : Any] {
        return [
            JSONDecoding.objectIdentifierKey:registerName(),
            "teamid":teamid,
            "zoneid":zoneid
        ]
    }
}

class TeamDelRequest: APIRequest {
    override func registerName() -> String { return "request-team-del" }
    var teamid = [Int]()
    
    override func setJSONValues(_ values: [String : Any]) {
        self.teamid = getJSONValue(named: "teamid", from: values, defaultValue: [])
    }
    
    override func getJSONValues() -> [String : Any] {
        return [
            JSONDecoding.objectIdentifierKey:registerName(),
            "teamid":teamid
        ]
    }
}

class TeamAddRequest: APIRequest {
    override func registerName() -> String { return "request-team-add" }
    var name = ""
    var manager = ""
    var teamid : Int = 0
    var zone : Int = 0
    
    override func setJSONValues(_ values: [String : Any]) {
        self.name = getJSONValue(named: "name", from: values, defaultValue: "")
        self.zone = getJSONValue(named: "zone", from: values, defaultValue: 0)
        self.teamid = getJSONValue(named: "teamid", from: values, defaultValue: 0)
        self.manager = getJSONValue(named: "manager", from: values, defaultValue: "")
    }
    
    override func getJSONValues() -> [String : Any] {
        return [
            JSONDecoding.objectIdentifierKey:registerName(),
            "name":name,
            "zone":zone,
            "manager":manager,
            "teamid":teamid
        ]
    }
}

class ZoneAddRequest: APIRequest {
    override func registerName() -> String { return "request-zone-add" }
    var name = ""
    var zone = ""
    
    override func setJSONValues(_ values: [String : Any]) {
        self.name = getJSONValue(named: "name", from: values, defaultValue: "")
        self.zone = getJSONValue(named: "zone", from: values, defaultValue: "")
    }
    
    override func getJSONValues() -> [String : Any] {
        return [
            JSONDecoding.objectIdentifierKey:registerName(),
            "name":name,
            "zone":zone
        ]
    }
}

class TeamItem: APIRequest {
    override func registerName() -> String { return "request-team-item" }
    var name = ""
    var uid = 0
    var manager = ""
    
    override func setJSONValues(_ values: [String : Any]) {
        self.name = getJSONValue(named: "name", from: values, defaultValue: "")
        self.manager = getJSONValue(named: "manager", from: values, defaultValue: "")
        self.uid = getJSONValue(named: "id", from: values, defaultValue: 0)
    }
    
    override func getJSONValues() -> [String : Any] {
        return [
            JSONDecoding.objectIdentifierKey:registerName(),
            "name":name,
            "id":uid,
            "manager":manager
        ]
    }
    
    static func convert(team: Team) -> TeamItem {
        let z = TeamItem()
        z.name = team.name
        z.uid = team.id
        z.manager = team.mananger
        return z
    }
}

class TeamList: APIRequest {
    override func registerName() -> String { return "request-team-list" }
    var list = [TeamItem]()
    
    override func setJSONValues(_ values: [String : Any]) {
        self.list = getJSONValue(named: "list", from: values, defaultValue: [])
    }
    
    override func getJSONValues() -> [String : Any] {
        return [
            JSONDecoding.objectIdentifierKey:registerName(),
            "list":list.map({ $0.getJSONValues() })
        ]
    }
    
    static func convert(teams: [Team]) -> TeamList {
        let z = TeamList()
        z.list = teams.map({
            let i = TeamItem.convert(team: $0)
            return i
        })
        return z
    }
}

class ZoneItem: APIRequest {
    override func registerName() -> String { return "request-zone-item" }
    var name = ""
    var uid = 0
    var team = [TeamItem]()
    
    override func setJSONValues(_ values: [String : Any]) {
        self.name = getJSONValue(named: "name", from: values, defaultValue: "")
        self.uid = getJSONValue(named: "id", from: values, defaultValue: 0)
        self.team = getJSONValue(named: "team", from: values, defaultValue: [])
    }
    
    override func getJSONValues() -> [String : Any] {
        return [
            JSONDecoding.objectIdentifierKey:registerName(),
            "name":name,
            "id":uid,
            "team": team.map({ $0.getJSONValues() })
        ]
    }
    
    static func convert(zone: Zone) -> ZoneItem {
        let z = ZoneItem()
        z.name = zone.name
        z.uid = zone.id
        return z
    }
}

class ZoneList: APIRequest {
    override func registerName() -> String { return "request-zone-list" }
    var list = [ZoneItem]()
    
    override func setJSONValues(_ values: [String : Any]) {
        self.list = getJSONValue(named: "list", from: values, defaultValue: [])
    }
    
    override func getJSONValues() -> [String : Any] {
        return [
            JSONDecoding.objectIdentifierKey:registerName(),
            "list":list.map({ $0.getJSONValues() })
        ]
    }
    
    static func convert(zone: [Zone]) -> ZoneList {
        let z = ZoneList()
        z.list = zone.map({
            let tz = TeamInZone()
            let pack = tz.request(teamInZone: $0.id)
            let i = ZoneItem.convert(zone: $0)
            i.team = pack?.values.map({
                TeamItem.convert(team: $0.team)
                
            }) ?? []
            return i
        })
        return z
    }
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
    
    guard let json = parser(request: request, type: TeamAddRequest.self) else {
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
    
    guard let json = parser(request: request, type: ZoneAddRequest.self) else {
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
    let res = APIResponse()
    res.code = ResponseErrorCode.ok.rawValue
    res.msg = ""
    res.data = ZoneList.convert(zone: zones)
    do {
        try response.setBody(json: res)
    }   catch   {
        log(error: error.localizedDescription)
        res.data = nil
        try! response.setBody(json: res)
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
    let res = APIResponse()
    res.code = ResponseErrorCode.ok.rawValue
    res.msg = ""
    res.data = TeamList.convert(teams: teams)
    do {
        try response.setBody(json: res)
    }   catch   {
        log(error: error.localizedDescription)
        res.data = nil
        try! response.setBody(json: res)
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
    
    guard let json = parser(request: request, type: TeamDelRequest.self) else {
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
    
    guard let json = parser(request: request, type: TeamDelRequest.self) else {
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
    
    guard let json = parser(request: request, type: ZoneTeamDelRequest.self) else {
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
