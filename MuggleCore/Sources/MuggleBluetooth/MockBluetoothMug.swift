import Common
import EmberBluetooth
import Foundation

#if DEBUG
package struct MockBluetoothMug {

  package let delegate: () -> CBMPeripheralSpecDelegate

  package func connected() -> BluetoothMug & BluetoothPeripheral {
    let mug = BluetoothMugModel.EmberModel.mug.build(
      CBMPeripheralPreview(
        .connected(delegate: delegate()),
        state: .connected
      )
    )
    mug.configure(known: nil, onUpdate: { _ in })
    return mug
  }

  package init(delegate: @escaping () -> CBMPeripheralSpecDelegate = { EmberMug2SpecDelegate() }) {
    self.delegate = delegate
  }
}
#endif
