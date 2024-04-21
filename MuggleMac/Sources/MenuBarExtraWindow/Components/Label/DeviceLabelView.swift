import Common
import MuggleBluetooth
import SwiftUI

#if DEBUG
#Preview {
  DeviceLabelView(
    mug: MockBluetoothMug().connected()
  )
}
#endif

struct DeviceLabelView: View {
  let mug: BluetoothMug

  var body: some View {
    HStack(spacing: 10) {
      DeviceEditableLEDView(mug: mug)

      Text(mug.name)
        .font(.body.weight(.medium))

      DeviceWriteActivityIndicatorView(viewModel: .init(mug: mug))
        .controlSize(.small)
    }
  }
}
