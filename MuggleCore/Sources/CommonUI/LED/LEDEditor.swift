import Common
import Combine
import Oklab
import SwiftUI

public struct LEDEditor: View {

  public init(viewModel: ViewModel) {
    self.viewModel = viewModel
  }

  @State private var viewModel: ViewModel

  public var body: some View {
    VStack {
      colorSlider
      brightnessSlider
    }
  }

  @Observable
  public final class ViewModel: ObservableObject {
    var hue: Double
    var brightness: Double
    private var updates: AnyCancellable?
    private let send: (LEDState) -> Void

    public init(mug: BluetoothMug) {
      hue = Double(OklabColorPolar(swiftUI: mug.led?.color ?? .gray).hueDegrees)
      brightness = mug.led?.brightness ?? 1.0
      send = { mug.send(.led($0)) }

      if mug.led == nil {
        updates = mug.ledStream
          .first()
          .sink { [weak self] led in
            self?.hue = Double(OklabColorPolar(swiftUI: led.color).hueDegrees)
            self?.brightness = led.brightness
          }
      }
    }

    func writeProposedColor() {
      send(LEDState(color: color(hue: Float(hue)), brightness: brightness))
    }

    func color(hue degrees: Float) -> Color {
      Color(
        OklabColorPolar(
          lightness: 0.71,
          chroma: 0.33,
          hueDegrees: degrees
        )
      )
    }
  }
}

private extension LEDEditor {

  var brightnessSlider: some View {
    GradientSlider(
      value: $viewModel.brightness,
      range: (0.25)...1,
      interiorLabel: {
        Image(systemName: "sun.max.fill")
          .renderingMode(.template)
      },
      onEditingEnded: viewModel.writeProposedColor
    )
    .frame(width: 150, alignment: .topLeading)
    .controlSize(.small)
    .tint(.white)
  }

  var colorSlider: some View {
    GradientSlider(
      value: $viewModel.hue,
      range: 0...359,
      interiorLabel: {
        Image(systemName: "circle.fill")
          .renderingMode(.template)
          .foregroundStyle(viewModel.color(hue: Float(viewModel.hue)))
      },
      onEditingEnded: viewModel.writeProposedColor
    )
    .frame(width: 150, alignment: .topLeading)
    .controlSize(.small)
    .backgroundStyle(
      LinearGradient(
        colors: (0...359).map { viewModel.color(hue: Float($0)) },
        startPoint: .leading,
        endPoint: .trailing
      )
    )
    .tint(.clear)
  }
}
