// swift-tools-version: 5.10

import PackageDescription

let package = Package(
  name: "MuggleCore",
  defaultLocalization: "en",
  platforms: [.macOS(.v14), .visionOS(.v1)],
  products: [
    .library(name: "Common",targets: ["Common"]),
    .library(name: "CommonUI",targets: ["CommonUI"]),
    .library(name: "EmberBluetooth",targets: ["EmberBluetooth"]),
    .library(name: "MuggleBluetooth",targets: ["MuggleBluetooth"]),
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-collections", from: Version(1, 1, 0)),
    .package(url: "https://github.com/NordicSemiconductor/IOS-CoreBluetooth-Mock/", from: Version(0, 18, 0)),
    .package(url: "https://github.com/importRyan/Oklab", from: Version(1, 1, 2)),
  ],
  targets: [
    .target(
      name: "Common",
      dependencies: [
        .product(name: "CoreBluetoothMock", package: "IOS-CoreBluetooth-Mock"),
      ]
    ),
    .target(
      name: "CommonUI",
      dependencies: [
        "Common",
        .product(name: "Oklab", package: "Oklab"),
      ]
    ),
    .target(
      name: "EmberBluetooth",
      dependencies: [
        "Common",
        .product(name: "Collections", package: "swift-collections"),
      ]
    ),
    .target(
      name: "MuggleBluetooth",
      dependencies: [
        "Common",
        "EmberBluetooth",
        "VFZOBluetooth",
        .product(name: "Collections", package: "swift-collections"),
      ]
    ),
    .testTarget(
      name: "MuggleBluetoothTests",
      dependencies: ["MuggleBluetooth"]
    ),
    .target(
      name: "VFZOBluetooth",
      dependencies: [
        "Common",
        .product(name: "Collections", package: "swift-collections"),
      ]
    ),
  ]
)
