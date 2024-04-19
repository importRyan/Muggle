import Common
import SwiftUI

struct DeviceLabelView: View {
  let mug: BluetoothMug

  var body: some View {
    HStack(spacing: 10) {
      DeviceLEDView(viewModel: .init(mug: mug))
      Text(mug.name)
        .font(.body.weight(.medium))
      DeviceWriteActivityIndicatorView(viewModel: .init(mug: mug))
        .controlSize(.small)
    }
  }
}
