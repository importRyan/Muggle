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
