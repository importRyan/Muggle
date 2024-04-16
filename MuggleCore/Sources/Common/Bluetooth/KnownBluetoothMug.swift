import SwiftUI

package struct KnownBluetoothMug: Codable {
  package let color: RGBColor?
  package let model: BluetoothMugModel
  package let name: String
  package let serial: String

  package struct RGBColor {
    package let color: Color
  }

  package init(color: Color?, model: BluetoothMugModel, name: String, serial: String) {
    self.color = color.map(RGBColor.init)
    self.model = model
    self.name = name
    self.serial = serial
  }
}

package struct LocalKnownBluetoothMug: Codable, Identifiable {
  package var id: UUID { localCBUUID }
  package var localCBUUID: UUID
  package var mug: KnownBluetoothMug

  package init(localCBUUID: UUID, mug: KnownBluetoothMug) {
    self.localCBUUID = localCBUUID
    self.mug = mug
  }
}

extension KnownBluetoothMug.RGBColor: Codable {
  package init(from decoder: any Decoder) throws {
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

  package func encode(to encoder: any Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode(color.justRGB())
  }
}
