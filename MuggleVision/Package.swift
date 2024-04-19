// swift-tools-version: 5.10
import PackageDescription

let package = Package(
  name: "MuggleVision",
  platforms: [.visionOS(.v1)],
  products: [
    .library(name: "MuggleVision", targets: ["MuggleVision"]),
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-collections", from: Version(1, 1, 0)),
    .package(path: "../MuggleCore")
  ],
  targets: [
    .target(
      name: "MuggleVision",
      path: "Sources"
    ),
  ]
)
