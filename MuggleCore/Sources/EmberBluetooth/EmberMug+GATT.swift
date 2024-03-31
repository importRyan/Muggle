import Common

package extension EmberMug {
  enum GATT {
    package static let service = CBUUID(ember: "3622")

    /// - TODO: PR https://github.com/orlopau/ember-mug
    package enum Characteristics: String, CaseIterable {
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
}

// MARK: - Helpers

private extension CBUUID {
  convenience init(ember: String) {
    self.init(string: "FC54\(ember)-236C-4C94-8FA9-944A3E5353FA")
  }
}

extension EmberMug.GATT.Characteristics {
  var id: CBUUID {
    CBUUID(ember: rawValue)
  }

  init?(id: CBUUID) {
    guard let knownValue = Self.allCases.first(where: { $0.id == id }) else { return nil }
    self = knownValue
  }
}

extension EmberMug.GATT.Characteristics: CustomDebugStringConvertible {
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

package extension CBUUID {
  static let ember = EmberMug.GATT.self
  func emberCharacteristic() -> EmberMug.GATT.Characteristics? {
    .init(id: self)
  }
}

extension CBCharacteristic {
  func ember() -> EmberMug.GATT.Characteristics? {
    .init(id: uuid)
  }
}
