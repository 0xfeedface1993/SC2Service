//
//  main.swift
//  PerfectTemplate
//
//  Created by Kyle Jessup on 2015-11-05.
//	Copyright (C) 2015 PerfectlySoft, Inc.
//
//===----------------------------------------------------------------------===//
//
// This source file is part of the Perfect.org open source project
//
// Copyright (c) 2015 - 2016 PerfectlySoft Inc. and the Perfect project authors
// Licensed under Apache License v2.0
//
// See http://perfect.org/licensing.html for license information
//
//===----------------------------------------------------------------------===//
//

import PerfectHTTP
import PerfectHTTPServer
import StarCraftMatchCore

// An example request handler.
// This 'handler' function can be referenced directly in the configuration below.
func handler(request: HTTPRequest, response: HTTPResponse) {
	// Respond with a simple message.
	response.setHeader(.contentType, value: "text/html")
	response.appendBody(string: "<html><title>Hello, world!</title><body>Hello, world!</body></html>")
	// Ensure that response.completed() is called when your processing is done.
	response.completed()
}

// Configure one server which:
//    * Serves the hello world message at <host>:<port>/
//    * Serves static files out of the "./webroot"
//        directory (which must be located in the current working directory).
//    * Performs content compression on outgoing data when appropriate.
var routes = Routes()
routes.add(method: .post, uri: "/api/v1/addTeam", handler: teamAddHandler)
routes.add(method: .post, uri: "/api/v1/addZone", handler: zoneAddHandler)
routes.add(method: .post, uri: "/api/v1/allZone", handler: zoneAllHandler)
routes.add(method: .post, uri: "/api/v1/allTeam", handler: teamAllHandler)
routes.add(method: .post, uri: "/api/v1/delTeam", handler: teamDeleteHandler)
routes.add(method: .post, uri: "/api/v1/delZone", handler: zoneDeleteHandler)
routes.add(method: .post, uri: "/api/v1/delZonevTeam", handler: zonevTeamDeleteHandler)
routes.add(method: .post, uri: "/api/v1/matchBatchLoad", handler: matchBatchHandler)
routes.add(method: .get, uri: "/api/v1/currentMatch", handler: todayMatchHandler)

routes.add(method: .get, uri: "/", handler: handler)
routes.add(method: .get, uri: "/**",
           handler: StaticFileHandler(documentRoot: "./webroot", allowResponseFilters: true).handleRequest)

configDatabase()
configurePostgresDB() 
requestConfig()
responseConfig()

Match.removeAllRecord()

try HTTPServer.launch(name: "localhost",
                      port: 8181,
                      routes: routes,
                      responseFilters: [
                        (PerfectHTTPServer.HTTPFilter.contentCompression(data: [:]), HTTPFilterPriority.high)])

