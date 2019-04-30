//
//  Request.swift
//  PerfectTemplate
//
//  Created by virus1994 on 2019/4/17.
//

import PerfectLib
import PerfectHTTP
import PerfectLogger
import StarCraftMatchCore

protocol JSONRegisterName {
    func registerName() -> String
}

class APIRequest: JSONConvertibleObject, JSONRegisterName {
    func registerName() -> String { return "" }
}

/// 解析json数据，返回值是APIRequest子类
///
/// - Parameters:
///   - request: http请求
///   - type: APIRequest子类
/// - Returns: APIRequest子类实例，转换失败则返回nil
func parser<T: APIRequest>(request: HTTPRequest, type: T.Type) -> T? {
    do {
        guard let json = try request.postBodyString?.jsonDecode() as? T else {
            return nil
        }
        return json
    } catch {
        log(error: error.localizedDescription)
        return nil
    }
}

/// 初始化请求设置
func requestConfig() {
    let items: [APIRequest] = [ZoneAddRequest(), TeamAddRequest(), TeamDelRequest(), ZoneTeamDelRequest(), MatchBatchAddRequest(), TeamMatch(), PlayerMatch(), MTeam(), Player()]
    items.forEach({ x in
        JSONDecoding.registerJSONDecodable(name: x.registerName(), creator: { return x })
    })
}
