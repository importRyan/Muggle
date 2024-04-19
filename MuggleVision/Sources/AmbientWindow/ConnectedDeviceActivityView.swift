import Common
import Combine
import SwiftUI

struct ConnectedDeviceActivityView: View {

  @State var viewModel: ViewModel

  var body: some View {
    VStack(alignment: .leading) {
      Text(viewModel.headline)
        .font(.largeTitle)
        .contentTransition(.numericText())
        .foregroundStyle(viewModel.isHeadlineProminent ? .primary : .secondary)
      Text(viewModel.caption)
        .font(.callout)
        .foregroundStyle(.secondary)
    }
  }
}

extension ConnectedDeviceActivityView {
  @Observable
  final class ViewModel {
    private(set) var caption = ""
    private(set) var headline = ""
    private(set) var isHeadlineProminent: Bool

    private var subs = Set<AnyCancellable>()

    init(mug: BluetoothMug) {
      self.isHeadlineProminent = mug.connection.isConnected
      if let temp = mug.temperatureCurrent {
        self.headline = temp.formatted
      }
      if let activity = mug.activity,
         let temp = mug.temperatureTarget {
        self.caption = Self.caption(for: mug.connection, activity: activity, target: temp)
      }

      Publishers.CombineLatest(
        mug.connectionStream,
        mug.temperatureCurrentStream
      )
      .sink { [weak self] status, temp in
        self?.headline = temp.formatted
        self?.isHeadlineProminent = status.isConnected
      }
      .store(in: &subs)

      Publishers.CombineLatest3(
        mug.connectionStream,
        mug.activityStream,
        mug.temperatureTargetStream
      )
      .sink { [weak self] connection, activity, temp in
        self?.caption = Self.caption(for: connection, activity: activity, target: temp)
      }
      .store(in: &subs)
    }

    static func caption(for connection: ConnectionStatus, activity: MugActivity, target: LocalUnit<HeaterState>) -> String {
      switch connection {
      case .connected: break
      case .connecting: return "Connecting"
      case .disconnected: return "Disconnected"
      }
      if target.temp == .off {
        return "Off"
      }
      return switch activity {
      case .adjustingHeater: "Heating to \(target.formatted)"
      case .filling: "Filling"
      case .cooling: "Cooling to \(target.formatted)"
      case .heating: "Heating to \(target.formatted)"
      case .holding: "Holding at \(target.formatted)"
      case .standby: "Empty"
      }
    }
  }
}
