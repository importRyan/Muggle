// swift-tools-version: 5.10
import PackageDescription

let package = Package(
  name: "MuggleMac",
  platforms: [.macOS(.v14)],
  products: [
    .library(name: "MuggleMac", targets: ["MuggleMac"]),
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-collections", from: Version(1, 1, 0)),
    .package(path: "../MuggleCore")
  ],
  targets: [
    .target(
      name: "MuggleMac",
      dependencies: [
        .product(name: "Common", package: "MuggleCore"),
        .product(name: "MuggleBluetooth", package: "MuggleCore"),
      ],
      path: "Sources"
    ),
  ]
)
