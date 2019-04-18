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

class TeamAddRequest: APIRequest {
    override func registerName() -> String { return "request-team-add" }
    var name = ""
    var manager = ""
    var zone : Int = 0
    
    override func setJSONValues(_ values: [String : Any]) {
        self.name = getJSONValue(named: "name", from: values, defaultValue: "")
        self.zone = getJSONValue(named: "zone", from: values, defaultValue: 0)
        self.manager = getJSONValue(named: "manager", from: values, defaultValue: "")
    }
    
    override func getJSONValues() -> [String : Any] {
        return [
            JSONDecoding.objectIdentifierKey:registerName(),
            "name":name,
            "zone":zone,
            "manager":manager
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

/// 添加战队，需要指定赛区、管理员
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
    
    save(team: json.name, manager: json.manager) { (isSuccess) in
        if isSuccess {
            saveSuccessMaker(response: response)
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

//func zoneAllHandler(request: HTTPRequest, response: HTTPResponse) {
//    // Respond with a simple message.
//    response.setHeader(.contentType, value: "application/json")
//    // Ensure that response.completed() is called when your processing is done.
//    
//    guard let contentType = request.header(HTTPRequestHeader.Name.contentType), contentType == "application/json" else {
//        jsonErrorMaker(response: response)
//        return
//    }
//    
//    let zone = Zone()
//    do {
//        try zone.find([("activeState", "1")])
//        
//    }   catch {
//        log(error: error.localizedDescription)
//        
//    }
//}

