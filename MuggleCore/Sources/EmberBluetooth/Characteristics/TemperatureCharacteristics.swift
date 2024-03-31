import Common
import Foundation

final class TemperatureCharacteristic {
  @Published var value: Double?
  var characteristic: CBCharacteristic?
}

extension TemperatureCharacteristic: BluetoothCharacteristic {
  func parse(update data: Data) throws {
    let newValue: UInt16 = try data.readInteger(from: 0)
    value = Double(newValue) * 0.01
  }
}
