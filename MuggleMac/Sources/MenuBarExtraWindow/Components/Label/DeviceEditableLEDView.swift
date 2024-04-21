import Common
import CommonUI
import Combine
import MuggleBluetooth
import SwiftUI

struct DeviceEditableLEDView: View {
  let mug: BluetoothMug

  @State private var isHoveringOnLED = false
  @State private var presentEditor = false

  var body: some View {
    DeviceLEDView(viewModel: .init(mug: mug))
      .animation(.smooth) {
        $0.scaleEffect(isHoveringOnLED ? 1.1 : 1)
      }
      .onHover { isHoveringOnLED = $0 }
      .onTapGesture(perform: showEditor)
      .contextMenu {
        Button("Change LED", action: showEditor)
      }
      .popover(
        isPresented: $presentEditor,
        attachmentAnchor: .point(.leading),
        arrowEdge: .leading
      ) {
        LEDEditor(viewModel: .init(mug: mug))
          .padding()
      }
  }

  private func showEditor() {
    presentEditor = true
  }
}
