import SwiftUI

extension AnimatedAppIcon {
  struct AboutAppGlowingVariant: View {

    let fields: CachedStarFields

    var body: some View {
      let border = MuggleElectricCup.squircle(in: fields.size)
      AnimatedAppIcon(
        border: border,
        fields: fields
      )
      .overlay {
        border.stroke(.white.opacity(0.1), lineWidth: 0.5)
      }
      .compositingGroup()
      .shadow(radius: 10, x: 5, y: 5)
      .shadow(color: MuggleElectricCup.atmosphereTint.opacity(0.35), radius: 30)
    }
  }
}
