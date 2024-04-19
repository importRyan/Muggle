import SwiftUI

struct AboutTheApp: View {

#if DEBUG
  @State private var showExporter = false
  @State private var exportedItems: URL?
#endif

  var body: some View {
    VStack(spacing: 30) {
      AnimatedAppIcon.AboutAppGlowingVariant(fields: .inAppVariant)
#if DEBUG
        .onTapGesture {
          Task { @MainActor in
            exportedItems = await renderMacOSIcons()
            showExporter = true
          }
        }
        .fileMover(isPresented: $showExporter, file: exportedItems) { result in }
#endif

      Text("Muggle is an open source, privacy-friendly alternative to apps by Bluetooth smart mug manufacturers.")
        .lineLimit(nil)
        .lineSpacing(2)
        .font(.caption)
        .multilineTextAlignment(.center)
        .frame(width: CachedStarFields.inAppVariant.size)
        .fixedSize(horizontal: false, vertical: true)
    }
  }
}

extension CachedStarFields {
  static let inAppVariant = CachedStarFields(size: 140.0)
}
