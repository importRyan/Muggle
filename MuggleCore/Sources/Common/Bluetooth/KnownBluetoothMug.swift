import SwiftUI

public struct KnownBluetoothMug: Codable {
  public let color: RGBColor?
  public let model: BluetoothMugModel
  public let name: String
  public let serial: String

  public struct RGBColor {
    public let color: Color
  }

  public init(color: Color?, model: BluetoothMugModel, name: String, serial: String) {
    self.color = color.map(RGBColor.init)
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

extension KnownBluetoothMug.RGBColor: Codable {
  public init(from decoder: any Decoder) throws {
    let container = try decoder.singleValueContainer()
    let bits = try container.decode([UInt8].self)
    guard bits.count == 3 else {
      self.color = .black
      Log.app.error("\(Self.self) Unexpected Vector Length \(bits)")
      return
    }
    let floats = bits.map { Double($0) / 255 }
    self.color = .init(red: floats[0], green: floats[1], blue: floats[2])
  }

  public func encode(to encoder: any Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode(color.justRGB())
  }
}
