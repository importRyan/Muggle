import MuggleMac
import SwiftUI

@main
struct MuggleMacApp: App {
  @NSApplicationDelegateAdaptor(MacAppDelegate.self) var delegate
  var body: some Scene {
    MacRootScene(delegate: delegate)
  }
}
