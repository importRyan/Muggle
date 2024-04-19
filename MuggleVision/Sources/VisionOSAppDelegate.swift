import Common
import MuggleBluetooth
import SwiftUI

public final class VisionOSAppDelegate: NSObject {
  package lazy var localStorage: KeyValueStore = UserDefaults.standard
  package lazy private(set) var central = BluetoothCentral(
    knownPeripheralsStore: .live(store: localStorage)
  )
}

extension VisionOSAppDelegate: UIApplicationDelegate {
  public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    localStorage[.launches, default: 0] &+= 1
    Log.app.info("Launch #\(self.localStorage[.launches, default: 0])")
    central.setup()
    return true
  }
}
