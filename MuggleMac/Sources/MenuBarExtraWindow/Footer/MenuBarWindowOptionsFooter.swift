import SwiftUI

struct MenuBarWindowOptionsFooter: View {

  @State private var isHovering = false

  var body: some View {
    HStack(spacing: 30) {
      QuitButton()
        .opacity(isHovering ? 0.8 : 0)
      OnboardingLaunchAtLoginToggle()
      OpenSettingsWindowButton()
    }
    .font(.callout)
    .foregroundStyle(isHovering ? .primary : .tertiary)
    .frame(maxWidth: .infinity, alignment: .trailing)
    .padding(.horizontal, 20)
    .padding(.bottom)
    .animation(.linear.speed(1.5), value: isHovering)
    .contentShape(.rect)
    .onHover { isHovering = $0 }
    .buttonStyle(.borderless)
  }
}
