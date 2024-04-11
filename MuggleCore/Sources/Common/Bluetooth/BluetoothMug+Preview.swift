import Combine
import SwiftUI

package extension BluetoothMug where Self == PreviewMug {
  /// Intended for SwiftUI previews without a Nordic mock created by:
  /// ```
  /// EmberMug.init(
  ///   CBMPeripheralPreview(.mug2(), state: .connected)
  /// )
  /// ```
  static func preview() -> PreviewMug {
    PreviewMug()
  }
}

/// Intended for SwiftUI previews without a Nordic mock created by:
/// ```
/// EmberMug.init(
///   CBMPeripheralPreview(.mug2(), state: .connected)
/// )
/// ```
package final class PreviewMug: ObservableObject, BluetoothMug {
  @Published package var activity: MugActivity?
  @Published package var batteryState: BatteryState?
  @Published package var connection = ConnectionStatus.disconnected
  @Published package var hasContents: Bool?
  @Published package var isConfiguring = false
  @Published package var isBusy = false
  @Published package var isWriting = false
  @Published package var led: LEDState?
  @Published package var name: String = "Ember"
  @Published package var serialNumber: String?
  @Published package var temperatureCurrentCelsius: Double?
  @Published package var temperatureTargetState: HeaterState?
  @Published package var temperatureUnit: UnitTemperature?
  package var temperatureViableRange: ClosedRange<Double> = 49...63.0

  package func send(_ command: BluetoothMugCommand) {
    switch command {
    case .led(let color):
      led = color
    case .targetTemperature(let state):
      temperatureTargetState = state
    case .unit(let unit):
      temperatureUnit = unit
    }
  }

  package var activityStream: AnyPublisher<MugActivity, Never> {
    $activity.compactMap { $0 }.eraseToAnyPublisher()
  }
  package var batteryStream: AnyPublisher<BatteryState, Never> {
    $batteryState.compactMap { $0 }.eraseToAnyPublisher()
  }
  package var connectionStream: AnyPublisher<ConnectionStatus, Never> {
    $connection.eraseToAnyPublisher()
  }
  package var hasContentsStream: AnyPublisher<Bool, Never> {
    $hasContents.compactMap { $0 }.eraseToAnyPublisher()
  }
  package var isWritingStream: AnyPublisher<Bool, Never> {
    $isBusy.eraseToAnyPublisher()
  }
  package var isConnectedAndReadyForCommands: Bool {
    connection == .connected && !isConfiguring
  }
  package var isConnectedAndReadyForCommandsStream: AnyPublisher<Bool, Never> {
    Publishers.CombineLatest(
      connectionStream,
      isConfiguringStream
    )
    .map { connection, isConfiguring in
      connection == .connected && !isConfiguring
    }
    .eraseToAnyPublisher()
  }
  package var isConfiguringStream: AnyPublisher<Bool, Never> {
    $isConfiguring.eraseToAnyPublisher()
  }
  package var ledStream: AnyPublisher<LEDState, Never> {
    $led.compactMap { $0 }.eraseToAnyPublisher()
  }
  package var temperatureCurrent: TemperatureState? {
    guard let temperatureCurrentCelsius, let temperatureUnit else { return nil }
    return .init(celsius: temperatureCurrentCelsius, unit: temperatureUnit)
  }
  package var temperatureTarget: LocalUnit<Common.HeaterState>? {
    guard let temperatureTargetState, let temperatureUnit else { return nil }
    return .init(temp: temperatureTargetState, unit: temperatureUnit)
  }
  package var temperatureStream: AnyPublisher<AllTemperatureState, Never> {
    Publishers.CombineLatest3(
      $temperatureCurrentCelsius.compactMap { $0 },
      $temperatureTargetState.compactMap { $0 },
      $temperatureUnit.compactMap { $0 }
    )
    .map(AllTemperatureState.init)
    .eraseToAnyPublisher()
  }
  package var temperatureCurrentStream: AnyPublisher<TemperatureState, Never> {
    Publishers.CombineLatest(
      $temperatureCurrentCelsius.compactMap { $0 },
      $temperatureUnit.compactMap { $0 }
    )
    .map(TemperatureState.init)
    .eraseToAnyPublisher()
  }
  package var temperatureTargetStream: AnyPublisher<LocalUnit<HeaterState>, Never> {
    Publishers.CombineLatest(
      $temperatureTargetState.compactMap { $0 },
      $temperatureUnit.compactMap { $0 }
    )
    .map(LocalUnit.init)
    .eraseToAnyPublisher()
  }
  package var temperatureUnitStream: AnyPublisher<UnitTemperature, Never> {
    $temperatureUnit.compactMap { $0 }.eraseToAnyPublisher()
  }
}
