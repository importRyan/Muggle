import Common
import SwiftUI

public extension ControlSize {
  var points: CGFloat {
    switch self {
    case .mini: return 18
    case .small: return 20
    case .regular: return 25
    case .large: return 30
    case .extraLarge: return 35
    @unknown default:
      Log.app.warning("controlSize unknown case")
      return 25
    }
  }
}
