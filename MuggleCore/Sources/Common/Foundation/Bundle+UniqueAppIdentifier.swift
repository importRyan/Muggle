import Foundation

package extension Bundle {
  var uniqueAppIdentifier: String { bundleIdentifier ?? "com.roastingapps.muggle" }
}
