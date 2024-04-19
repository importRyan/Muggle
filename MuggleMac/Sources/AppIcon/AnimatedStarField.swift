import GameplayKit
import SwiftUI

struct AnimatedStarField<Stars: Shape>: View {

  @Environment(\.accessibilityPlayAnimatedImages) private var playAnimations
  @Environment(\.accessibilityReduceMotion) private var reduceMotion
  @State private var isTwinkling = false

  var layer1: Stars
  var layer2: Stars
  var layer3: Stars
  var layer4: Stars

  var body: some View {
    ZStack {
      layer1
        .animation(.linear(duration: 600).repeatForever(autoreverses: false)) {
          $0.rotationEffect(.degrees(isTwinkling ? 0 : -360), anchor: .bottom)
        }
      layer2
        .animation(.linear(duration: 5).repeatForever()) {
          $0.opacity(isTwinkling ? 1 : 0.2)
        }
      layer3
        .animation(.linear(duration: 1000).repeatForever(autoreverses: false)) {
          $0.rotationEffect(.degrees(isTwinkling ? 0 : -360))
        }
      layer4
        .opacity(0.3).blur(radius: 1)
    }
    .foregroundStyle(.white)
    .onAppear {
      if reduceMotion { return }
      guard playAnimations else { return }
      isTwinkling = true
    }
  }
}

struct RandomStars: Shape, @unchecked Sendable {

  private let minStarSizeMultiplier: Float
  private let maxStarSizeMultiplier: Float
  private let stars: Int
  private let randomizer: GKRandomSource

  init(seed: UInt64 = 0, minStarSizeMultiplier: Float = 0.002, maxStarSizeMultiplier: Float = 0.006, stars: Int = 200) {
    self.randomizer = GKLinearCongruentialRandomSource(seed: seed)
    self.stars = stars
    self.minStarSizeMultiplier = minStarSizeMultiplier
    self.maxStarSizeMultiplier = maxStarSizeMultiplier
  }

  func path(in rect: CGRect) -> Path {
    var path = Path()
    let dimension = min(Float(rect.width), Float(rect.height))
    let starSizeRange = (dimension * minStarSizeMultiplier)...(dimension * maxStarSizeMultiplier)

    for _ in 0..<stars {
      let starSize = CGFloat(starSizeRange.lerp(randomizer.nextUniform()))
      let starRect = CGRect(
        x: CGFloat(randomizer.nextUniform()) * rect.height,
        y: CGFloat(randomizer.nextUniform()) * rect.width,
        width: starSize,
        height: starSize
      )
      path.addEllipse(in: starRect)
    }

    return path
  }
}

private extension ClosedRange {
  func lerp(_ t: Bound) -> Bound where Bound: FloatingPoint {
    lowerBound + t * (upperBound - lowerBound)
  }
}
