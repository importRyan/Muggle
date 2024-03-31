import Common
import Foundation

final class HasContentsCharacteristic {
  @Published var value: Bool?
  var characteristic: CBCharacteristic?
}

extension HasContentsCharacteristic: BluetoothCharacteristic {
  func parse(update data: Data) throws {
    let level: UInt8 = try data.readInteger(from: 0)
    value = level >= 30
  }
}
