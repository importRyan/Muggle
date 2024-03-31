import SwiftUI

struct CachedStarFields {
  let a: Path
  let b: Path
  let c: Path
  let d: Path
  let size: CGFloat

  init(size: CGFloat, maxStarSizeMultiplier: Float = 0.008) {
    self.size = size
    self.a = RandomStars(seed: 200, maxStarSizeMultiplier: maxStarSizeMultiplier).path(inSquare: size)
    self.b = RandomStars(seed: 9409).path(inSquare: size)
    self.c = RandomStars(seed: 22323, maxStarSizeMultiplier: maxStarSizeMultiplier).path(inSquare: size)
    self.d = RandomStars(seed: 5454, maxStarSizeMultiplier: 0.01).path(inSquare: size)
  }
}
