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
    fatalError()
  }

  var activityStream: AnyPublisher<MugActivity, Never> {
    fatalError()
  }

  var batteryState: BatteryState? {
    fatalError()
  }

  var batteryStream: AnyPublisher<BatteryState, Never> {
    fatalError()
  }

  var connectionStream: AnyPublisher<ConnectionStatus, Never> {
    $connection.eraseToAnyPublisher()
  }

  var hasContents: Bool? {
    fatalError()
  }

  var hasContentsStream: AnyPublisher<Bool, Never> {
    fatalError()
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
    fatalError()
  }

  var ledStream: AnyPublisher<LEDState, Never> {
    fatalError()
  }

  var serialNumber: String? {
    fatalError()
  }

  var temperatureStream: AnyPublisher<AllTemperatureState, Never> {
    fatalError()
  }

  var temperatureCurrentStream: AnyPublisher<TemperatureState, Never> {
    fatalError()
  }

  var temperatureTargetStream: AnyPublisher<LocalUnit<HeaterState>, Never> {
    fatalError()
  }

  var temperatureUnitStream: AnyPublisher<UnitTemperature, Never> {
    fatalError()
  }

  var temperatureViableRange: ClosedRange<Double> {
    fatalError()
  }

  var temperatureCurrent: TemperatureState? {
    fatalError()
  }

  var temperatureTarget: LocalUnit<HeaterState>? {
    fatalError()
  }
}
