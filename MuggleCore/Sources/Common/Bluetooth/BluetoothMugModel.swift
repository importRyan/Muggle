import Foundation

public enum BluetoothMugModel: Codable {
  case ember(EmberModel)
  case vfzo(VFZOModel)

  public enum EmberModel: Codable {
    case mug
    case travel
  }

  public enum VFZOModel: Codable {
    case twelveOunce
  }
}
