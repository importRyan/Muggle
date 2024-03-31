import Common
import Combine
import SwiftUI

struct DeviceLEDView: View {
  @State var viewModel: ViewModel
  @State private var didAppear = false

  var body: some View {
    Circle()
      .fill(viewModel.color.gradient)
      .frame(width: 18, height: 18)
      .blur(radius: 2.5)
      .animation(.linear(duration: 3).repeatForever(autoreverses: false)) {
        $0.rotationEffect(.degrees(didAppear ? 0 : 360))
      }
      .onAppear { didAppear.toggle() }
  }

  @Observable
  final class ViewModel {
    var color: Color = .gray
    private var updates: AnyCancellable?

    init(mug: BluetoothMug) {
      updates = mug.ledStream
        .combineLatest(mug.connectionStream)
        .sink { [weak self] led, connection in
          self?.color = led.opacity(connection.isConnected ? 1 : 0.5)
        }
    }
  }
}
