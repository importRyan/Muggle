import Common
import SwiftUI

struct SendSuggestionButton: View {
  @Environment(\.openURL) private var openURL
  var body: some View {
    Button("Suggest feature", systemImage: "lightbulb") {
      openURL(URL(email: "ryan@roastingapps.com", subject: "Muggle Suggestion: ", body: "")!)
    }
    .labelStyle(.titleAndIcon)
  }
}
