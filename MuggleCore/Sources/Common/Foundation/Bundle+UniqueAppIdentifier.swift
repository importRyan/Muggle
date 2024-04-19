import Foundation

public extension Bundle {
  var uniqueAppIdentifier: String { bundleIdentifier ?? "com.roastingapps.muggle" }
}
