import Common
import EmberBluetooth
import Foundation

#if DEBUG
public struct MockBluetoothMug {

  public let delegate: () -> CBMPeripheralSpecDelegate

  public func connected() -> BluetoothMug & BluetoothPeripheral {
    let mug = BluetoothMugModel.EmberModel.mug.build(
      CBMPeripheralPreview(
        .connected(delegate: delegate()),
        state: .connected
      )
    )
    mug.configure(known: nil, onUpdate: { _ in })
    return mug
  }

  public init(delegate: @escaping () -> CBMPeripheralSpecDelegate = { EmberMug2SpecDelegate() }) {
    self.delegate = delegate
  }
}
#endif
