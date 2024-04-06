import MuggleBluetooth
import SwiftUI
#if os(macOS)
public final class MacAppDelegate: NSObject {
  package let central = BluetoothCentral()
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
