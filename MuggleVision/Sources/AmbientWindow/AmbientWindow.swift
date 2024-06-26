import Common
import CommonUI
import MuggleBluetooth
import SwiftUI

#if DEBUG
#Preview {
  AmbientWindow(
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

struct AmbientWindow: View {
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
          ConnectedDeviceActivityView(viewModel: .init(mug: mug))
        }
      }
    }
    .onChange(of: isPresented, initial: true) { _, _ in
      central.scanForEmberProducts()
      central.scheduleScanStop(after: 60)
    }
  }
}
