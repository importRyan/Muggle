import SwiftUI

public struct LEDState: Equatable {
  public var color: Color
  public var brightness: Double

  public init(color: Color, brightness: Double) {
    self.color = color
    self.brightness = brightness
  }
}

extension LEDState: CustomDebugStringConvertible {
  public var debugDescription: String {
    "\(Self.self) \(color.description) brightness: \(brightness.formatted(.number.precision(.fractionLength(2))))"
  }
}

package extension Color {
  /// 8-bit three channels
  func justRGB() -> [UInt8] {
#if os(macOS)
    NSColor(self).justRGB()
#elseif os(visionOS)
    UIColor(self).justRGB()
#endif
  }
}

#if os(macOS)
private extension NSColor {
  func justRGB() -> [UInt8] {
    guard let color = self.asSRGBComponentsColor() else { return [0, 0, 0] }
    let components: [Double] = switch color.numberOfComponents {
    case 4...: [color.redComponent, color.greenComponent, color.blueComponent]
    case ...2: Array(repeating: color.whiteComponent, count: 3)
    default: [0, 0, 0]
    }
    return components.map { UInt8($0 * 255) }
  }

  func asSRGBComponentsColor() -> NSColor? {
    guard let rgb = usingType(.componentBased) else { return nil }
    guard rgb.colorSpace == .extendedSRGB || rgb.colorSpace == .sRGB
    else { return rgb.usingColorSpace(.extendedSRGB) }
    return rgb
  }
}
#elseif os(visionOS)
private extension UIColor {
  func justRGB() -> [UInt8] {
    guard let components = cgColor.asSRGB()?.components, components.endIndex == 4 else { return [0, 0, 0] }
    return components[0...2].map { UInt8($0 * 255) }
  }
}

private extension CGColor {
  func asSRGB() -> CGColor? {
    if colorSpace == srgb || colorSpace == esrgb { return self }
    return converted(to: srgb, intent: .defaultIntent, options: nil)
  }
}

private let esrgb = CGColorSpace(name: CGColorSpace.extendedSRGB)!
private let srgb = CGColorSpace(name: CGColorSpace.extendedSRGB)!
#endif

extension LEDState: Codable {
  private enum CodingKeys: String, CodingKey {
    case rgb
    case brightness
  }

  public func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(brightness, forKey: .brightness)
    try container.encode(color.justRGB(), forKey: .rgb)
  }

  public init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.brightness = try container.decode(Double.self, forKey: .brightness)
    let bits = try container.decode([UInt8].self, forKey: .rgb)
    guard bits.count == 3 else {
      self.color = .black
      Log.app.error("\(Self.self) Unexpected Vector Length \(bits)")
      return
    }
    let floats = bits.map { Double($0) / 255 }
    self.color = .init(red: floats[0], green: floats[1], blue: floats[2])
  }
}
