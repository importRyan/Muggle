import MuggleBluetooth
import SwiftUI

public struct MacRootScene: Scene {

  public init(delegate: MacAppDelegate) {
    self.delegate = delegate
  }

  private let delegate: MacAppDelegate

  public var body: some Scene {
    MenuBarExtraScene(delegate: delegate)
    SettingsWindow(delegate: delegate)
  }
}
