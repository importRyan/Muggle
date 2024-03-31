import SwiftUI

struct GitHubButton: View {

  @Environment(\.openURL) private var openURL
  static let url = URL(string: "https://www.github.com/importRyan/Muggle")

  var body: some View {
    Button(
      action: {
        guard let url = Self.url else { return }
        openURL(url)
      },
      label: {
        Image(.gitHub)
          .resizable()
          .scaledToFit()
      }
    )
    .buttonStyle(.borderless)
  }
}
