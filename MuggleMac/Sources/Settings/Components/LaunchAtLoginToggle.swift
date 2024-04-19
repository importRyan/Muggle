import SwiftUI

struct LaunchAtLoginToggle: View {
  @EnvironmentObject var delegate: MacAppDelegate

  var body: some View {
    Contents(client: delegate.launchAtLogin)
  }

  struct Contents: View {
    @ObservedObject var client: LaunchAtLoginClient

    var body: some View {
      HStack {
        Toggle(
          "Start on boot",
          isOn: .init(
            get: { client.state.isLaunching },
            set: { _ in client.toggle() }
          )
        )
        if client.state.requiresUserIntervention {
          Button("Open Preferences", action: client.openPreferences)
            .buttonBorderShape(.capsule)
            .buttonStyle(.borderedProminent)
            .controlSize(.small)
        }
      }
    }
  }
}
