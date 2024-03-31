import Common
import Foundation

final class PushEventCharacteristic {
  var value: PushEvent?
  var characteristic: CBCharacteristic?
  weak var mug: EmberMug?
}

extension PushEventCharacteristic: BluetoothCharacteristic {
  func parse(update data: Data) throws {
    let value: UInt8 = try data.readInteger(from: 0)
    guard let event = PushEvent(rawValue: Int(value)) else {
      throw BluetoothParsingError.unexpectedValue(data: data)
    }
    self.value = event
    guard let mug = mug else {
      throw BluetoothParsingError.notSetup
    }
    switch event {
    case .activity: mug.requestRead(.activity)
    case .battery: mug.requestRead(.battery)
    case .charging: mug.battery.value?.isCharging = true
    case .level: mug.requestRead(.hasContents)
    case .notCharging: mug.battery.value?.isCharging = false
    case .tempTarget: mug.requestRead(.tempTarget)
    case .tempCurrent: mug.requestRead(.tempCurrent)
    }
  }
}

enum PushEvent: Int {
  case battery = 1
  case charging
  case notCharging
  case tempTarget
  case tempCurrent
  case level = 7
  case activity
}

extension PushEvent: CustomDebugStringConvertible {
  var debugDescription: String {
    switch self {
    case .battery: "battery"
    case .charging: "charging"
    case .notCharging: "notCharging"
    case .tempTarget: "tempTarget"
    case .tempCurrent: "tempCurrent"
    case .level: "level"
    case .activity: "activity"
    }
  }
}
