import Common
import Combine
import MuggleBluetooth
import SwiftUI

#if DEBUG
#Preview {
  ChangeTemperaturePanel(
    isHovering: true,
    viewModel: .init(mug: .previewMug())
  )
  .fixedSize()
  .padding(20)
}
#endif

struct ChangeTemperaturePanel: View {

  let isHovering: Bool
  @StateObject var viewModel: ChangeTemperaturePanel.ViewModel
  @Environment(\.isEnabled) private var isEnabled

  var body: some View {
    VStack {
      Text(viewModel.label)
        .monospacedDigit()
        .foregroundStyle(labelStyle)
        .frame(maxWidth: .infinity)

      GradientSlider(
        value: $viewModel.temperatureCelsius,
        range: viewModel.signalingRange,
        interiorLabel: Image(systemName: viewModel.thumbControlSymbol),
        onEditingEnded: viewModel.writeCurrentTemperature
      )
      .frame(width: 150, alignment: .topLeading)
      .controlSize(.small)
      .animation(.smooth) {
        $0.backgroundStyle(LinearGradient(colors: trackColors, startPoint: .leading, endPoint: .trailing))
      }
      .padding(.bottom, 5)

      BeverageTemperaturePresetMenus(
        changeTemperature: { preset in
          withAnimation(.smooth.fast) {
            viewModel.adoptPreset(preset)
          }
        }
      )
    }
    .buttonStyle(.borderless)
  }

  private var labelStyle: HierarchicalShapeStyle {
    guard isEnabled else { return .quinary }
    return isHovering ? .primary : .secondary
  }

  private var trackColors: [Color] {
    if viewModel.isHeaterOff {
      [.gray.opacity(0.9), .gray.opacity(0.3)]
    } else if isHovering {
      [.orange, .red]
    } else {
      [.gray.opacity(0.4), .gray.opacity(0.3)]
    }
  }
}

// MARK: - View Model

extension ChangeTemperaturePanel {
  final class ViewModel: ObservableObject {
    @Published var temperatureCelsius: Double
    @Published private var formatUnit: UnitTemperature
    let signalingRange: ClosedRange<Double>

    private var unitChanges: AnyCancellable?
    private var targetHydration: AnyCancellable?
    private let send: (HeaterState) -> Void

    init(mug: BluetoothMug) {
      let signalingRange = mug.temperatureViableRange.reducingLowerBound(by: 0.3)
      self.signalingRange = signalingRange
      send = { mug.send(.targetTemperature($0)) }
      let currentTarget = mug.temperatureTarget
      formatUnit = currentTarget?.unit ?? .celsius
      temperatureCelsius = currentTarget?.temp.value ?? signalingRange.lowerBound

      unitChanges = mug.temperatureUnitStream
        .sink { [weak self] newPreference in
          self?.formatUnit = newPreference
        }

      if currentTarget == nil {
        targetHydration = mug.temperatureTargetStream
          .first()
          .sink { [weak self] target in
            withAnimation(.smooth) {
              self?.temperatureCelsius = target.temp.value ?? signalingRange.lowerBound
            }
          }
      }
    }
  }
}

extension ChangeTemperaturePanel.ViewModel {

  var isHeaterOff: Bool {
    temperatureCelsius <= signalingRange.lowerBound
  }

  var label: String {
    if isHeaterOff {
      "Off"
    } else {
      Measurement<UnitTemperature>.celsius(temperatureCelsius)
        .converted(to: formatUnit)
        .formattedIntegersNoSymbol()
    }
  }

  var thumbControlSymbol: String {
    isHeaterOff ? "snowflake" : "heat.waves"
  }

  func adoptPreset(_ preset: Double) {
    temperatureCelsius = preset
    writeCurrentTemperature()
  }

  func writeCurrentTemperature() {
    if isHeaterOff {
      send(.off)
    } else {
      send(.celsius(temperatureCelsius))
    }
  }
}
