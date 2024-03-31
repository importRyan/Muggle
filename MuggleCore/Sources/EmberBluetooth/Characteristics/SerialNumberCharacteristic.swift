import Common
import Foundation

final class SerialNumberCharacteristic {
  @Published var value: String?
  var characteristic: CBCharacteristic?
}

extension SerialNumberCharacteristic: BluetoothCharacteristic {
  func parse(update data: Data) throws {
    // Prefix may not be stable across models; unknown structure
    // [197, 172, 22, 184, 120, 206, // ...] c5ac16b878ce[...]
    guard let value = String(data: data.dropFirst(6), encoding: .ascii) else {
      throw BluetoothParsingError.unexpectedValue(data: data)
    }
    self.value = value
  }
}
