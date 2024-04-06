import MuggleMac
import SwiftUI

#if os(macOS)
@main
struct MuggleMacApp: App {
  @NSApplicationDelegateAdaptor(MacAppDelegate.self) var delegate
  var body: some Scene {
    MacRootScene(delegate: delegate)
  }
}
#elseif os(visionOS)
@main
struct MuggleVisionOSApp: App {
  @UIApplicationDelegateAdaptor(VisionOSAppDelegate.self) var delegate
  var body: some Scene {
    VisionOSRootScene(delegate: delegate)
  }
}
#endif
