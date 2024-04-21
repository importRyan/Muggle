import Combine
import Common
import MuggleBluetooth
import SwiftUI

struct BluetoothMugView: View {

  @State var isHovering = false
  let mug: BluetoothMug
  @State var viewModel: ViewModel

  var body: some View {
    HStack(alignment: .center, spacing: 20) {
      deviceInfo
      changeTemperaturePanel
    }
    .padding(20)
    .fixedSize()
    .contentShape(.rect)
    .contextMenu {
      TemperatureUnitPicker(viewModel: .init(mug: mug))
        .pickerStyle(.inline)
        .disabled(viewModel.isDisabled)
    }
    .onHover { isHovering = $0 }
  }

  private var changeTemperaturePanel: some View {
    ChangeTemperaturePanel(
      isHovering: isHovering,
      viewModel: .init(mug: mug)
    )
    .animation(.linear.speed(2)) {
      $0.opacity(isHovering && !viewModel.isDisabled ? 1 : 0.4)
    }
    .padding(.vertical, 4)
    .padding(.bottom, 2)
    .modifier(GlassInset(tint: .clear))
    .disabled(viewModel.isDisabled)
  }

  private var deviceInfo: some View {
    VStack(alignment: .leading, spacing: 5) {
      ConnectedDeviceActivityView(viewModel: .init(mug: mug))
        .frame(maxWidth: .infinity, alignment: .leading)
        .fixedSize()

      BatteryStateView(viewModel: .init(mug: mug))
        .padding(.bottom, 15)

      DeviceLabelView(mug: mug)
        .disabled(viewModel.isDisabled)
    }
  }

  @Observable
  final class ViewModel {
    private(set) var isDisabled = true
    private var updates: AnyCancellable?

    init(mug: BluetoothMug) {
      isDisabled = !mug.isConnectedAndReadyForCommands
      updates = mug.isConnectedAndReadyForCommandsStream.sink { [weak self] isReady in
        self?.isDisabled = !isReady
      }
    }
  }
}
