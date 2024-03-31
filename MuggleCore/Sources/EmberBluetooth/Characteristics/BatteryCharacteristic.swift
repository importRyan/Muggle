import Common
import Foundation

final class BatteryCharacteristic {
  @Published var value: BatteryState?
  var characteristic: CBCharacteristic?
}

extension BatteryCharacteristic: BluetoothCharacteristic {
  func parse(update data: Data) throws {
    let charge: UInt8 = try data.readInteger(from: 0)
    let isCharging: UInt8 = try data.readInteger(from: 1)
    value = BatteryState(percent: Double(charge) / 100, isCharging: isCharging == 1)
  }
}
