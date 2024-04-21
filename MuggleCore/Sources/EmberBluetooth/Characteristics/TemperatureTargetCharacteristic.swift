import Common
import Foundation

final class TargetTemperatureCharacteristic {
  @Published var value: HeaterState?
  var characteristic: CBCharacteristic?
  /// Mug 2 CM17, Tumbler 16 oz CM21X
  static let validTemperatureRange = 49.0...63.0
}

extension TargetTemperatureCharacteristic: BluetoothWriteableCharacteristic {
  func parse(update data: Data) throws {
    let rawValue: UInt16 = try data.readInteger(from: 0)
    let newValue = Double(rawValue) * 0.01
    value = HeaterState(deviceLowerLimit: Self.validTemperatureRange.lowerBound, currentValue: newValue)
  }

  func encode(_ newValue: HeaterState) -> Data {
    newValue.emberCommandData
  }
}

extension HeaterState {
  var emberCommandData: Data {
    switch self {
    case .off:
      return Data([0, 0, 0, 0])
    case .celsius(var target):
      let range = TargetTemperatureCharacteristic.validTemperatureRange
      if target < range.lowerBound {
        return HeaterState.off.emberCommandData
      }
      target = min(range.upperBound, target)
      let value = UInt16(target * 100).littleEndian
      var data = Data()
      withUnsafeBytes(of: value) { data.append(contentsOf: $0) }
      return data
    }
  }
}
