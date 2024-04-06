#if os(macOS)
import MuggleBluetooth
import SwiftUI

struct MenuBarExtraScene: Scene {
  let central: BluetoothCentral

  var body: some Scene {
    MenuBarExtra(
      content: { MenuBarWindow(central: central) },
      label: { MenuBarExtraIcon(viewModel: .init(central: central)) }
    )
    .menuBarExtraStyle(.window)
  }
}
#endif
