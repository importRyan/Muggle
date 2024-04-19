import Foundation

public extension Measurement<UnitTemperature> {
  static func celsius(_ value: Double) -> Self {
    Self.init(value: value, unit: .celsius)
  }

  func formattedIntegersNoSymbol() -> String {
    formatted(
      .measurement(
        width: .narrow,
        usage: .asProvided,
        numberFormatStyle: .number.precision(.fractionLength(0))
      )
    )
    .trimmingCharacters(in: .letters)
  }
}

