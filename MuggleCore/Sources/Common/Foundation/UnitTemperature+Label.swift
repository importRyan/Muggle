import Foundation

package extension UnitTemperature {
  var label: String {
    switch self {
    case .celsius: "℃"
    case .fahrenheit: "℉"
    case .kelvin: "K"
    default: ""
    }
  }
}
