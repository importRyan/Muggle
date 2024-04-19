// swift-tools-version: 5.10
import PackageDescription

let package = Package(
  name: "MuggleVision",
  platforms: [.visionOS(.v1)],
  products: [
    .library(name: "MuggleVision", targets: ["MuggleVision"]),
  ],
  dependencies: [
    .package(path: "../MuggleCore")
  ],
  targets: [
    .target(
      name: "MuggleVision",
      dependencies: [
        .product(name: "Common", package: "MuggleCore"),
        .product(name: "CommonUI", package: "MuggleCore"),
        .product(name: "MuggleBluetooth", package: "MuggleCore"),
      ],
      path: "Sources"
    ),
  ]
)
