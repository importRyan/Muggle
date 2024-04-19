import SwiftUI

struct ShootingStarView: View {
  @State private var startPosition = true
  @State private var startOpacity = true
  @State private var offsetX = -0.35

  var body: some View {
    GeometryReader { geo in
      let canvas = geo.size.width
      let trail = 40.0
      let halfTrail = trail / 2
      let angle = Angle.degrees(-35)
      let start = CGPoint(x: canvas + halfTrail, y: -halfTrail)
      let end = CGPoint(x: (canvas + trail) * tan(angle.radians * 0.9), y: canvas + trail)

      StarTrailShape()
        .stroke(
          LinearGradient(
            colors: [
              .white.opacity(0.6),
              .white.opacity(0.1),
              .white.opacity(0)
            ],
            startPoint: .bottomLeading,
            endPoint: .topTrailing
          ),
          lineWidth: 1
        )
        .frame(width: trail, height: 1)
        .rotationEffect(angle)
        .position(startPosition ? start : end)
        .opacity(startOpacity ? 1 : 0)
        .offset(x: offsetX * canvas)
    }
    .task {
      try? await Task.sleep(for: .seconds(1))
      let move = Animation.steepCurve(duration: 1.8)
      let hide = Animation.linear(duration: 1.6)
      let randomRange = -0.6...0.3
      withAnimation(move) { startPosition = false }
      withAnimation(hide) { startOpacity = false }
      try? await Task.sleep(for: .seconds(2.5))
      while true {
        (startPosition, startOpacity) = (true, true)
        offsetX = .random(in: randomRange)
        withAnimation(move) { startPosition = false }
        withAnimation(hide) { startOpacity = false }
        try? await Task.sleep(for: .seconds(Int.random(in: 3...6)))
      }
    }
  }
}

private extension Animation {
  static func steepCurve(duration: Double) -> Animation {
    .timingCurve(0.6, 0, 0.9, -0.1, duration: duration)
  }
}

private struct StarTrailShape: Shape {
  func path(in rect: CGRect) -> Path {
    var path = Path()
    path.move(to: CGPoint(x: rect.minX, y: rect.minY))
    path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
    return path
  }
}
