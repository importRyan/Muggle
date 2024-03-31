import SwiftUI

struct GlassInset: ViewModifier {
  var tint: Color = .clear
  func body(content: Content) -> some View {
    content
      .padding()
      .background(
        LinearGradient(
          colors: [tint.opacity(0.08), tint.opacity(0)],
          startPoint: .topLeading,
          endPoint: .bottom
        )
      )
      .background(.ultraThinMaterial, in: .rect(cornerRadius: 10))
      .overlay { RoundedRectangle(cornerRadius: 10).strokeBorder(.white.opacity(0.1), lineWidth: 0.5) }
      .compositingGroup()
      .shadow(color: .black.opacity(0.3), radius: 5, x: 1, y: 1)
  }
}
