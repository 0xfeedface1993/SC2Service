// swift-tools-version:4.2
// Generated automatically by Perfect Assistant
// Date: 2019-04-11 03:48:22 +0000
import PackageDescription

let package = Package(
	name: "StartCraftMatch",
	products: [
		.executable(name: "PerfectTemplate", targets: ["PerfectTemplate"])
	],
	dependencies: [
		.package(url: "https://github.com/0xfeedface1993/SC2MatchCore.git", "0.1.4"..<"1.0.0")
	],
	targets: [
		.target(name: "PerfectTemplate", dependencies: ["StarCraftMatchCore"])
	]
)
