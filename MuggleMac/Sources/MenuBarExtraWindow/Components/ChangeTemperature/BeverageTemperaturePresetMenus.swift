import SwiftUI

struct BeverageTemperaturePresetMenus: View {
  let changeTemperature: (Double) -> Void

  var body: some View {
    HStack {
      Menu("Coffee", systemImage: "mug") {
        Button("Latte") { changeTemperature(55) }
        Button("Cappuccino") { changeTemperature(56) }
        Button("Black") { changeTemperature(60) }
      }

      Menu("Tea", systemImage: "bag") {
        Button("Floral") { changeTemperature(52) }
        Button("Black") { changeTemperature(57) }
        Button("Green") { changeTemperature(58) }
        Button("Herbal") { changeTemperature(63) }
      }
    }
    .controlSize(.small)
    .frame(maxWidth: .infinity)
    .menuStyle(.borderlessButton)
    .buttonBorderShape(.capsule)
  }
}
