import SwiftUI

#if os(macOS)
import MuggleMac

@main
struct MuggleMacApp: App {
  @NSApplicationDelegateAdaptor(MacAppDelegate.self) var delegate
  var body: some Scene {
    MacRootScene(delegate: delegate)
  }
}

#elseif os(visionOS)
import MuggleVision

@main
struct MuggleVisionOSApp: App {
  @UIApplicationDelegateAdaptor(VisionOSAppDelegate.self) var delegate
  var body: some Scene {
    VisionOSRootScene(delegate: delegate)
  }
}
#endif
