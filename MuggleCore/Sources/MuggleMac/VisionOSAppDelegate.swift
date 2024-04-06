import MuggleBluetooth
import SwiftUI
#if os(visionOS)
public final class VisionOSAppDelegate: NSObject {
  package let central = BluetoothCentral()
}

extension VisionOSAppDelegate: UIApplicationDelegate {
  public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    central.setup()
    return true
  }
}
#endif
