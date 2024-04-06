import SwiftUI

struct AppSettings: View {
#if os(macOS)
  @StateObject var launchAtLogin = LaunchAtLoginViewModel()
#endif
  
  var body: some View {
#if os(macOS)
    VStack {
      Toggle(
        "Start on boot",
        isOn: .init(
          get: { launchAtLogin.isLaunchingAtLogin },
          set: { _ in launchAtLogin.toggle() }
        )
      )
      if launchAtLogin.requiresSystemPreferencesAction {
        Button("Open Login Items") { launchAtLogin.openPreferences() }
      }
    }
    .padding()
    .onAppear(perform: launchAtLogin.refresh)
#endif
  }
}
