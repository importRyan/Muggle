import SwiftUI

struct MenuBarWindowOptionsFooter: View {

  @State private var isHovering = false
  @Environment(\.openWindow) private var openWindow

  var body: some View {
    HStack(spacing: 30) {
      #if os(macOS)
      Button("Quit") {
        NSApp.terminate(nil)
      }
      .opacity(isHovering ? 0.8 : 0)

      Spacer()

      Button("Settings") {
        // Workaround: MenuBarExtra LSUIElement-launched scenes need the app to be activated otherwise existing windows won't respond to makeKeyAndOrderFront and will be lost beneath the never-ending clutter of life
        if let window = NSApp.windows.settingsWindow {
          NSApp.activate()
          window.orderFrontRegardless()
          window.makeKey()
          return
        }
        openWindow(id: SettingsWindow.id)
      }
      #endif
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

#if os(macOS)
extension [NSWindow] {
  var settingsWindow: NSWindow? {
    filter { $0.identifier?.rawValue == SettingsWindow.id }.first
  }
}
#endif
