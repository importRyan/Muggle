// swift-tools-version: 5.10
import PackageDescription

let package = Package(
  name: "MuggleMac",
  defaultLocalization: "en",
  platforms: [.macOS(.v14), .visionOS(.v1)],
  products: [
    .library(name: "MuggleMac", targets: ["MuggleMac"]),
  ],
  dependencies: [
    .package(path: "../MuggleCore")
  ],
  targets: [
    .target(
      name: "MuggleMac",
      dependencies: [
        .product(name: "Common", package: "MuggleCore"),
        .product(name: "CommonUI", package: "MuggleCore"),
        .product(name: "MuggleBluetooth", package: "MuggleCore"),
      ],
      path: "Sources"
    ),
  ]
)
