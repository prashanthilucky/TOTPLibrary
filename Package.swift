// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TOTPLibrary",
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "TOTPLibrary",
            targets: ["TOTPLibrary"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
       
        .package(url: "https://github.com/sean7512/RestEssentials.git", from: "5.2.0"),
        
        .package(url: "https://github.com/apple/swift-crypto.git", .upToNextMajor(from: "1.0.0")),
        
        .package(url: "https://github.com/krzyzanowskim/CryptoSwift.git", .upToNextMinor(from: "1.3.8"))
        
        
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "TOTPLibrary",
            dependencies: []),
        .testTarget(
            name: "TOTPLibraryTests",
            dependencies: ["TOTPLibrary"]),
    ]
)
