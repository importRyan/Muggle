import SwiftUI

public extension TextAlignment {
  var horizontal: HorizontalAlignment {
    switch self {
    case .leading: .leading
    case .center: .center
    case .trailing: .trailing
    }
  }
}
