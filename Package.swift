// swift-tools-version:4.2
// Generated automatically by Perfect Assistant
// Date: 2019-04-09 08:17:42 +0000
import PackageDescription

let package = Package(
	name: "StartCraftMatch",
	products: [
		.executable(name: "PerfectTemplate", targets: ["PerfectTemplate"])
	],
	dependencies: [
		.package(url: "https://github.com/0xfeedface1993/StarCraftMatchCore.git", from: "0.1.1")
	],
	targets: [
		.target(name: "PerfectTemplate", dependencies: ["StarCraftMatchCore"])
	]
)
