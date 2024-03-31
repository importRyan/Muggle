import Combine
import Common
import MuggleBluetooth
import SwiftUI

struct MenuBarExtraIcon: View {

  @StateObject var viewModel: ViewModel

  var body: some View {
    switch viewModel.state {
    case .inactiveApp:
      Image(systemName: "mug")

    case .connecting:
      render(ConnectingMug.self)

    case .empty(let isCharging, let caption):
      if isCharging {
        render(EmptyChargingMug.self)
      } else {
        render(EmptyMug.self)
      }
      if let caption {
        Text(caption)
      }

    case .beverage(let isCharging, let caption):
      if isCharging {
        render(FullChargingMug.self)
      } else {
        render(FullMug.self)
      }
      Text(caption)
    }
  }
}

// MARK: - View State

private enum MenuBarIconState: Equatable {
  case inactiveApp
  case connecting
  case empty(isCharging: Bool, caption: String?)
  case beverage(isCharging: Bool, caption: String)

  struct DeviceState {
    let battery: BatteryState?
    let hasContents: Bool?
    let temp: AllTemperatureState
  }
}

extension MenuBarIconState {
  init(device: DeviceState?) {
    guard let device else {
      self = .connecting
      return
    }
    guard
      let battery = device.battery,
      let hasContents = device.hasContents else {
      self = .connecting
      return
    }
    if hasContents {
      self = .beverage(
        isCharging: battery.isCharging,
        caption: device.temp.isAtIdealTemperature ? " Ready" : device.temp.formattedCurrent
      )
    } else {
      self = .empty(
        isCharging: battery.isCharging,
        caption: battery.percent > 0.98 ? nil : battery.percent.formatted(.percent)
      )
    }
  }
}

// MARK: - View Model

extension MenuBarExtraIcon {
  final class ViewModel: ObservableObject {
    @Published fileprivate var state: MenuBarIconState = .inactiveApp
    private var isBluetoothActive: AnyCancellable?
    private var firstConnectedDeviceStream: AnyCancellable?

    init(central: BluetoothCentral) {
      isBluetoothActive = central.$status
        .map { $0 == .poweredOn ? true : false }
        .sink { [weak self] isActive in
          guard let self else { return }
          if isActive && state == .inactiveApp {
            state = .connecting
          } else {
            state = .inactiveApp
          }
        }

      firstConnectedDeviceStream = central.$peripherals
        .flatMap { Publishers.MergeMany($0.values.map(\.onConnectionStream)) }
        .first()
        .flatMap(\.stateStream)
        .sink { [weak self] deviceState in
          guard let self else { return }
          if state == .inactiveApp { return }
          state = .init(device: deviceState)
        }
    }
  }
}

private extension BluetoothMug {
  var onConnectionStream: AnyPublisher<BluetoothMug, Never> {
    connectionStream
      .filter(\.isConnected)
      .compactMap { [weak self] _ in self }
      .eraseToAnyPublisher()
  }

  var stateStream: AnyPublisher<MenuBarIconState.DeviceState, Never> {
    Publishers.CombineLatest3(
      batteryStream,
      hasContentsStream,
      temperatureStream
    )
    .map(MenuBarIconState.DeviceState.init)
    .eraseToAnyPublisher()
  }
}
