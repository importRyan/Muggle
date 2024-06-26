import SwiftUI

#if DEBUG
#Preview {
  SettingsWindowContent()
}
#endif

struct SettingsWindow: Scene {
  static let id = "settings"

  let delegate: MacAppDelegate

  var body: some Scene {
    // Workaround for window toolbar customization
    Window("Muggle Settings", id: SettingsWindow.id) {
      SettingsWindowContent()
        .padding()
        .environmentObject(delegate)
    }
  }
}

private struct SettingsWindowContent: View {

  var body: some View {
    VStack(spacing: 25) {
      HStack(alignment: .top, spacing: 50) {
        VStack(spacing: 20) {
          AboutTheApp()

          GitHubButton()
            .frame(square: 22)
        }
        VStack(alignment: .leading) {
          AppSettings()
            .frame(maxHeight: .infinity, alignment: .top)
          TipMeBox()
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
      }
    }
    .toolbar {
      SendSuggestionButton()
      Color.clear
      ReportBugButton()
    }
    .padding()
    .padding()
  }
}
