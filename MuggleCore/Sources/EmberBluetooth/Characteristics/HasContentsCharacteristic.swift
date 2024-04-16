import Common
import Foundation

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
