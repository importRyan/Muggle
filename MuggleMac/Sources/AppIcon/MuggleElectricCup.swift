import Common
import SwiftUI

#if DEBUG
#Preview("Transparent") {
  MuggleElectricCup().frame(square: 150)
}
#Preview("Squircle") {
  MuggleElectricCup.WithBackground(
    stars: EmptyView(),
    atmosphere: EmptyView()
  )
  .frame(square: 250)
  .containerShape(MuggleElectricCup.squircle(in: 250))
}
#endif

struct MuggleElectricCup: View {

  var boltTint: Color = .yellow
  var mugTint: Color = Color(white: 0.05)
  var mugGlint: Color = Color(white: 0.12)
  var mugContents: Color = Color(
    hue: 243 / 360,
    saturation: 0.84,
    brightness: 0.15
  )

  var body: some View {
    GeometryReader { geo in
      ZStack {
        Ellipse()
          .foregroundStyle(mugContents)
          .frame(width: geo.size.width * 0.65, height: geo.size.height * 0.2)
          .offset(x: geo.size.width * -0.03, y: geo.size.height * -0.38)

        Image(systemName: "mug.fill")
          .resizable()
          .scaledToFit()
          .offset(x: geo.size.width * 0.05)
          .foregroundStyle(
            LinearGradient(
              stops: [
                .init(color: mugTint, location: 0.05),
                .init(color: mugGlint, location: 0.4),
                .init(color: mugTint, location: 0.85),
              ],
              startPoint: .leading,
              endPoint: .trailing
            )
          )

        Image(systemName: "bolt.fill")
          .resizable()
          .scaledToFit()
          .frame(square: geo.size.width * 0.4)
          .offset(x: geo.size.width * -0.04, y: geo.size.height * 0.05)
          .foregroundStyle(boltTint.gradient)
          .shadow(color: boltTint.opacity(0.4), radius: 10, x: 0.0, y: 0.0)
      }
    }
    .compositingGroup()
  }
}

// MARK: - Icon with Animated Background

extension MuggleElectricCup {

  static let skyTint = Color(
    hue: 243 / 360,
    saturation: 0.66,
    brightness: 0.25
  )

  static let atmosphereTint = Color(
    hue: 243 / 360,
    saturation: 0.6,
    brightness: 0.65
  )

  static let horizonTint = Color(
    hue: (243 + 45) / 360,
    saturation: 0.75,
    brightness: 0.7
  )

  static let glow = Color(
    hue: 26 / 360,
    saturation: 0.35,
    brightness: 1
  )

  static func squircle(in dimension: CGFloat) -> RoundedRectangle {
    RoundedRectangle(cornerRadius: dimension * 0.22, style: .continuous)
  }

  struct WithBackground<Stars: View, Atmosphere: View>: View {

    var background = LinearGradient(
      colors: [skyTint, atmosphereTint,  horizonTint],
      startPoint: .top,
      endPoint: .init(x: 0.24, y: 1.2)
    )

    let stars: Stars
    let atmosphere: Atmosphere

    var body: some View {
      GeometryReader { geo in
        let dimension = min(geo.size.width, geo.size.height)
        let padding = dimension * 0.12
        ZStack {
          stars
          atmosphere

          Ellipse()
            .foregroundStyle(MuggleElectricCup.skyTint.opacity(0.5))
            // Adding a blend mode will cause an artifact in the ImageRenderer for app icon export
            .blur(radius: dimension * 0.07)
            .frame(width: dimension * 0.95, height: dimension * 0.22)
            .frame(maxHeight: .infinity, alignment: .bottom)
            .offset(x: dimension * -0.03, y: dimension * 0.07)

          MuggleElectricCup()
            .offset(x: dimension * 0.03, y: dimension * 0.05)
            .shadow(
              color: MuggleElectricCup.glow.opacity(0.28),
              radius: dimension * 0.4
            )
            .padding(padding)
        }
        .frame(square: dimension)
        .background(background, in: .containerRelative)
      }
      .clipShape(.containerRelative)
      .compositingGroup()
    }
  }
}
