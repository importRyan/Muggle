import Common
import Foundation

final class ActivityCharacteristic {
  @Published var value: EmberMugActivity?
  var characteristic: CBCharacteristic?
}

extension ActivityCharacteristic: BluetoothCharacteristic {
  func parse(update data: Data) throws {
    let newValue: UInt8 = try data.readInteger(from: 0)
    guard let newValue = EmberMugActivity(rawValue: Int(newValue)) else {
      throw BluetoothParsingError.unexpectedValue(data: data)
    }
    value = newValue
  }
}

enum EmberMugActivity: Int {
  case adjustingHeater = 0
  case empty = 1
  case filling = 2
  case unknown3 = 3
  case cooling = 4
  case heating = 5
  case holding = 6

  var activity: MugActivity {
    switch self {
    case .adjustingHeater: .adjustingHeater
    case .empty: .standby
    case .filling: .filling
    case .cooling: .cooling
    case .heating: .heating
    case .holding: .holding
    case .unknown3: .standby
    }
  }
}

extension EmberMugActivity: CustomDebugStringConvertible {
  var debugDescription: String {
    switch self {
    case .adjustingHeater: "Adjusting Heat"
    case .empty: "Standby"
    case .filling: "Filling"
    case .unknown3: "Unknown 3"
    case .cooling: "Cooling"
    case .heating: "Heating"
    case .holding: "Holding"
    }
  }
}
