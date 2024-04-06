import MuggleBluetooth
import SwiftUI
#if os(visionOS)
    public struct VisionOSRootScene: Scene {

  public init(delegate: VisionOSAppDelegate) {
    self.central = delegate.central
  }

  package init(central: BluetoothCentral) {
    self.central = central
  }

  private let central: BluetoothCentral

  public var body: some Scene {
    WindowGroup {
      MenuBarWindow(central: central)
    }
  }
}
#endif
