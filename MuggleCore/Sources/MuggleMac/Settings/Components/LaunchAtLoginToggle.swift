#if canImport(ServiceManagement)
import Common
import Combine
import ServiceManagement
import SwiftUI

struct LaunchAtLoginToggle: View {
  @StateObject private var launchAtLogin = LaunchAtLoginViewModel()

  var body: some View {
    HStack {
      Toggle(
        "Start on boot",
        isOn: .init(
          get: { launchAtLogin.isLaunchingAtLogin },
          set: { _ in launchAtLogin.toggle() }
        )
      )
      if launchAtLogin.requiresSystemPreferencesAction {
        Button("Open Preferences") { launchAtLogin.openPreferences() }
          .buttonBorderShape(.capsule)
          .buttonStyle(.borderedProminent)
          .controlSize(.small)
      }
    }
    .onAppear(perform: launchAtLogin.refresh)
  }
}

@MainActor
final class LaunchAtLoginViewModel: ObservableObject {
  @Published var isLaunchingAtLogin = false
  @Published var requiresSystemPreferencesAction = false
}

extension LaunchAtLoginViewModel {
  func toggle() {
    refresh()

    if isLaunchingAtLogin {
      Task { @MainActor in
        await unregister()
        refresh()
      }
      return
    }

    if requiresSystemPreferencesAction {
      SMAppService.openSystemSettingsLoginItems()
      return
    }

    register()
  }

  func refresh() {
    Log.app.info("SMAppService \(SMAppService.mainApp.status.rawValue)")
    switch SMAppService.mainApp.status {
    case .enabled:
      isLaunchingAtLogin = true
    case .notFound:
      isLaunchingAtLogin = false
      Log.app.error("SMSAppService notFound")
    case .notRegistered:
      isLaunchingAtLogin = false
    case .requiresApproval:
      isLaunchingAtLogin = false
      requiresSystemPreferencesAction = true
    @unknown default:
      Log.app.error("SMSAppService unknown status")
    }
  }

  func openPreferences() {
    SMAppService.openSystemSettingsLoginItems()
  }
}

private extension LaunchAtLoginViewModel {
  func register() {
    do {
      try SMAppService.mainApp.register()
      isLaunchingAtLogin = true
    } catch {
      Log.app.error("SMAppService register \(error.localizedDescription)")
    }
  }

  func unregister() async {
    do {
      try await SMAppService.mainApp.unregister()
      isLaunchingAtLogin = false
    } catch {
      isLaunchingAtLogin = false
      Log.app.error("SMAppService unregister \(error.localizedDescription)")
    }
  }
}
#endif
