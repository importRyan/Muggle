import Common
import SwiftUI

final class LEDColorCharacteristic {
  @Published var value: LEDState?
  var characteristic: CBCharacteristic?
}

extension LEDColorCharacteristic: BluetoothWriteableCharacteristic {
  func parse(update data: Data) throws {
    guard let color = LEDState(ember: data) else {
      throw BluetoothParsingError.unexpectedValue(data: data)
    }
    value = color
  }

  func encode(_ newValue: LEDState) -> Data {
    newValue.emberData
  }
}

extension LEDState {
  var emberData: Data {
    var bytes = color.justRGB()
    let brightness = max(7, UInt8(brightness * 255))
    bytes.append(brightness)
    return Data(bytes)
  }

  init?(ember data: Data) {
    let bytes = data.bytes.map { Double($0) / 255 }
    guard bytes.endIndex == 4 else { return nil }
    self.init(
      color: Color(red: bytes[0], green: bytes[1], blue: bytes[2]),
      brightness: bytes[3]
    )
  }
}
