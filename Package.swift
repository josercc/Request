// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import Foundation

let urlForAlamofire:String
let urlForCleanJSON:String
if let value = ProcessInfo.processInfo.environment["isGiteeMirror"],
   let isGiteeMirror = Bool(value),
   isGiteeMirror {
    urlForAlamofire = "https://gitee.com/mirrors/alamofire.git"
    urlForCleanJSON = "https://gitee.com/daveeapp/CleanJSON.git"
} else {
    urlForAlamofire = "https://github.com/Alamofire/Alamofire.git"
    urlForCleanJSON = "https://github.com/Pircate/CleanJSON.git"
}

let package = Package(
    name: "Request",
    platforms: [
        .iOS(.v10)
    ],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "Request",
            targets: ["Request"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(name:"Alamofire", url: urlForAlamofire, from: "5.0.0"),
        .package(url: urlForCleanJSON, from: "1.0.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "Request",
            dependencies: ["Alamofire","CleanJSON"]),
        .testTarget(
            name: "RequestTests",
            dependencies: ["Request"]),
    ]
)
