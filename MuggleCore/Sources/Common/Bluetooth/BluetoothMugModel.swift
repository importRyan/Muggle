import Foundation

package enum BluetoothMugModel: Codable {
  case ember(EmberModel)

  package enum EmberModel: Codable {
    case mug
    case travel
  }
}
