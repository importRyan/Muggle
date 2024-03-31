import MuggleBluetooth
import SwiftUI

public struct MacRootScene: Scene {

  public init(delegate: MacAppDelegate) {
    self.central = delegate.central
  }

  package init(central: BluetoothCentral) {
    self.central = central
  }

  private let central: BluetoothCentral

  public var body: some Scene {
    MenuBarExtraScene(central: central)
    SettingsWindow()
  }
}
