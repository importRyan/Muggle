import Common
import Foundation

final class TemperatureUnitPreferenceCharacteristic {
  @Published var value: UnitTemperature?
  var characteristic: CBCharacteristic?
}

extension TemperatureUnitPreferenceCharacteristic: BluetoothWriteableCharacteristic {
  func parse(update data: Data) throws {
    let newValue: UInt8 = try data.readInteger(from: 0)
    guard let newValue = UnitTemperature.from(ember: newValue) else {
      throw BluetoothParsingError.unexpectedValue(data: data)
    }
    value = newValue
  }

  func encode(_ newValue: UnitTemperature) -> Data {
    Data([newValue.ember])
  }
}

extension UnitTemperature {
  static func from(ember: UInt8) -> UnitTemperature? {
    switch ember {
    case 0: .celsius
    case 1: .fahrenheit
    default: nil
    }
  }

  var ember: UInt8 {
    switch self {
    case .celsius: 0
    case .fahrenheit: 1
    default: 0
    }
  }
}
