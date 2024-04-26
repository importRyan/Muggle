import Combine
import Common
import Foundation
import SwiftUI

extension VFZOMug: BluetoothMug {
  func send(_ command: BluetoothMugCommand) {
    fatalError()
  }
}

extension VFZOMug {

  var activity: MugActivity? {
    push.value?.activity
  }

  var activityStream: AnyPublisher<MugActivity, Never> {
    push.$value.compactMap(\.?.activity).eraseToAnyPublisher()
  }

  var batteryState: BatteryState? {
    push.value?.battery
  }

  var batteryStream: AnyPublisher<BatteryState, Never> {
    push.$value.compactMap(\.?.battery).eraseToAnyPublisher()
  }

  var connectionStream: AnyPublisher<ConnectionStatus, Never> {
    $connection.eraseToAnyPublisher()
  }

  var hasContents: Bool? {
    nil
  }

  var hasContentsStream: AnyPublisher<Bool, Never> {
    Empty(outputType: Bool.self, failureType: Never.self).eraseToAnyPublisher()
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


  var isWriting: Bool {
    !writes.awaitingResponse.isEmpty
  }

  var isWritingStream: AnyPublisher<Bool, Never> {
    writes.$awaitingResponse.map { !$0.isEmpty }.eraseToAnyPublisher()
  }

  var led: LEDState? {
    nil
  }

  var ledStream: AnyPublisher<LEDState, Never> {
    Empty(outputType: LEDState.self, failureType: Never.self).eraseToAnyPublisher()
  }

  var serialNumber: String? {
    fatalError()
  }

  var temperatureStream: AnyPublisher<AllTemperatureState, Never> {
    push.$value
      .compactMap { $0 }
      .map { state in
        AllTemperatureState(
          currentCelsius: state.tempCurrent.celsius,
          target: state.tempTarget,
          unit: state.tempCurrent.unit
        )
      }
      .eraseToAnyPublisher()
  }

  var temperatureCurrentStream: AnyPublisher<TemperatureState, Never> {
    push.$value.compactMap(\.?.tempCurrent).eraseToAnyPublisher()
  }

  var temperatureTargetStream: AnyPublisher<LocalUnit<HeaterState>, Never> {
    push.$value.compactMap(\.?.localHeaterState).eraseToAnyPublisher()
  }

  var temperatureUnitStream: AnyPublisher<UnitTemperature, Never> {
    push.$value.compactMap(\.?.tempCurrent.unit).eraseToAnyPublisher()
  }

  var temperatureViableRange: ClosedRange<Double> {
    PushEventCharacteristic.validTargetTemperatureRange
  }

  var temperatureCurrent: TemperatureState? {
    push.value?.tempCurrent
  }

  var temperatureTarget: LocalUnit<HeaterState>? {
    push.value?.localHeaterState
  }
}

private extension PushEventCharacteristic.Contents {
  var activity: MugActivity {
    guard isHeating else { return .standby }
    guard case .celsius(let target) = tempTarget else { return .standby }
    let targetRange = (target - 0.5)...(target + 0.5)
    if targetRange.contains(tempCurrent.celsius) { return .holding }
    if tempCurrent.celsius < target { return .heating }
    return .cooling
  }

  var localHeaterState: LocalUnit<HeaterState> {
    .init(temp: tempTarget, unit: tempCurrent.unit)
  }
}
