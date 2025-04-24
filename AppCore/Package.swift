// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "AppCore",
  platforms: [
    .iOS(.v17),
    .macOS(.v14),
  ],
  products: [
    // Products define the executables and libraries a package produces, making them visible to other packages.
    .library(
      name: "AppCore",
      targets: ["AppCore"]
    ),
    .library(
      name: "DataStore",
      targets: ["DataStore"]
    ),
  ],
  dependencies: [
    .package(url: "https://github.com/weichsel/ZIPFoundation.git", .upToNextMajor(from: "0.9.0"))
  ],
  targets: [
    // Targets are the basic building blocks of a package, defining a module or a test suite.
    // Targets can depend on other targets in this package and products from dependencies.
    .target(
      name: "AppCore",
      dependencies: [
        "DataStore",
        "ZIPFoundation"
      ]
    ),
    .target(
      name: "DataStore",
      dependencies: []
    ),
    .testTarget(
      name: "AppCoreTests",
      dependencies: ["AppCore"]
    ),
    .testTarget(
      name: "DataStoreTests",
      dependencies: ["DataStore"]
    ),
  ]
)
