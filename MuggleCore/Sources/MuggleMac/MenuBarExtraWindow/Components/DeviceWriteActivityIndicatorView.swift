import Combine
import Common
import SwiftUI

struct DeviceWriteActivityIndicatorView: View {

  @State var viewModel: ViewModel

  var body: some View {
    ProgressView()
      .opacity(viewModel.showIndicator ? 1 : 0)
      .animation(.smooth, value: viewModel.showIndicator)
      .help(viewModel.label)
      .accessibilityLabel(viewModel.label)
      .accessibilityHidden(!viewModel.showIndicator)
  }

  @Observable
  final class ViewModel {
    var showIndicator = false
    var label = ""
    private var updates: AnyCancellable?

    init(mug: BluetoothMug) {
      updates = Publishers.CombineLatest3(
        mug.connectionStream,
        mug.isBusyStream,
        mug.isConfiguringStream
      )
      .sink { [weak self] connection, isBusy, isConfiguring in
        switch connection {
        case .disconnected:
          self?.showIndicator = false
        case .connecting:
          self?.label = "Connecting"
          self?.showIndicator = true
        case .connected:
          self?.showIndicator = isConfiguring || isBusy
          self?.label = isConfiguring ? "Connecting" : "Sending command"
        }
      }
    }
  }
}
