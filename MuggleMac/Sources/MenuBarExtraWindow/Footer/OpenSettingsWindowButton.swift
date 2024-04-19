import SwiftUI

struct OpenSettingsWindowButton: View {
  @Environment(\.openWindow) private var openWindow

  var body: some View {
    Button("Settings", action: openSettingsWindow)
  }

  private func openSettingsWindow() {
    // Workaround: MenuBarExtra LSUIElement-launched scenes need the app to be activated otherwise existing windows won't respond to makeKeyAndOrderFront and will be lost beneath the never-ending clutter of life
    if let window = NSApp.windows.settingsWindow {
      NSApp.activate()
      window.orderFrontRegardless()
      window.makeKey()
      return
    }
    openWindow(id: SettingsWindow.id)
  }
}

extension [NSWindow] {
  var settingsWindow: NSWindow? {
    filter { $0.identifier?.rawValue == SettingsWindow.id }.first
  }
}
