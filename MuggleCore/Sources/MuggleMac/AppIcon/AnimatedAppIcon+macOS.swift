#if DEBUG
import Common
import SwiftUI

#Preview {
  AppStoreIconRecipe(
    fields: CachedStarFields(size: 256.0, maxStarSizeMultiplier: 0.006), 
    inset: 10
  )
  .clipShape(.rect)
  .padding()
  .background(.white)
}

@MainActor
func renderMacOSIcons() async -> URL {
  let recipes: [AppStoreIconRecipe] = [
    .init(fields: CachedStarFields(size: 16.0), inset: 0),
    .init(fields: CachedStarFields(size: 32.0), inset: 0),
    .init(fields: CachedStarFields(size: 128.0), inset: 8),
    .init(fields: CachedStarFields(size: 256.0, maxStarSizeMultiplier: 0.006), inset: 14),
    .init(fields: CachedStarFields(size: 512.0, maxStarSizeMultiplier: 0.004), inset: 28),
  ]
  let cacheDir = try! FileManager.default.url(
    for: .cachesDirectory,
    in: .userDomainMask,
    appropriateFor: .cachesDirectory,
    create: true
  )
  for (filename, png) in recipes.flatMap(\.rendered) {
    try! png.write(to: cacheDir.appendingPathComponent(filename, conformingTo: .png))
  }
  return cacheDir
}

fileprivate struct AppStoreIconRecipe: View {
  let fields: CachedStarFields
  let inset: CGFloat

  @MainActor
  var rendered: [(filename: String, png: Data)] {
    [
      ("Muggle\(fields.size.rounded())", png(scale: 1)),
      ("Muggle\(fields.size.rounded())@2x", png(scale: 2)),
    ]
  }

  var body: some View {
    let shadowRadius = inset * 0.3
    let shadowOffsetX = shadowRadius * cos(.pi/4)
    let shadowOffsetY = shadowRadius * sin(.pi/4)
    AnimatedAppIcon(
      border: RoundedRectangle(cornerRadius: fields.size * 0.15, style: .continuous),
      fields: CachedStarFields(size: fields.size - inset, maxStarSizeMultiplier: 0.006)
    )
    .frame(square: fields.size)
    .compositingGroup()
    .shadow(
      color: .black.opacity(0.5),
      radius: shadowRadius,
      x: shadowOffsetX,
      y: shadowOffsetY
    )
    .offset(
      x: -shadowOffsetX,
      y: -shadowOffsetY
    )
  }

  @MainActor
  private func png(scale: CGFloat) -> Data {
    let renderer = ImageRenderer(content: body)
    renderer.isOpaque = false
    renderer.scale = scale
    guard let image = renderer.cgImage else { fatalError() }
    let bitmap = NSBitmapImageRep(cgImage: image)
    guard let data = bitmap.representation(using: .png, properties: [:]) else { fatalError() }
    return data
  }
}
#endif
