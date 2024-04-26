import Common
import Foundation

/// FFF0: 0783b03e8535b5a07140a304d2495cb8
/// Notifying layout
/// 0-1: Always [85, 170]
/// 2: isHeating
/// 3: isFahrenheit
/// 4: literal current temperature
/// 5: literal target temperature
/// 6: isCharging
/// 7: literal battery bars shown in app
/// 8-17: Always 0
/// 18: Always UInt8 16
/// 19: Checksum (2-7 + zeros + 18)
///
/// Some rare responses have radically different payloads (either sniffer noise or different message)
///
/// When reading, responds with [67, 72, 65, 82, 49, 95, 86, 65, 76, 85, 69] "CHAR1_VALUE"
final class PushEventCharacteristic: BluetoothCharacteristic {
  @Published var value: Contents?
  var characteristic: CBCharacteristic?

  static let validTargetTemperatureRange = 35.0...65.0

  struct Contents: CustomDebugStringConvertible {
    let battery: BatteryState
    let isHeating: Bool
    let tempCurrent: TemperatureState
    let tempTarget: HeaterState

    var debugDescription: String {
      let unit = tempCurrent.unit == .fahrenheit ? "F" : "C"
      return "\(Self.self) battery: \(battery.debugDescription) current: \(tempCurrent.formatted)\(unit) target: \(tempTarget.debugDescription)"
    }
  }

  func parse(update data: Data) throws {
    // Possibly just sniffer error, but some rare payloads differ and may represent a different message
    guard data.bytes.endIndex == 20,
          data.bytes.prefix(2) == [85, 170],
          data.bytes[2...18].reduce(0, +) == data.bytes[19]
    else {
      throw BluetoothParsingError.unexpectedValue(data: data)
    }

    let isHeating = data.bytes[2] == 1
    guard [0, 1].contains(data.bytes[2]) else {
      throw BluetoothParsingError.unexpectedValue("\(Self.self) isHeating \(isHeating)")
    }

    let isFahrenheit = data.bytes[3] == 1
    let unit = isFahrenheit ? UnitTemperature.fahrenheit : .celsius
    guard [0, 1].contains(data.bytes[3]) else {
      throw BluetoothParsingError.unexpectedValue("\(Self.self) isFahrenheit \(isFahrenheit)")
    }

    // Literal on-screen number (interpret using `isFahrenheit`)
    let temperatureCurrent = data.bytes[4]

    // Literal on-screen number (interpret using `isFahrenheit`)
    let temperatureTarget = data.bytes[5]

    let isCharging = data.bytes[6] == 1
    guard [0, 1].contains(data.bytes[6]) else {
      throw BluetoothParsingError.unexpectedValue("\(Self.self) isCharging \(isCharging)")
    }

    let batteryBars = data.bytes[7]
    guard (0...5).contains(batteryBars) else {
      throw BluetoothParsingError.unexpectedValue("\(Self.self) batteryBars \(batteryBars)")
    }

    self.value = Contents(
      battery: BatteryState(
        percent: Double(batteryBars) / 5,
        isCharging: isCharging
      ),
      isHeating: isHeating,
      tempCurrent: TemperatureState(
        celsius: Measurement<UnitTemperature>.init(
          value: Double(temperatureCurrent),
          unit: unit
        )
        .converted(to: .celsius)
        .value,
        unit: unit
      ),
      tempTarget: .celsius(
        Measurement<UnitTemperature>.init(
          value: Double(temperatureTarget),
          unit: unit
        )
        .converted(to: .celsius)
        .value
      )
    )
  }
}
