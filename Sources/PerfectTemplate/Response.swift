//
//  Response.swift
//  PerfectTemplate
//
//  Created by virus1994 on 2019/4/17.
//

import PerfectLib
import PerfectHTTP

enum ResponseErrorCode: Int {
    case ok = 200
    case invalidJson = 741
    case saveFailed = 742
}

protocol APIResponse: Codable {
    associatedtype Codable
    var code : Int { get set }
    var msg : String { get set }
    var data : Codable { get set }
}

struct EmptyResponse: APIResponse {
    var code : Int = 200
    var msg : String = ""
    var data : [String:String] = [:]
}

/// api请求数据都是json数据，非jsonh格式或缺失参数则返回错误
///
/// - Parameter response: http响应
func jsonErrorMaker(response: HTTPResponse) {
    response.setHeader(.contentType, value: "application/json")
    let jsonString = try! #"{"code":"\#(ResponseErrorCode.invalidJson.rawValue)", "msg":"bad requst data"}"#.jsonDecode()
    try! response.setBody(json: jsonString)
    response.completed()
}

/// 数据保存失败，所有数据更改和保存操作失败会调用，开发者通过错误日志调试，而用户只需要只带存储出了问题
///
/// - Parameter response: http响应
func saveErrorMaker(response: HTTPResponse) {
    response.setHeader(.contentType, value: "application/json")
    let jsonString = try! #"{"code":"\#(ResponseErrorCode.saveFailed.rawValue)", "msg":"server can't save your data"}"#.jsonDecode()
    try! response.setBody(json: jsonString)
    response.completed()
}

/// 操作成功响应
///
/// - Parameter response: http响应
func saveSuccessMaker(response: HTTPResponse) {
    response.setHeader(.contentType, value: "application/json")
    let jsonString = try! #"{"code":"\#(ResponseErrorCode.ok.rawValue)", "msg":""}"#.jsonDecode()
    try! response.setBody(json: jsonString)
    response.completed()
}

func responseConfig() {
//    JSONDecoding.registerJSONDecodable(name: APIResponse.registerName, creator: { return APIResponse() })
}
