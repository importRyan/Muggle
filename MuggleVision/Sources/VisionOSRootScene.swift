import MuggleBluetooth
import SwiftUI

public struct VisionOSRootScene: Scene {

  public init(delegate: VisionOSAppDelegate) {
    self.central = delegate.central
  }

  private let central: BluetoothCentral

  public var body: some Scene {
    WindowGroup {
      AmbientWindow(central: central)
    }
  }
}

