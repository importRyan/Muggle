import Common

package enum EmberGATT {
  /// Are some on 3632?
  package static let service = CBUUID(ember: "3622")
  /// Or is this 21d1?
  package static let serviceTravelMug = CBUUID(ember: "3621")

  /// TODO: - Travel Mug Support
  enum Characteristics: String, CaseIterable {
    // Ember's app ignores 0001 and contents are limited; identification runs by color.
    //  case name = "0001"
    case tempCurrent = "0002"
    case tempTarget = "0003"
    case tempUnitPreference = "0004"
    case hasContents = "0005"
    case activity = "0008"
    case battery = "0007"
    case push = "0012"
    case led = "0014"
    case serialNumber = "000D"
  }
}

// MARK: - Helpers

private extension CBUUID {
  convenience init(ember: String) {
    self.init(string: "FC54\(ember)-236C-4C94-8FA9-944A3E5353FA")
  }
}

extension EmberGATT.Characteristics {
  var id: CBUUID {
    CBUUID(ember: rawValue)
  }

  init?(id: CBUUID) {
    guard let knownValue = Self.allCases.first(where: { $0.id == id }) else { return nil }
    self = knownValue
  }
}

extension EmberGATT.Characteristics: CustomDebugStringConvertible {
  package var debugDescription: String {
    switch self {
    case .activity: "activity"
    case .battery: "battery"
    case .hasContents: "hasContents"
    case .led: "led"
    case .push: "pushEvent"
    case .serialNumber: "deviceSerial"
    case .tempCurrent: "tempCurrent"
    case .tempTarget: "tempTarget"
    case .tempUnitPreference: "tempUnitPreference"
    }
  }
}

extension CBUUID {
  package static let ember = EmberGATT.self
  func emberCharacteristic() -> EmberGATT.Characteristics? {
    .init(id: self)
  }
}

extension CBCharacteristic {
  func ember() -> EmberGATT.Characteristics? {
    .init(id: uuid)
  }
}
