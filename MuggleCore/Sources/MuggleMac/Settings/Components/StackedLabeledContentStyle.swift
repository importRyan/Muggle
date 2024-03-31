import Common
import SwiftUI

struct StackedLabeledContentStyle: LabeledContentStyle {
  @Environment(\.multilineTextAlignment) private var textAlignment
  func makeBody(configuration: Configuration) -> some View {
    VStack(alignment: textAlignment.horizontal, spacing: 8) {
      configuration.label
        .fontWeight(.semibold)
      configuration.content
    }
  }
}
