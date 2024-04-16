#if os(macOS)
import MuggleBluetooth
import SwiftUI

struct MenuBarExtraScene: Scene {
  let delegate: MacAppDelegate

  var body: some Scene {
    MenuBarExtra(
      content: { 
        MenuBarWindow(central: delegate.central)
          .environmentObject(delegate)
      },
      label: {
        MenuBarExtraIcon(viewModel: .init(central: delegate.central))
      }
    )
    .menuBarExtraStyle(.window)
  }
}
#endif
