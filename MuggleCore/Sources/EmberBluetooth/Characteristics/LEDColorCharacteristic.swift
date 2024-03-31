import Common
import SwiftUI

final class LEDColorCharacteristic {
  @Published var value: Color?
  var characteristic: CBCharacteristic?
}

extension LEDColorCharacteristic: BluetoothWriteableCharacteristic {
  func parse(update data: Data) throws {
    guard let color = EmberRGBA(data).color else {
      throw BluetoothParsingError.unexpectedValue(data: data)
    }
    value = color
  }

  func encode(_ newValue: Color) -> Data {
    Data(EmberRGBA(newValue).bytes)
  }
}

private struct EmberRGBA {
  var bytes: [UInt8]

  var color: Color? {
    guard bytes.endIndex == 4 else { return nil }
    return Color(
      red: Double(bytes[0]) / 255,
      green: Double(bytes[1]) / 255,
      blue: Double(bytes[2]) / 255,
      opacity: Double(bytes[3]) / 255
    )
  }

  init(_ data: Data) {
    self.bytes = data.bytes
  }

  init(_ color: Color) {
    let color = NSColor(color)
    let red = UInt8(color.redComponent * 255)
    let green = UInt8(color.greenComponent * 255)
    let blue = UInt8(color.blueComponent * 255)
    let alpha = UInt8(color.alphaComponent * 255)
    self.bytes = [red, green, blue, alpha]
  }
}
