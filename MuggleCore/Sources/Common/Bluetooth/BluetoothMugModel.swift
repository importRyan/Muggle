import Foundation

public enum BluetoothMugModel: Codable {
  case ember(EmberModel)

  public enum EmberModel: Codable {
    case mug
    case travel
  }
}
