import Combine
import CoreBluetoothMock
import Foundation
import struct SwiftUI.Color

package protocol BluetoothPeripheral: AnyObject {
  var connection: ConnectionStatus { get set }
  var peripheral: CBPeripheral { get }
  var serialNumber: String? { get }
  var name: String { get }
  var debugShortIdentifier: String { get }
  var debugAllIdentifiers: String { get }
  func configure(
    knownSerial: String?,
    onSerialNumberUpdate: @escaping (String) -> Void
  )
}

package protocol BluetoothMug: AnyObject {
  func send(_ command: BluetoothMugCommand)

  var activity: MugActivity? { get }
  var activityStream: AnyPublisher<MugActivity, Never> { get }
  var batteryState: BatteryState? { get }
  var batteryStream: AnyPublisher<BatteryState, Never> { get }
  var connection: ConnectionStatus { get }
  var connectionStream: AnyPublisher<ConnectionStatus, Never> { get }
  var hasContents: Bool? { get }
  var hasContentsStream: AnyPublisher<Bool, Never> { get }
  var isBusyStream: AnyPublisher<Bool, Never> { get }
  var isConfiguringStream: AnyPublisher<Bool, Never> { get }
  var isConnectedAndReadyForCommands: Bool { get }
  var isConnectedAndReadyForCommandsStream: AnyPublisher<Bool, Never> { get }
  var ledStream: AnyPublisher<LEDState, Never> { get }
  var name: String { get }
  var serialNumber: String? { get }
  var temperatureStream: AnyPublisher<AllTemperatureState, Never> { get }
  var temperatureCurrentStream: AnyPublisher<TemperatureState, Never> { get }
  var temperatureTargetStream: AnyPublisher<LocalUnit<HeaterState>, Never> { get }
  var temperatureUnitStream: AnyPublisher<UnitTemperature, Never> { get }
  var temperatureCurrent: TemperatureState? { get }
  var temperatureTarget: LocalUnit<HeaterState>? { get }

  var temperatureViableRange: ClosedRange<Double> { get }
}

extension BluetoothMug {
  func commandTemperature(celsius: Double) -> HeaterState {
    if celsius < temperatureViableRange.lowerBound { return .off }
    return .celsius(celsius)
  }
}

package enum MugActivity {
  case adjustingHeater
  case cooling
  case filling
  case heating
  case holding
  case standby

  var name: String {
    switch self {
    case .adjustingHeater: "Adjusting Heating Element"
    case .cooling: "Cooling"
    case .filling: "Filling"
    case .heating: "Heating"
    case .holding: "Holding"
    case .standby: "Standby"
    }
  }
}

package struct BatteryState: CustomDebugStringConvertible {
  package var percent: Double
  package var isCharging: Bool

  package init(percent: Double, isCharging: Bool) {
    self.percent = percent
    self.isCharging = isCharging
  }

  package var debugDescription: String {
    percent.formatted(.percent).appending(isCharging ? " charging" : " not charging")
  }
}

package enum BluetoothMugCommand: Equatable, CustomDebugStringConvertible {
  case led(LEDState)
  case targetTemperature(HeaterState)
  case unit(UnitTemperature)

  package var debugDescription: String {
    switch self {
    case .led(let newValue):
      "led: \(newValue.debugDescription)"
    case .targetTemperature(let newValue):
      "targetTemperature: \(newValue.debugDescription)"
    case .unit(let newValue):
      "unit: \(newValue.debugDescription)"
    }
  }
}

package enum HeaterState: Equatable {
  case off
  case celsius(Double)

  package var value: Double? {
    switch self {
    case .off: nil
    case .celsius(let value): value
    }
  }

  package func formatted(unit: UnitTemperature) -> String {
    switch self {
    case .off: 
      "Off"
    case .celsius(let celsius):
      Measurement<UnitTemperature>
        .celsius(celsius)
        .converted(to: unit)
        .formattedIntegersNoSymbol()
    }
  }

  package init(deviceLowerLimit: Double, currentValue: Double?) {
    guard let currentValue, currentValue >= deviceLowerLimit else {
      self = .off
      return
    }
    self = .celsius(currentValue)
  }
}


extension HeaterState: CustomDebugStringConvertible {
  package var debugDescription: String { formatted(unit: .celsius) }
}

package struct LocalUnit<T: Equatable> {
  package var temp: T
  package var unit: UnitTemperature

  package init(temp: T, unit: UnitTemperature) {
    self.temp = temp
    self.unit = unit
  }
}
package extension LocalUnit where T == HeaterState {
  var formatted: String { temp.formatted(unit: unit) }
}

package struct TemperatureState: Equatable {
  package let celsius: Double
  package let unit: UnitTemperature

  package init(celsius: Double, unit: UnitTemperature) {
    self.celsius = celsius
    self.unit = unit
  }
}

package struct AllTemperatureState: Equatable {
  package let currentCelsius: Double
  package let target: HeaterState
  package let unit: UnitTemperature

  package init(currentCelsius: Double, target: HeaterState, unit: UnitTemperature) {
    self.currentCelsius = currentCelsius
    self.target = target
    self.unit = unit
  }
}

package extension AllTemperatureState {
  var isAtIdealTemperature: Bool {
    currentCelsius.rounded() == target.value?.rounded()
  }

  var formattedCurrent: String {
    Measurement<UnitTemperature>
      .celsius(currentCelsius)
      .converted(to: unit)
      .formattedIntegersNoSymbol()
  }

  var formattedTarget: String {
    target.formatted(unit: unit)
  }
}

package extension TemperatureState {
  var formatted: String {
    Measurement<UnitTemperature>
      .celsius(celsius)
      .converted(to: unit)
      .formattedIntegersNoSymbol()
  }
}
