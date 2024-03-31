import Foundation

package extension ClosedRange {
  func percentage(_ value: Bound) -> Bound where Bound: FloatingPoint {
    (value - lowerBound) / (upperBound - lowerBound)
  }

  func boundedValue(percentage: Bound) -> Bound where Bound: FloatingPoint {
    if percentage <= 0 {
      lowerBound
    } else if percentage > 1 {
      upperBound
    } else {
      percentage * (upperBound - lowerBound) + lowerBound
    }
  }

  func unboundedValue(percentage: Bound) -> Bound where Bound: FloatingPoint {
    percentage * (upperBound - lowerBound) + lowerBound
  }

  func reducingLowerBound(by amount: Bound) -> ClosedRange<Bound> where Bound: FloatingPoint {
    (lowerBound - amount)...upperBound
  }
}
