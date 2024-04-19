import SwiftUI

struct NoDevicesInstructionsView: View {
  var body: some View {
    VStack(spacing: 12) {
      Image(systemName: "mug.fill")
        .font(.largeTitle)

      Text("Finding nearby Ember mugs")

      Text("To pair a mug, press its bottom button until the LED pulses blue.")
        .multilineTextAlignment(.center)
        .foregroundStyle(.secondary)
    }
    .padding(20)
  }
}
