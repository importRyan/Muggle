import Combine
import CoreBluetoothMock
import Foundation
import struct SwiftUI.Color

public protocol BluetoothPeripheral: AnyObject {
  var connection: ConnectionStatus { get set }
  var peripheral: CBPeripheral { get }
  var serialNumber: String? { get }
  var name: String { get }
  var debugShortIdentifier: String { get }
  var debugAllIdentifiers: String { get }
  func configure(
    known: LocalKnownBluetoothMug?,
    onUpdate: @escaping (LocalKnownBluetoothMug) -> Void
  )
}

public protocol BluetoothMug: AnyObject {
  func send(_ command: BluetoothMugCommand)

  var activity: MugActivity? { get }
  var activityStream: AnyPublisher<MugActivity, Never> { get }
  var batteryState: BatteryState? { get }
  var batteryStream: AnyPublisher<BatteryState, Never> { get }
  var connection: ConnectionStatus { get }
  var connectionStream: AnyPublisher<ConnectionStatus, Never> { get }
  var hasContents: Bool? { get }
  var hasContentsStream: AnyPublisher<Bool, Never> { get }
  var isConfiguringStream: AnyPublisher<Bool, Never> { get }
  var isConnectedAndReadyForCommands: Bool { get }
  var isConnectedAndReadyForCommandsStream: AnyPublisher<Bool, Never> { get }
  var isWriting: Bool { get }
  var isWritingStream: AnyPublisher<Bool, Never> { get }
  var led: LEDState? { get }
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

public enum MugActivity {
  case adjustingHeater
  case cooling
  case filling
  case heating
  case holding
  case standby

  public var name: String {
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

public struct BatteryState: CustomDebugStringConvertible {
  public var percent: Double
  public var isCharging: Bool

  public init(percent: Double, isCharging: Bool) {
    self.percent = percent
    self.isCharging = isCharging
  }

  public var debugDescription: String {
    percent.formatted(.percent).appending(isCharging ? " charging" : " not charging")
  }
}

public enum BluetoothMugCommand: Equatable, CustomDebugStringConvertible {
  case led(LEDState)
  case targetTemperature(HeaterState)
  case unit(UnitTemperature)

  public var debugDescription: String {
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

public enum HeaterState: Equatable {
  case off
  case celsius(Double)

  public var value: Double? {
    switch self {
    case .off: nil
    case .celsius(let value): value
    }
  }

  public func formatted(unit: UnitTemperature) -> String {
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

  public init(deviceLowerLimit: Double, currentValue: Double?) {
    guard let currentValue, currentValue >= deviceLowerLimit else {
      self = .off
      return
    }
    self = .celsius(currentValue)
  }
}


extension HeaterState: CustomDebugStringConvertible {
  public var debugDescription: String { formatted(unit: .celsius) }
}

public struct LocalUnit<T: Equatable> {
  public var temp: T
  public var unit: UnitTemperature

  public init(temp: T, unit: UnitTemperature) {
    self.temp = temp
    self.unit = unit
  }
}
public extension LocalUnit where T == HeaterState {
  var formatted: String { temp.formatted(unit: unit) }
}

public struct TemperatureState: Equatable {
  public let celsius: Double
  public let unit: UnitTemperature

  public init(celsius: Double, unit: UnitTemperature) {
    self.celsius = celsius
    self.unit = unit
  }
}

public struct AllTemperatureState: Equatable {
  public let currentCelsius: Double
  public let target: HeaterState
  public let unit: UnitTemperature

  public init(currentCelsius: Double, target: HeaterState, unit: UnitTemperature) {
    self.currentCelsius = currentCelsius
    self.target = target
    self.unit = unit
  }
}

public extension AllTemperatureState {
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

public extension TemperatureState {
  var formatted: String {
    Measurement<UnitTemperature>
      .celsius(celsius)
      .converted(to: unit)
      .formattedIntegersNoSymbol()
  }
}
