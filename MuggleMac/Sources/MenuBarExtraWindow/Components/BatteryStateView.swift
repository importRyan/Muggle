import Combine
import Common
import SwiftUI

struct BatteryStateView: View {

  @Observable
  final class ViewModel {
    private(set) var state: ViewState?
    private var updates: AnyCancellable?

    init(mug: BluetoothMug) {
      state = mug.batteryState.map(ViewState.init)
      updates = mug.batteryStream.sink { [weak self] state in
        self?.state = .init(state: state)
      }
    }
  }

  @State var viewModel: ViewModel
  @State private var isHovering = false

  var body: some View {
    if let state = viewModel.state {
      HStack(spacing: 0) {
        if isHovering {
          Text(state.value)
            .font(.caption)
            .foregroundStyle(.secondary)
            .padding(.trailing, 4)
            .transition(
              .move(edge: .leading)
              .combined(with: .opacity.animation(.smooth.fast))
              .combined(with: .scale(0.8, anchor: .leading))
            )
        }
        Image(systemName: state.symbolName)
          .symbolRenderingMode(.hierarchical)
          .fontWeight(.medium)
        Image(systemName: "bolt.fill")
          .symbolRenderingMode(.hierarchical)
          .font(.caption2)
          .opacity(state.isCharging ? 1 : 0)
      }
      .symbolEffect(.pulse.byLayer, options: .speed(0.1), isActive: state.isCharging)
      .accessibilityElement()
      .accessibilityLabel("Battery")
      .accessibilityValue(state.accessibilityValue)
      .contentShape(.rect)
      .animation(.smooth, value: isHovering)
      .onHover { isHovering = $0 }
    }
  }

  struct ViewState: Equatable {
    let accessibilityValue: String
    let isCharging: Bool
    let symbolName: String
    let value: String

    init(state: BatteryState) {
      self.value = state.percent.formatted(.percent)
      self.accessibilityValue = state.isCharging ? value.appending(" charging") : value
      self.isCharging = state.isCharging
      self.symbolName = BatterySymbol(percent: state.percent).rawValue
    }
  }

  enum BatterySymbol: String {
    case zero = "battery.0percent"
    case low = "battery.25percent"
    case half = "battery.50percent"
    case high = "battery.75percent"
    case full = "battery.100percent"

    init(percent: Double) {
      self = switch percent {
      case ...0: .zero
      case ...0.4: .low
      case ...0.60: .half
      case ...0.90: .high
      default: .full
      }
    }
  }
}
