import MuggleBluetooth
import SwiftUI

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
