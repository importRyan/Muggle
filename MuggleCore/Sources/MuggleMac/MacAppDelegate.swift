import MuggleBluetooth
import SwiftUI
#if os(macOS)
public final class MacAppDelegate: NSObject {
  package lazy private(set) var central = BluetoothCentral(
    knownPeripheralsStore: .live(store: UserDefaults.standard)
  )
}

extension MacAppDelegate: NSApplicationDelegate {
  public func applicationDidFinishLaunching(_ notification: Notification) {
    central.setup()
  }

  public func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    false
  }
}
#endif
