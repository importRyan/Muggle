import SwiftUI

struct TipMeBox: View {
  var body: some View {
    GroupBox {
      LabeledContent {
        Text("[Send a small 🙏](https://www.buymeacoffee.com/ryanferrell) or [hire me](https://www.linkedin.com/in/ryanpferrell)")
      } label: {
        Text("Enjoying the app?")
      }
      .padding()
    }
    .labeledContentStyle(StackedLabeledContentStyle())
  }
}
