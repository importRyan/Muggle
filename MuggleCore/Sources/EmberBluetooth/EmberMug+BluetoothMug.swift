import Combine
import Common
import Foundation
import SwiftUI

extension EmberMug: BluetoothMug {
  package func send(_ command: BluetoothMugCommand) {
    let gatt: GATT.Characteristics = switch command {
    case .led: .led
    case .targetTemperature: .tempTarget
    case .unit: .tempUnitPreference
    }
    guard let characteristic = self[ember: gatt].characteristic else {
      Log.ember.error("\(self.debugShortIdentifier) writeValue attempted before setup \(gatt.debugDescription) \(command.debugDescription)")
      return
    }
    if writes.awaitingResponse.contains(gatt) {
      writes.addToQueue(gatt, command)
      Log.ember.info("\(self.debugShortIdentifier) writeQueue updated \(gatt.debugDescription) \(command.debugDescription)")
      return
    }
    guard connection == .connected else {
      writes.addToQueue(gatt, command)
      Log.ember.info("\(self.debugShortIdentifier) writeQueue updated (currently disconnected) \(gatt.debugDescription) \(command.debugDescription)")
      return
    }
    let data = switch command {
    case .led(let newValue): led.encode(newValue)
    case .targetTemperature(let newValue): tempTarget.encode(newValue)
    case .unit(let newValue): tempUnit.encode(newValue)
    }
    writes.awaitResponse(gatt)
    peripheral.writeValue(data, for: characteristic, type: .withResponse)
    Log.ember.info("\(self.debugShortIdentifier) writeValue \(command.debugDescription) \(gatt.debugDescription) \(data.bytes)")
  }
}

package extension EmberMug {

  var activity: MugActivity? {
    activityCharacteristic.value?.activity
  }

  var activityStream: AnyPublisher<MugActivity, Never> {
    activityCharacteristic.$value.compactMap { $0?.activity }.eraseToAnyPublisher()
  }

  var batteryState: BatteryState? {
    battery.value
  }

  var batteryStream: AnyPublisher<BatteryState, Never> {
    battery.$value.compactMap { $0 }.eraseToAnyPublisher()
  }

  var connectionStream: AnyPublisher<ConnectionStatus, Never> {
    $connection.eraseToAnyPublisher()
  }

  var hasContents: Bool? {
    hasContentsCharacteristic.value
  }

  var hasContentsStream: AnyPublisher<Bool, Never> {
    hasContentsCharacteristic.$value.compactMap { $0 }.eraseToAnyPublisher()
  }

  var isBusyStream: AnyPublisher<Bool, Never> {
    writes.$awaitingResponse.map { !$0.isEmpty }.eraseToAnyPublisher()
  }

  var isConfiguringStream: AnyPublisher<Bool, Never> {
    $setupStepsRemaining.map { !$0.isEmpty }.eraseToAnyPublisher()
  }

  var isConnectedAndReadyForCommands: Bool {
    connection == .connected && isSetUp
  }

  var isConnectedAndReadyForCommandsStream: AnyPublisher<Bool, Never> {
    Publishers.CombineLatest(
      connectionStream,
      isConfiguringStream
    )
    .map { connection, isConfiguring in
      connection == .connected && !isConfiguring
    }
    .eraseToAnyPublisher()
  }

  var ledStream: AnyPublisher<LEDState, Never> {
    led.$value.compactMap { $0 }.eraseToAnyPublisher()
  }

  var serialNumber: String? {
    serial.value
  }

  var temperatureStream: AnyPublisher<AllTemperatureState, Never> {
    Publishers.CombineLatest3(
      tempCurrent.$value.compactMap { $0 },
      tempTarget.$value.compactMap { $0 },
      tempUnit.$value.compactMap { $0 }
    )
    .map(AllTemperatureState.init)
    .eraseToAnyPublisher()
  }

  var temperatureCurrentStream: AnyPublisher<TemperatureState, Never> {
    Publishers.CombineLatest(
      tempCurrent.$value.compactMap { $0 },
      tempUnit.$value.compactMap { $0 }
    )
    .map(TemperatureState.init)
    .eraseToAnyPublisher()
  }

  var temperatureTargetStream: AnyPublisher<LocalUnit<HeaterState>, Never> {
    Publishers.CombineLatest(
      tempTarget.$value.compactMap { $0 },
      tempUnit.$value.compactMap { $0 }
    )
    .map(LocalUnit.init)
    .eraseToAnyPublisher()
  }

  var temperatureUnitStream: AnyPublisher<UnitTemperature, Never> {
    tempUnit.$value.compactMap { $0 }.eraseToAnyPublisher()
  }

  var temperatureViableRange: ClosedRange<Double> {
    TargetTemperatureCharacteristic.validTemperatureRange
  }

  var temperatureCurrent: TemperatureState? {
    guard let value = tempCurrent.value, let unit = tempUnit.value
    else { return nil }
    return .init(celsius: value, unit: unit)
  }

  var temperatureTarget: LocalUnit<HeaterState>? {
    guard let value = tempTarget.value, let unit = tempUnit.value
    else { return nil }
    return .init(temp: value, unit: unit)
  }
}
