import Common
import SwiftUI

#if DEBUG
#Preview {
  AnimatedAppIcon.AboutAppGlowingVariant(fields: .inAppVariant).padding()
}
#endif

struct AnimatedAppIcon: View {
  var border: RoundedRectangle
  var fields: CachedStarFields

  var body: some View {
    MuggleElectricCup.WithBackground(
      stars: AnimatedStarField(
        layer1: fields.a,
        layer2: fields.b,
        layer3: fields.c,
        layer4: fields.d
      ),
      atmosphere: ShootingStarView()
    )
    .containerShape(border)
    .clipShape(border)
    .frame(square: fields.size)
  }
}

extension Shape {
  func path(inSquare: CGFloat) -> Path {
    path(in: .init(origin: .zero, size: .init(width: inSquare, height: inSquare)))
  }
}
