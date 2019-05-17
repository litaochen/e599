// swift-tools-version:4.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    // 1
    name: "Server",
    dependencies: [
        .package(url: "https://github.com/IBM-Swift/Kitura.git",
                 .upToNextMajor(from: "2.0.0")),
        .package(url: "https://github.com/IBM-Swift/HeliumLogger.git",
                 .upToNextMajor(from: "1.0.0")),
        .package(url: "https://github.com/OpenKitten/MongoKitten.git", from: "5.0.0"),
        .package(url: "https://github.com/OpenKitten/BSON.git", .upToNextMajor(from: "6.0.4")),
        .package(url: "https://github.com/weichsel/ZIPFoundation/", .upToNextMajor(from: "0.9.9")),
        .package(url: "https://github.com/IBM-Swift/Kitura-CORS.git", from: "2.1.1")
    ],
    //5
    targets: [
        .target(name: "Server",
                dependencies: ["Kitura" , "HeliumLogger", "MongoKitten", "BSON", "ZIPFoundation", "KituraCORS"],
                path: "Sources")
    ]
)
