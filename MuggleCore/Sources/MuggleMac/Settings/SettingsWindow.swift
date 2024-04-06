import SwiftUI

#if DEBUG
#Preview {
  SettingsWindowContent()
}
#endif

#if os(macOS)
struct SettingsWindow: Scene {
  static let id = "settings"
  var body: some Scene {
    // Workaround for window toolbar customization
    Window("Muggle Settings", id: SettingsWindow.id) {
      SettingsWindowContent()
        .padding()
    }
  }
}
#endif

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
