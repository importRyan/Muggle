import Common
import EmberBluetooth

#if DEBUG
package extension BluetoothMug where Self == EmberMug {
  /// Works outside a Central for SwiftUI Previews and demos
  static func previewMug(
    delegate: () -> CBMPeripheralSpecDelegate = { EmberMug2SpecDelegate() }
  ) -> BluetoothMug & BluetoothPeripheral {
    let mug = EmberMug(
      CBMPeripheralPreview(
        .connected(delegate: delegate()),
        state: .connected
      )
    )
    mug.configure(knownSerial: "111", onSerialNumberUpdate: { _ in })
    return mug
  }
}
#endif
