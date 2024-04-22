import Common
import Foundation

/// Tumbler 16 oz CM21X may be slower to update or have a different meaning for 5/6.
class HasContentsCharacteristic: BluetoothCharacteristic {
  @Published var value: Bool?
  var characteristic: CBCharacteristic?

  func parse(update data: Data) throws {
    let level: UInt8 = try data.readInteger(from: 0)
    value = level >= 30
  }
}

final class TravelMugHasContentsCharacteristic: HasContentsCharacteristic {
  override func parse(update data: Data) throws {
    let level: UInt8 = try data.readInteger(from: 0)
    value = level >= 5
  }
}
