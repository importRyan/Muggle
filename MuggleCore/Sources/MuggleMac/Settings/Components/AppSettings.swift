import SwiftUI

struct AppSettings: View {
  @StateObject var launchAtLogin = LaunchAtLoginViewModel()

  var body: some View {
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
  }
}
