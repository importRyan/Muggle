import Foundation

package extension FloatingPoint {
  func clamped(_ range: ClosedRange<Self>) -> Self {
    max(range.lowerBound, min(self, range.upperBound))
  }
}
