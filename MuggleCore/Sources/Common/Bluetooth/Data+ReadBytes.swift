import Foundation

package extension Data {
  var bytes: [UInt8] { map { $0 } }

  func readInteger<I: FixedWidthInteger>(from offset: Int) throws -> I {
    let range = (offset ..< (offset + MemoryLayout<I>.size))
    if self.count < range.upperBound {
      throw BluetoothParsingError.outOfRange
    }
    return subdata(in: range).withUnsafeBytes { $0.load(as: I.self) }
  }
}
