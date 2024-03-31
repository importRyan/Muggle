import Common
import MuggleBluetooth
import SwiftUI

struct MenuBarWindow: View {
  @ObservedObject var central: BluetoothCentral
  @Environment(\.isPresented) var isPresented

  var body: some View {
    VStack(spacing: 0) {
      BluetoothCentralStatusHint(
        status: central.status,
        noPeripherals: central.peripherals.isEmpty
      )
      if [.poweredOn, .resetting, .poweredOff].contains(central.status) {
        ForEach(central.peripherals.elements, id: \.key) { _, mug in
          BluetoothMugView(
            mug: mug,
            viewModel: .init(mug: mug)
          )
        }
      }
      MenuBarWindowOptionsFooter()
    }
    .onChange(of: isPresented, initial: true) { _, _ in
      central.scanForEmberProducts()
      central.scheduleScanStop(after: 60)
    }
  }
}
