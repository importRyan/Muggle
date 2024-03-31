import Foundation

package protocol BluetoothWriteableCharacteristic: BluetoothCharacteristic {
  func encode(_ newValue: Value) -> Data
}

package protocol BluetoothCharacteristic: AnyObject, CustomDebugStringConvertible {
  associatedtype Value
  var value: Value? { get set }
  var characteristic: CBCharacteristic? { get set }
  func parse(update data: Data) throws
}

package extension BluetoothCharacteristic {
  func `set`(_ characteristic: CBCharacteristic) {
    self.characteristic = characteristic
  }
}

extension BluetoothCharacteristic where Value: CustomDebugStringConvertible  {
  package var debugDescription: String {
    let unwrappedValue = if let value { value.debugDescription } else { "nil" }
    return "\(Self.self): \(unwrappedValue)"
  }
}

extension BluetoothCharacteristic where Value: CustomStringConvertible {
  package var debugDescription: String {
    let unwrappedValue = if let value { value.description } else { "nil" }
    return "\(Self.self): \(unwrappedValue)"
  }
}

extension BluetoothCharacteristic where Value == String {
  package var debugDescription: String {
    let unwrappedValue = if let value { value } else { "nil" }
    return "\(Self.self) \(unwrappedValue)"
  }
}

extension BluetoothCharacteristic where Value == Double {
  package var debugDescription: String {
    let unwrappedValue = if let value { value.formatted(.number.precision(.fractionLength(3))) } else { "nil" }
    return "\(Self.self) \(unwrappedValue)"
  }
}

extension BluetoothCharacteristic where Value == UnitTemperature {
  package var debugDescription: String {
    let unwrappedValue = if let value { value.label } else { "nil" }
    return "\(Self.self) \(unwrappedValue)"
  }
}
