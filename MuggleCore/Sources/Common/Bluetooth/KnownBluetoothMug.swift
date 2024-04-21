import SwiftUI

public struct KnownBluetoothMug: Codable {
  public let led: LEDState?
  public let model: BluetoothMugModel
  public let name: String
  public let serial: String


  public init(led: LEDState?, model: BluetoothMugModel, name: String, serial: String) {
    self.led = led
    self.model = model
    self.name = name
    self.serial = serial
  }
}

public struct LocalKnownBluetoothMug: Codable, Identifiable {
  public var id: UUID { localCBUUID }
  public var localCBUUID: UUID
  public var mug: KnownBluetoothMug

  public init(localCBUUID: UUID, mug: KnownBluetoothMug) {
    self.localCBUUID = localCBUUID
    self.mug = mug
  }
}
