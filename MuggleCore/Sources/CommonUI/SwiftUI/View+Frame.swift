import SwiftUI

public extension View {
  func frame(square: CGFloat, alignment: Alignment = .center) -> some View {
    frame(width: square, height: square, alignment: alignment)
  }
}
