import Common
import SwiftUI

struct AuthorizeBluetoothView: View {

  var body: some View {
    VStack(spacing: 12) {
      Image(systemName: "antenna.radiowaves.left.and.right")
        .font(.largeTitle)

      Text("Grant Bluetooth permissions to find nearby Ember mugs")
        .multilineTextAlignment(.center)

      // TODO: - VisionOS
      #if os(macOS)
      Button("Open Settings") {
        if let url = URL.settingsPrivacyBluetooth, NSWorkspace.shared.open(url) { return }
        if let url = URL.settingsPrivacy, NSWorkspace.shared.open(url) { return }
        if let url = URL.settingsSecurity, NSWorkspace.shared.open(url) { return }
        Log.app.error("Invalid open settings URLs")
      }
      .keyboardShortcut(.defaultAction)
      #endif
    }
    .padding(20)
  }
}

#if os(macOS)
extension URL {
  static let settingsPrivacy = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy")
  static let settingsPrivacyBluetooth = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Bluetooth")
  static let settingsSecurity = URL(string: "x-apple.systempreferences:com.apple.preference.security")
}
#endif
