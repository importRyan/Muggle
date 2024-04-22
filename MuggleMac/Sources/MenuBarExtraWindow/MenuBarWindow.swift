import Common
import CommonUI
import MuggleBluetooth
import SwiftUI

#if DEBUG
#Preview {
  MenuBarWindow(
    central: .mocked(
      knownPeripheralsStore: KnownPeripheralsStore.live(store: .ephemeral),
      configure: { central in
        CBMCentralManagerMock.simulateInitialState(.poweredOn)
        CBMCentralManagerMock.simulateAuthorization(.allowedAlways)
        CBMCentralManagerMock.simulatePeripherals([.advertising()])
      }
    )
  )
}
#endif

struct MenuBarWindow: View {
  @ObservedObject var central: BluetoothCentral
  @Environment(\.isPresented) var isPresented

  // TODO: - Better support multiple mugs
  private var sortedDevices: [BluetoothMug & BluetoothPeripheral] {
    central.peripherals.values.sorted(by: {
      $0.name < $1.name
    })
  }

  var body: some View {
    VStack(spacing: 0) {
      BluetoothCentralStatusHint(
        status: central.status,
        noPeripherals: central.peripherals.isEmpty
      )
      if [.poweredOn, .resetting, .poweredOff].contains(central.status) {
        ForEach(sortedDevices, id: \.peripheral.identifier) { mug in
          BluetoothMugView(
            mug: mug,
            forget: { central.forget(mug) },
            viewModel: .init(mug: mug)
          )
        }
      }
      MenuBarWindowOptionsFooter()
    }
    .fixedSize(horizontal: true, vertical: true)
    .animation(.smooth.fast, value: sortedDevices.map(\.peripheral.identifier ))
    .onChange(of: isPresented, initial: true) { _, _ in
      central.scanForEmberProducts()
      central.scheduleScanStop(after: 60)
    }
  }
}
