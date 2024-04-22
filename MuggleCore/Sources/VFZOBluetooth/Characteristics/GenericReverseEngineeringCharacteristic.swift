import Common
import Foundation

final class GenericReverseEngineeringCharacteristic: BluetoothCharacteristic {
  @Published var value: Data?
  var characteristic: CBCharacteristic?
  private let name: String

  init(name: String) {
    self.name = name
  }

  func parse(update data: Data) throws {
    value = data
  }

  var debugDescription: String {
    name
  }
}
