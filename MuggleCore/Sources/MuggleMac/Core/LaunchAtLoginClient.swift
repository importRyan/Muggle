#if canImport(ServiceManagement)
import Common
import Combine
import ServiceManagement

enum LaunchingAtLoginState {
  case isLaunching
  case isNotLaunching
  case isNotLaunchingAndRequiresUserIntervention

  var isLaunching: Bool {
    if case .isLaunching = self { true } else { false }
  }

  var isNotLaunching: Bool {
    !isLaunching
  }

  var requiresUserIntervention: Bool {
    if case .isNotLaunchingAndRequiresUserIntervention = self { true } else { false }
  }
}

@MainActor
class LaunchAtLoginClient: ObservableObject {
  @Published var state = LaunchingAtLoginState.isNotLaunching
}

extension LaunchAtLoginClient {
  func toggle() {
    refresh()

    if state.isLaunching {
      Task { @MainActor in
        await unregister()
        refresh()
      }
      return
    }

    if state.requiresUserIntervention {
      SMAppService.openSystemSettingsLoginItems()
      return
    }

    register()
  }

  func refresh() {
    Log.app.info("SMAppService \(SMAppService.mainApp.status.debugDescription)")
    switch SMAppService.mainApp.status {
    case .enabled:
      state = .isLaunching
    case .notFound:
      state = .isNotLaunching
      Log.app.error("SMSAppService notFound")
    case .notRegistered:
      state = .isNotLaunching
    case .requiresApproval:
      state = .isNotLaunchingAndRequiresUserIntervention
    @unknown default:
      state = .isNotLaunchingAndRequiresUserIntervention
      Log.app.error("SMSAppService unknown status")
    }
  }

  func openPreferences() {
    SMAppService.openSystemSettingsLoginItems()
  }
}

private extension LaunchAtLoginClient {
  func register() {
    do {
      try SMAppService.mainApp.register()
      state = .isLaunching
    } catch {
      Log.app.error("SMAppService register \(error.localizedDescription)")
    }
  }

  func unregister() async {
    do {
      try await SMAppService.mainApp.unregister()
      state = .isNotLaunching
    } catch {
      state = .isNotLaunching
      Log.app.error("SMAppService unregister \(error.localizedDescription)")
    }
  }
}

extension SMAppService.Status: CustomDebugStringConvertible {
  public var debugDescription: String {
    switch self {
    case .enabled: "enabled"
    case .notFound: "notFound(ProgrammerError)"
    case .notRegistered: "notRegistered"
    case .requiresApproval: "requiresApproval(UserIntervention)"
    @unknown default: "unknown"
    }
  }
}
#endif
