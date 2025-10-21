// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "VeiloKit",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    products: [
        // Products define the executables and libraries a package produces
        .library(
            name: "VeiloKit",
            targets: ["VeiloKit"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on
        .package(url: "https://github.com/gumob/PunycodeSwift.git", from: "2.1.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package
        .target(
            name: "VeiloKit",
            dependencies: [
                .product(name: "Punycode", package: "PunycodeSwift")
            ],
            path: "Sources/VeiloKit",
            resources: [
                .copy("ContentBlocker/Resources")
            ]
        )
    ]
)

