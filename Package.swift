// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SafariContentBlockerKit",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    products: [
        // Products define the executables and libraries a package produces
        .library(
            name: "SafariContentBlockerKit",
            targets: ["SafariContentBlockerKit"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on
        .package(url: "https://github.com/gumob/PunycodeSwift.git", from: "2.1.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package
        .target(
            name: "SafariContentBlockerKit",
            dependencies: [
                .product(name: "Punycode", package: "PunycodeSwift")
            ],
            path: "Sources/SafariContentBlockerKit",
            resources: [
                .copy("ContentBlocker/Resources")
            ]
        )
    ]
)

