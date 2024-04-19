#if canImport(ServiceManagement)
import Common
import SwiftUI

struct OnboardingLaunchAtLoginToggle: View {

  @EnvironmentObject private var delegate: MacAppDelegate

  private var isOnboarding: Bool {
    let launchCount = delegate.localStorage[.launches] ?? 0
    return launchCount <= 2
  }

  var body: some View {
    Contents(
      client: delegate.launchAtLogin,
      isOnboarding: isOnboarding
    )
  }

  struct Contents: View {
    @ObservedObject var client: LaunchAtLoginClient
    let isOnboarding: Bool

    private var showToggle: Bool {
      if isOnboarding { client.state.isNotLaunching }
      else { false }
    }

    var body: some View {
      // TODO: - Diagnose layout height for MenuBarExtraWindow when else branch is dropped in favor of parent frame control
      if showToggle {
        LaunchAtLoginToggle.Contents(client: client)
          .transition(.opacity.animation(.smooth.fast.delay(0.25)))
          .frame(maxWidth: .infinity)
      } else {
        Spacer()
      }
    }
  }
}
#endif
