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

  static let muggleLogoClusters: [[CGFloat]] = [
    [0.1, 0.1],
    [0.1, 0.2],
    [0.1, 0.3],
    [0.1, 0.4],
    [0.1, 0.5],
    [0.1, 0.6],
    [0.1, 0.7],
    [0.1, 0.9],
    [0.2, 0.1],
    [0.2, 0.9],
    [0.3, 0.1],
    [0.4, 0.1],
    [0.5, 0.1],
    [0.6, 0.1],
    [0.7, 0.1],
    [0.8, 0.1],
    [0.8, 0.2],
    [0.8, 0.3],
    [0.8, 0.4],
    [0.8, 0.5],
    [0.8, 0.6],
    [0.8, 0.9],
    [0.9, 0.1],
    [0.9, 0.2],
    [0.9, 0.3],
    [0.9, 0.4],
    [0.9, 0.5],
    [0.9, 0.6],
    [0.9, 0.7],
    [0.9, 0.7],
    [0.9, 0.8],
    [0.9, 0.9],
  ]

  private let clusters: [[CGFloat]]
  private let minStarSizeMultiplier: Float
  private let maxStarSizeMultiplier: Float
  private let stars: Int
  private let randomizer: GKRandomSource

  init(seed: UInt64 = 0, minStarSizeMultiplier: Float = 0.002, maxStarSizeMultiplier: Float = 0.006, stars: Int = 150, clusters: [[CGFloat]] = Self.muggleLogoClusters) {
    self.randomizer = GKLinearCongruentialRandomSource(seed: seed)
    self.clusters = clusters
    self.stars = stars
    self.minStarSizeMultiplier = minStarSizeMultiplier
    self.maxStarSizeMultiplier = maxStarSizeMultiplier
  }

  func path(in rect: CGRect) -> Path {
    var path = Path()
    let dimension = min(Float(rect.width), Float(rect.height))
    let starSizeRange = (dimension * minStarSizeMultiplier)...(dimension * maxStarSizeMultiplier)
    let clustersCountFloat = Float(clusters.count)
    let widthMultiplier = Float(rect.width / 5)
    let widthConstant = widthMultiplier /  2
    let heightMultiplier = Float(rect.height / 5)
    let heightConstant = heightMultiplier / 2

    for _ in 0..<stars {
      let centerIndex = Int(randomizer.nextUniform() * clustersCountFloat)
      let centerPosition = clusters[centerIndex]
      let centerX = Float(centerPosition[0] * rect.width)
      let centerY = Float(centerPosition[1] * rect.height)

      let randomX = randomizer.nextUniform() * widthMultiplier + centerX - widthConstant
      let randomY = randomizer.nextUniform() * heightMultiplier + centerY - heightConstant

      let starSize = CGFloat(starSizeRange.lerp(randomizer.nextUniform()))
      let starRect = CGRect(x: CGFloat(randomX), y: CGFloat(randomY), width: starSize, height: starSize)
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
