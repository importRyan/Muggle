import Common

package enum VFZOGATT {
  //  Manufacturer Data: 5016393639d8
  package static let service = CBUUID(string: "FFF0")

  enum Characteristics: String, CaseIterable {
    case push = "0783B03E-8535-B5A0-7140-A304D2495CB8"
    case readUnknownA = "0783B03E-8535-B5A0-7140-A304D2495CBA"
    case readUnknown5 = "FFF5"
  }
}

// MARK: - Helpers

extension VFZOGATT.Characteristics {
  var id: CBUUID {
    CBUUID(string: rawValue)
  }

  init?(id: CBUUID) {
    guard let knownValue = Self.allCases.first(where: { $0.id == id }) else { return nil }
    self = knownValue
  }
}

extension CBUUID {
  package static let vfzo = VFZOGATT.self
  func vfzoCharacteristic() -> VFZOGATT.Characteristics? {
    .init(id: self)
  }
}

extension CBCharacteristic {
  func vfzo() -> VFZOGATT.Characteristics? {
    .init(id: uuid)
  }
}

extension VFZOGATT.Characteristics: CustomDebugStringConvertible {
  package var debugDescription: String {
    switch self {
    case .push: "Push (8)"
    case .readUnknownA: "Unknown (A)"
    case .readUnknown5: "Unknown (5)"
    }
  }
}
