import Combine
import Common
import SwiftUI

struct TemperatureUnitPicker: View {

  @State var viewModel: ViewModel

  private var selection: Binding<UnitTemperature?> {
    .init(
      get: { viewModel.unit },
      set: { newValue in
        guard let newValue else { return }
        viewModel.unit = newValue
        viewModel.send(newValue)
      }
    )
  }

  var body: some View {
    Picker(selection: selection) {
      Text(UnitTemperature.celsius.label).tag(UnitTemperature?.some(.celsius))
      Text(UnitTemperature.fahrenheit.label).tag(UnitTemperature?.some(.fahrenheit))
    } label: {
      Text("Unit")
    }
  }

  @Observable
  final class ViewModel {
    var unit: UnitTemperature?
    private var updates: AnyCancellable?
    let send: (UnitTemperature) -> Void

    init(mug: BluetoothMug) {
      send = { mug.send(.unit($0)) }
      updates = mug.temperatureUnitStream.sink { [weak self] unit in
        self?.unit = unit
      }
    }
  }
}
