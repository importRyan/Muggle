import Foundation

package enum BluetoothParsingError: Error, LocalizedError {
  case outOfRange
  case unexpectedValue(String)
  case notSetup

  package var errorDescription: String? {
    switch self {
    case .unexpectedValue(let details):
      String(
        localized: "Unexpected value: \(details)",
        comment: "Bluetooth Data Parsing Error"
      )
    case .outOfRange:
      String(
        localized: "Attempted to read data at an out of range index.",
        comment: "Bluetooth Data Parsing Error"
      )

    case .notSetup:
      String(
        localized: "Characteristic setup incomplete",
        comment: "Bluetooth Data Parsing Error"
      )
    }
  }
}

package extension BluetoothParsingError {
  static func unexpectedValue(data: Data) -> BluetoothParsingError {
    .unexpectedValue("\(data.bytes)")
  }
}
