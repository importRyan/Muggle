#if os(macOS)
import Common
import MuggleBluetooth
import SwiftUI

public final class MacAppDelegate: NSObject, ObservableObject {
  package lazy private(set) var central = BluetoothCentral(
    knownPeripheralsStore: .live(store: localStorage)
  )
  let localStorage: KeyValueStore = UserDefaults.standard
}

extension MacAppDelegate: NSApplicationDelegate {
  public func applicationDidFinishLaunching(_ notification: Notification) {
    localStorage[.launches, default: 0] &+= 1
    Log.app.info("Launch #\(self.localStorage[.launches, default: 0])")
    central.setup()
  }

  public func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    false
  }
}
#endif
