import Common
import Foundation

/// FFF0: 0783b03e8535b5a07140a304d2495cb8
final class PushEventCharacteristic: BluetoothCharacteristic {
  @Published var value: Contents?
  var characteristic: CBCharacteristic?

  struct Contents: CustomDebugStringConvertible {
    let isCharging: Bool
    let celsius: Double

    var debugDescription: String {
      "\(Self.self) isCharging: \(isCharging) celsius: \(Int(celsius))"
    }
  }

  func parse(update data: Data) throws {
    guard data.bytes.endIndex == 20 else {
      throw BluetoothParsingError.unexpectedValue(data: data)
    }

    let numericalBoolean: Int8 = try data.readInteger(from: 6)
    guard [0, 1].contains(numericalBoolean) else {
      throw BluetoothParsingError.unexpectedValue("\(Self.self) \(numericalBoolean)")
    }

    // TODO: - Get some ice and plot. Change to F setting; it appears they transmit in F or C.
    let rawTemperature: UInt8 = data.last!

    self.value = .init(
      isCharging: numericalBoolean == 1,
      celsius: Double(rawTemperature) - 81
    )
  }
}
